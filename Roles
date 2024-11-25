
--Verificamos que usuarios existen
SELECT name 
FROM sys.database_principals 
WHERE type IN ('S', 'U'); -- S: SQL user, U: Windows user
GO

--Creamos el inicio de sesion
CREATE LOGIN SupervisorLogin 
WITH PASSWORD = 'TuContraseñaSegura';
GO

--Creamos un usuario
USE AuroraDB;
CREATE USER SupervisorUser 
FOR LOGIN SupervisorLogin;
GO
  
--Creamos el rol
CREATE ROLE Supervisor
GO
  
--Le otorgamos permisos a la tabla
GRANT INSERT, UPDATE, DELETE ON dbo.NotaCredito TO Supervisor --Crear tabla nota de credito
GO
  
--Asignamos el rol al usuario
EXEC sp_addrolemember 'Supervisor', 'SupervisorUser'
GO
  
--Verificamos el procedimiento
SELECT DP1.name AS DatabaseRoleName,
       DP2.name AS MemberName
FROM sys.database_role_members AS DRM
INNER JOIN sys.database_principals AS DP1
    ON DRM.role_principal_id = DP1.principal_id
INNER JOIN sys.database_principals AS DP2
    ON DRM.member_principal_id = DP2.principal_id
WHERE DP2.name = 'SupervisorUser'
GO
