#!/usr/bin/env python3
"""Limpa um manifest do kubectl removendo campos de runtime/server-side.

Uso:
    kubectl get <kind> <name> -n <ns> -o yaml | python3 clean_yaml.py
"""
import sys
import yaml

DROP_METADATA_KEYS = {
    "creationTimestamp",
    "resourceVersion",
    "uid",
    "generation",
    "managedFields",
    "selfLink",
    "finalizers",
    "ownerReferences",
}

DROP_ANNOTATION_KEYS = {
    "kubectl.kubernetes.io/last-applied-configuration",
    "deployment.kubernetes.io/revision",
    "control-plane.alpha.kubernetes.io/leader",
    "pv.kubernetes.io/bind-completed",
    "pv.kubernetes.io/bound-by-controller",
    "volume.beta.kubernetes.io/storage-provisioner",
    "volume.kubernetes.io/storage-provisioner",
    "volume.kubernetes.io/selected-node",
}


def is_default(key: str, value, parent_kind: str) -> bool:
    defaults = {
        "imagePullPolicy": "IfNotPresent",
        "terminationMessagePath": "/dev/termination-log",
        "terminationMessagePolicy": "File",
        "dnsPolicy": "ClusterFirst",
        "restartPolicy": "Always",
        "schedulerName": "default-scheduler",
        "successThreshold": 1,
        "protocol": "TCP",
        "revisionHistoryLimit": 10,
        "progressDeadlineSeconds": 600,
        "podManagementPolicy": "OrderedReady",
        "volumeMode": "Filesystem",
        "terminationGracePeriodSeconds": 30,
    }
    return defaults.get(key) == value


def walk_clean(node):
    if isinstance(node, dict):
        for key in list(node.keys()):
            if key == "status":
                node.pop(key)
                continue
            if key == "securityContext" and node[key] == {}:
                node.pop(key)
                continue
            if is_default(key, node[key], ""):
                node.pop(key)
                continue
            walk_clean(node[key])
    elif isinstance(node, list):
        for item in node:
            walk_clean(item)


def clean(obj: dict) -> dict:
    if not isinstance(obj, dict):
        return obj

    obj.pop("status", None)

    metadata = obj.get("metadata") or {}
    for key in list(metadata.keys()):
        if key in DROP_METADATA_KEYS:
            metadata.pop(key, None)
    annotations = metadata.get("annotations") or {}
    for key in list(annotations.keys()):
        if key in DROP_ANNOTATION_KEYS:
            annotations.pop(key, None)
        elif key.startswith("kubectl.kubernetes.io/"):
            annotations.pop(key, None)
    if not annotations:
        metadata.pop("annotations", None)
    else:
        metadata["annotations"] = annotations
    labels = metadata.get("labels") or {}
    for key in list(labels.keys()):
        if key.startswith("controller.cattle.io/") or key.startswith("objectset.rio.cattle.io/"):
            labels.pop(key)
    if not labels:
        metadata.pop("labels", None)

    spec = obj.get("spec")
    if isinstance(spec, dict):
        spec.pop("clusterIP", None)
        spec.pop("clusterIPs", None)
        if spec.get("type") == "ClusterIP" and "ipFamilies" in spec:
            spec.pop("ipFamilies", None)
            spec.pop("ipFamilyPolicy", None)
            spec.pop("internalTrafficPolicy", None)
            spec.pop("sessionAffinity", None)
        template = spec.get("template")
        if isinstance(template, dict):
            tm = template.get("metadata") or {}
            tm.pop("creationTimestamp", None)
            if not tm:
                template.pop("metadata", None)
        for tpl in spec.get("volumeClaimTemplates", []) or []:
            tm = tpl.get("metadata") or {}
            tm.pop("creationTimestamp", None)
            tpl.pop("status", None)
        for key in (
            "updateStrategy",
            "persistentVolumeClaimRetentionPolicy",
            "strategy",
        ):
            spec.pop(key, None) if spec.get(key) in (None, {}) else None
        upd = spec.get("updateStrategy")
        if isinstance(upd, dict):
            ru = upd.get("rollingUpdate")
            if isinstance(ru, dict) and ru.get("partition") == 0:
                ru.pop("partition")
                if not ru:
                    upd.pop("rollingUpdate")

    walk_clean(obj)
    return obj


def main() -> None:
    raw = sys.stdin.read()
    docs = list(yaml.safe_load_all(raw))
    cleaned = []
    for doc in docs:
        if doc is None:
            continue
        if doc.get("kind") == "List":
            for item in doc.get("items", []):
                cleaned.append(clean(item))
        else:
            cleaned.append(clean(doc))
    yaml.safe_dump_all(
        cleaned,
        sys.stdout,
        default_flow_style=False,
        sort_keys=False,
        width=4096,
    )


if __name__ == "__main__":
    main()
