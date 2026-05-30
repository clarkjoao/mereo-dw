-- Habilitar CDC nos 3 bancos piloto simulados (requer SQL Server Agent)

USE [MereoGR-Afya];
GO
IF (SELECT is_cdc_enabled FROM sys.databases WHERE name = N'MereoGR-Afya') = 0
    EXEC sys.sp_cdc_enable_db;
GO
IF NOT EXISTS (
    SELECT 1 FROM cdc.change_tables
    WHERE source_object_id = OBJECT_ID(N'dbo.COLABORADOR')
)
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'COLABORADOR',
        @role_name     = NULL,
        @supports_net_changes = 1;
GO

USE [MereoGR-Staging];
GO
IF (SELECT is_cdc_enabled FROM sys.databases WHERE name = N'MereoGR-Staging') = 0
    EXEC sys.sp_cdc_enable_db;
GO
IF NOT EXISTS (
    SELECT 1 FROM cdc.change_tables
    WHERE source_object_id = OBJECT_ID(N'dbo.COLABORADOR')
)
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'COLABORADOR',
        @role_name     = NULL,
        @supports_net_changes = 1;
GO

USE [MereoGR-Allos];
GO
IF (SELECT is_cdc_enabled FROM sys.databases WHERE name = N'MereoGR-Allos') = 0
    EXEC sys.sp_cdc_enable_db;
GO
IF NOT EXISTS (
    SELECT 1 FROM cdc.change_tables
    WHERE source_object_id = OBJECT_ID(N'dbo.COLABORADOR')
)
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'COLABORADOR',
        @role_name     = NULL,
        @supports_net_changes = 1;
GO
