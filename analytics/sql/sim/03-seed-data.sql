-- Seed ~15 rows por tenant; id_grupo_usuario variado para agregação gold

USE [MereoGR-Afya];
GO
IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADOR WHERE ID = 1)
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO) VALUES
    (1,  10, N'Ana Afya',      N'ana.afya@mereo.local',      1),
    (2,  10, N'Bruno Afya',    N'bruno.afya@mereo.local',    1),
    (3,  10, N'Carla Afya',    N'carla.afya@mereo.local',    1),
    (4,  20, N'Diego Afya',    N'diego.afya@mereo.local',    1),
    (5,  20, N'Elisa Afya',    N'elisa.afya@mereo.local',    1),
    (6,  20, N'Fabio Afya',    N'fabio.afya@mereo.local',    0),
    (7,  30, N'Gisele Afya',   N'gisele.afya@mereo.local',   1),
    (8,  30, N'Hugo Afya',     N'hugo.afya@mereo.local',     1),
    (9,  30, N'Iris Afya',     N'iris.afya@mereo.local',     1),
    (10, 30, N'Joao Afya',     N'joao.afya@mereo.local',     1),
    (11, 40, N'Kelly Afya',    N'kelly.afya@mereo.local',    1),
    (12, 40, N'Leo Afya',      N'leo.afya@mereo.local',      1),
    (13, 50, N'Maria Afya',    N'maria.afya@mereo.local',    1),
    (14, 50, N'Nelson Afya',   N'nelson.afya@mereo.local',   1),
    (15, 50, N'Olivia Afya',   N'olivia.afya@mereo.local',   1);
GO

USE [MereoGR-Staging];
GO
IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADOR WHERE ID = 1)
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO) VALUES
    (1,  100, N'Paula Staging',  N'paula.staging@mereo.local',  1),
    (2,  100, N'Quintino Staging', N'quintino.staging@mereo.local', 1),
    (3,  100, N'Rita Staging',   N'rita.staging@mereo.local',    1),
    (4,  200, N'Sergio Staging', N'sergio.staging@mereo.local',  1),
    (5,  200, N'Tania Staging',  N'tania.staging@mereo.local',   1),
    (6,  200, N'Ugo Staging',    N'ugo.staging@mereo.local',     0),
    (7,  300, N'Vera Staging',   N'vera.staging@mereo.local',    1),
    (8,  300, N'Walter Staging', N'walter.staging@mereo.local',  1),
    (9,  300, N'Xenia Staging',  N'xenia.staging@mereo.local',   1),
    (10, 300, N'Yuri Staging',   N'yuri.staging@mereo.local',    1),
    (11, 400, N'Zeca Staging',   N'zeca.staging@mereo.local',    1),
    (12, 400, N'Alice Staging',  N'alice.staging@mereo.local',   1),
    (13, 500, N'Bob Staging',    N'bob.staging@mereo.local',     1),
    (14, 500, N'Cecilia Staging', N'cecilia.staging@mereo.local', 1),
    (15, 500, N'Dan Staging',    N'dan.staging@mereo.local',     1);
GO

USE [MereoGR-Allos];
GO
IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADOR WHERE ID = 1)
INSERT INTO dbo.COLABORADOR (ID, ID_GRUPO_USUARIO, NOME, EMAIL, ATIVO) VALUES
    (1,  1000, N'Emma Allos',    N'emma.allos@mereo.local',    1),
    (2,  1000, N'Frank Allos',   N'frank.allos@mereo.local',   1),
    (3,  1000, N'Grace Allos',   N'grace.allos@mereo.local',   1),
    (4,  2000, N'Henry Allos',   N'henry.allos@mereo.local',   1),
    (5,  2000, N'Ivy Allos',     N'ivy.allos@mereo.local',     1),
    (6,  2000, N'Jack Allos',    N'jack.allos@mereo.local',    0),
    (7,  3000, N'Kate Allos',    N'kate.allos@mereo.local',    1),
    (8,  3000, N'Liam Allos',    N'liam.allos@mereo.local',    1),
    (9,  3000, N'Mia Allos',     N'mia.allos@mereo.local',     1),
    (10, 3000, N'Noah Allos',    N'noah.allos@mereo.local',    1),
    (11, 4000, N'Olive Allos',   N'olive.allos@mereo.local',   1),
    (12, 4000, N'Pete Allos',    N'pete.allos@mereo.local',    1),
    (13, 5000, N'Quinn Allos',   N'quinn.allos@mereo.local',   1),
    (14, 5000, N'Rose Allos',    N'rose.allos@mereo.local',    1),
    (15, 5000, N'Sam Allos',     N'sam.allos@mereo.local',     1);
GO
