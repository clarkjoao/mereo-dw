-- Habilitar CDC nos bancos piloto (executar no SQL Server com permissões sysadmin).
-- Repetir bloco por tenant: MereoGR-Afya, MereoGR-Staging, MereoGR-Allos

USE MereoGR-Afya;
GO
EXEC sys.sp_cdc_enable_db;
GO
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'COLABORADOR',
    @role_name     = NULL,
    @supports_net_changes = 1;
GO

USE MereoGR-Staging;
GO
EXEC sys.sp_cdc_enable_db;
GO
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'COLABORADOR',
    @role_name     = NULL,
    @supports_net_changes = 1;
GO

USE MereoGR-Allos;
GO
EXEC sys.sp_cdc_enable_db;
GO
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'COLABORADOR',
    @role_name     = NULL,
    @supports_net_changes = 1;
GO

-- Validar:
-- SELECT name, is_cdc_enabled FROM sys.databases WHERE name LIKE 'MereoGR-%';
-- SELECT * FROM cdc.change_tables;
