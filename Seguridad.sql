/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Osorio (43035245)

Enunciado: Entrega 5
Requisitos de seguridad
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
La información de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma.
*/

USE Com2900G04
GO

--Tabla Notas de credito
CREATE OR ALTER TABLE NotaDeCredito (
    NotaCreditoID INT PRIMARY KEY IDENTITY(1,1),
    FacturaID INT NOT NULL,
    ClienteID INT NOT NULL,
    FechaEmision DATETIME DEFAULT GETDATE(),
    Monto DECIMAL(18,2) NOT NULL,
    Tipo VARCHAR(50) CHECK (Tipo IN ('Valor', 'Producto')),
    ProductoID INT NULL, -- Solo se usará si el tipo es 'Producto'
GO

--Lista de usuarios existentes
SELECT name, type 
FROM sys.database_principals 
WHERE type IN ('S', 'U') -- S: SQL user, U: Windows user
GO

--creamos un inicio de sesión en el servidor
CREATE LOGIN SupervisorLogin 
WITH PASSWORD = 'TuContraseñaSegura';
GO

--Creamos una sesion
USE Com2900G04
CREATE USER SupervisorUser 
FOR LOGIN SupervisorLogin
GO

-- Creamos el rol de Supervisor
CREATE ROLE Supervisor
GO

-- Asignamos el rol Supervisor a un usuario específico 
ALTER ROLE Supervisor ADD MEMBER SupervisorUser
GO

-- Otorgamos permiso de inserción en la tabla NotaDeCredito al rol Supervisor
GRANT INSERT ON NotaDeCredito TO Supervisor
GO

-- Aseguramos de que solo los usuarios con el rol de Supervisor puedan generar una Nota de Crédito
DENY INSERT ON NotaDeCredito TO PUBLIC
GO

-- Creamos un procedimiento almacenado para generar la nota de crédito
CREATE PROCEDURE GenerarNotaCredito
    @FacturaID INT,
    @ClienteID INT,
    @Monto DECIMAL(10, 2)
AS
BEGIN
    -- Verificar que la factura esté pagada antes de crear la nota de crédito
    IF EXISTS (SELECT 1 FROM Facturas WHERE FacturaID = @FacturaID AND Estado = 'Pagada')
    BEGIN
        INSERT INTO NotasCredito (FacturaID, ClienteID, Monto, Fecha)
        VALUES (@FacturaID, @ClienteID, @Monto, GETDATE());
    END
    ELSE
    BEGIN
        RAISERROR ('La factura no está pagada. No se puede generar la nota de crédito.', 16, 1);
    END
END
GO
-- Otorgamos permisos solo al rol Supervisor
GRANT EXECUTE ON GenerarNotaCredito TO Supervisor
GO



--------------Encriptar----------------------------

/*CREATE TABLE rrhh.empleado (
	legajo int not null, -- identity o no?
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	dni int not null,
	direccion varchar(100) not null,
	email_laboral varchar(50),
	cuil char(13) not null, -- ej: 11-22222222-3
	cargo varchar(20) not null, -- ej: gerente de sucursal
	id_sucursal int not null,
	turno varchar(16), -- ej: jornada completa
	baja bit default 0, -- borrado logico
	constraint PK_empleado primary key (legajo),
	constraint CK_email check (
		email_laboral like '%@%.com'
	),
	constraint CK_cuil check (
		cuil like '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
	),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id)
);
go*/


-- Clave de encriptación 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ContraseniaSegura';
CREATE CERTIFICATE EmpleadoCertificado WITH SUBJECT = 'Certificado para encriptación de datos de empleados'
CREATE SYMMETRIC KEY EmpleadoClave WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE EmpleadoCertificado
GO

--encriptar

-- Abrir la clave simétrica para encriptar
OPEN SYMMETRIC KEY EmpleadoClave 
    ENCRYPTION BY CERTIFICATE EmpleadoCertificado;

	SELECT * FROM sys.certificates;
	SELECT * FROM sys.symmetric_keys;

-- Encriptar los datos
UPDATE rrhh.Empleado
SET
    Nombre = EncryptByKey(Key_GUID('EmpleadoClave'), Nombre),
    Direccion = EncryptByKey(Key_GUID('EmpleadoClave'), Direccion);

-- Cerrar la clave simétrica
CLOSE SYMMETRIC KEY EmpleadoClave;
GO

SELECT * FROM sys.certificates WHERE name = 'EmpleadoCertificado';
SELECT * FROM sys.symmetric_keys WHERE name = 'EmpleadoClave';


OPEN SYMMETRIC KEY EmpleadoClave
    ENCRYPTION BY CERTIFICATE EmpleadoCertificado;

-- Encriptar con Key_GUID
UPDATE rrhh.Empleado
SET
    Nombre = EncryptByKey(Key_GUID('EmpleadoClave'), Nombre),
    Direccion = EncryptByKey(Key_GUID('EmpleadoClave'), Direccion);

CLOSE SYMMETRIC KEY EmpleadoClave;
GO


-- Ejemplo para consultar los datos desencriptados
-- Abrir la clave simétrica
OPEN SYMMETRIC KEY EmpleadoClave DECRYPTION BY CERTIFICATE EmpleadoCertificado;

-- Desencriptar los datos
SELECT
    CONVERT(VARCHAR, DecryptByKey(Nombre)) AS Nombre,
    CONVERT(VARCHAR, DecryptByKey(Direccion)) AS Direccion
FROM rrhh.Empleado;

-- Cerrar la clave simétrica
CLOSE SYMMETRIC KEY EmpleadoClave;
GO
Select * from rrhh.empleado




----------------Respaldos--------------------------
--Permisos para crear ruta
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

--Generacion de ruta
EXEC xp_cmdshell 'mkdir C:\Backups';
GO

--Copia de Seguridad completa
BACKUP DATABASE AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Full.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Respaldo Completo Semanal'
GO

--Copia de seguridad Diferencial
BACKUP DATABASE AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Diferencial.bak'
WITH DIFFERENTIAL, NAME = 'Respaldo Diferencial'
GO

--Cambiamos a respaldo full
ALTER DATABASE AuroraDB
SET RECOVERY FULL;
GO

--Primer respaldo antes del log
BACKUP DATABASE AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Full.bak';
GO

--Copia de seguridad Incremental
BACKUP LOG AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Log.bak'
WITH NOFORMAT, NAME = 'Respaldo Incremental Diario'
GO

-- Consultas y Reportes en SQL Server

-- Reporte 1: Listar todas las sucursales con sus horarios y teléfonos
SELECT 
    ciudad,
    direccion,
    horario,
    telefono
FROM 
    rrhh.sucursal
GO

-- Reporte 2: Total de ventas por producto
SELECT 
    p.nombre AS producto,
    SUM(dv.cantidad) AS total_vendido,
    SUM(dv.subtotal) AS total_venta
FROM 
    op.detalleVenta dv
JOIN 
    op.producto p ON dv.id_producto = p.id
GROUP BY 
    p.nombre
ORDER BY 
    total_venta DESC
GO


-- Reporte 3: Costos y proveedores de productos importados
SELECT 
    p.nombre AS producto,
    p.precio AS costo,
    p.proveedor,
    p.precio_dolares AS costo_en_dolares
FROM 
    op.producto p
WHERE 
    p.precio_dolares IS NOT NULL
ORDER BY 
    p.nombre;
GO


-- Reporte 4: Listado de todos los productos, su categoría y precio
SELECT 
    nombre AS producto,
    categoria,
    precio
FROM 
    op.producto
WHERE 
    baja = 0
ORDER BY 
    categoria, nombre;
GO
