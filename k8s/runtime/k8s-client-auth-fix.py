# kubernetes-client 36.x: load_incluster_config grava api_key["authorization"],
# mas auth_settings() só lê api_key["BearerToken"] — requests saem como system:anonymous.
from kubernetes.client.configuration import Configuration

_orig_auth_settings = Configuration.auth_settings


def _patched_auth_settings(self):
    if "authorization" in self.api_key and "BearerToken" not in self.api_key:
        self.api_key["BearerToken"] = self.api_key["authorization"]
    return _orig_auth_settings(self)


Configuration.auth_settings = _patched_auth_settings
