-- dbo.COLABORADOR — schema alinhado ao contrato analytics/catalog/entities/colaborador.yaml

USE [MereoGR-Afya];
GO
IF OBJECT_ID(N'dbo.COLABORADOR', N'U') IS NULL
CREATE TABLE dbo.COLABORADOR (
    ID                              INT             NOT NULL,
    ID_GRUPO_USUARIO                INT             NULL,
    ID_IDIOMA                       INT             NULL,
    USER_LOGIN                      NVARCHAR(128)   NULL,
    NOME                            NVARCHAR(256)   NULL,
    EMAIL                           NVARCHAR(256)   NULL,
    WORKFLOW_ACOES                  NVARCHAR(MAX)   NULL,
    ATIVO                           BIT             NOT NULL CONSTRAINT DF_COLABORADOR_ATIVO DEFAULT (1),
    FOTO_PATH                       NVARCHAR(512)   NULL,
    USUARIO_AD                      BIT             NULL,
    TIPO_COLABORADOR                INT             NULL,
    EXIBIR_TUTORIAL                 BIT             NULL,
    Registration                    UNIQUEIDENTIFIER NULL,
    EXIBIR_TUTORIAL_DASH_PERFORMANCE BIT            NULL,
    FCMToken                        NVARCHAR(512)   NULL,
    AvailabilityRelocateStatus      INT             NULL,
    SignatureConsentAgreement       BIT             NULL,
    Locality_Id                     INT             NULL,
    CONSTRAINT PK_COLABORADOR PRIMARY KEY CLUSTERED (ID)
);
GO

USE [MereoGR-Staging];
GO
IF OBJECT_ID(N'dbo.COLABORADOR', N'U') IS NULL
CREATE TABLE dbo.COLABORADOR (
    ID                              INT             NOT NULL,
    ID_GRUPO_USUARIO                INT             NULL,
    ID_IDIOMA                       INT             NULL,
    USER_LOGIN                      NVARCHAR(128)   NULL,
    NOME                            NVARCHAR(256)   NULL,
    EMAIL                           NVARCHAR(256)   NULL,
    WORKFLOW_ACOES                  NVARCHAR(MAX)   NULL,
    ATIVO                           BIT             NOT NULL CONSTRAINT DF_COLABORADOR_ATIVO DEFAULT (1),
    FOTO_PATH                       NVARCHAR(512)   NULL,
    USUARIO_AD                      BIT             NULL,
    TIPO_COLABORADOR                INT             NULL,
    EXIBIR_TUTORIAL                 BIT             NULL,
    Registration                    UNIQUEIDENTIFIER NULL,
    EXIBIR_TUTORIAL_DASH_PERFORMANCE BIT            NULL,
    FCMToken                        NVARCHAR(512)   NULL,
    AvailabilityRelocateStatus      INT             NULL,
    SignatureConsentAgreement       BIT             NULL,
    Locality_Id                     INT             NULL,
    CONSTRAINT PK_COLABORADOR PRIMARY KEY CLUSTERED (ID)
);
GO

USE [MereoGR-Allos];
GO
IF OBJECT_ID(N'dbo.COLABORADOR', N'U') IS NULL
CREATE TABLE dbo.COLABORADOR (
    ID                              INT             NOT NULL,
    ID_GRUPO_USUARIO                INT             NULL,
    ID_IDIOMA                       INT             NULL,
    USER_LOGIN                      NVARCHAR(128)   NULL,
    NOME                            NVARCHAR(256)   NULL,
    EMAIL                           NVARCHAR(256)   NULL,
    WORKFLOW_ACOES                  NVARCHAR(MAX)   NULL,
    ATIVO                           BIT             NOT NULL CONSTRAINT DF_COLABORADOR_ATIVO DEFAULT (1),
    FOTO_PATH                       NVARCHAR(512)   NULL,
    USUARIO_AD                      BIT             NULL,
    TIPO_COLABORADOR                INT             NULL,
    EXIBIR_TUTORIAL                 BIT             NULL,
    Registration                    UNIQUEIDENTIFIER NULL,
    EXIBIR_TUTORIAL_DASH_PERFORMANCE BIT            NULL,
    FCMToken                        NVARCHAR(512)   NULL,
    AvailabilityRelocateStatus      INT             NULL,
    SignatureConsentAgreement       BIT             NULL,
    Locality_Id                     INT             NULL,
    CONSTRAINT PK_COLABORADOR PRIMARY KEY CLUSTERED (ID)
);
GO
