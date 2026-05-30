-- Bancos piloto simulados (nomes idênticos ao prod)
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'MereoGR-Afya')
    CREATE DATABASE [MereoGR-Afya];
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'MereoGR-Staging')
    CREATE DATABASE [MereoGR-Staging];
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'MereoGR-Allos')
    CREATE DATABASE [MereoGR-Allos];
GO
