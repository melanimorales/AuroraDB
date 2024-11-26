/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Osorio (43035245)

Enunciado: Entrega 5
Requisitos de seguridad
Cuando un cliente reclama la devoluci�n de un producto se genera una nota de cr�dito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de cr�dito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de cr�dito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen informaci�n personal.
La informaci�n de las ventas es de vital importancia para el negocio, por ello se requiere que
se establezcan pol�ticas de respaldo tanto en las ventas diarias generadas como en los
reportes generados.
Plantee una pol�tica de respaldo adecuada para cumplir con este requisito y justifique la
misma.
*/

--Lista de usuarios existentes
SELECT name, type 
FROM sys.database_principals 
WHERE type IN ('S', 'U') -- S: SQL user, U: Windows user

--creamos un inicio de sesi�n en el servidor
CREATE LOGIN SupervisorLogin 
WITH PASSWORD = 'TuContrase�aSegura';

--Creamos una sesion
USE Com2900G04;
CREATE USER SupervisorUser 
FOR LOGIN SupervisorLogin;

--Tabla Notas de credito
CREATE TABLE NotaDeCredito (
    NotaCreditoID INT PRIMARY KEY IDENTITY(1,1),
    FacturaID INT NOT NULL,
    ClienteID INT NOT NULL,
    FechaEmision DATETIME DEFAULT GETDATE(),
    Monto DECIMAL(18,2) NOT NULL,
    Tipo VARCHAR(50) CHECK (Tipo IN ('Valor', 'Producto')),
    ProductoID INT NULL, -- Solo se usar� si el tipo es 'Producto'
    FOREIGN KEY (FacturaID) REFERENCES Factura(FacturaID),
    FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
    FOREIGN KEY (ProductoID) REFERENCES Catalogo(ProductoID)
);
GO

-- Creamos el rol de Supervisor
CREATE ROLE Supervisor

-- Asignamos el rol Supervisor a un usuario espec�fico 
ALTER ROLE Supervisor ADD MEMBER SupervisorUser

-- Otorgamos permiso de inserci�n en la tabla NotaDeCredito al rol Supervisor
GRANT INSERT ON NotaDeCredito TO Supervisor

-- Aseguramos de que solo los usuarios con el rol de Supervisor puedan generar una Nota de Cr�dito
DENY INSERT ON NotaDeCredito TO PUBLIC

-- Creamos un procedimiento almacenado para generar la nota de cr�dito
CREATE PROCEDURE GenerarNotaCredito
    @FacturaID INT,
    @ClienteID INT,
    @Monto DECIMAL(10, 2)
AS
BEGIN
    -- Verificar que la factura est� pagada antes de crear la nota de cr�dito
    IF EXISTS (SELECT 1 FROM Facturas WHERE FacturaID = @FacturaID AND Estado = 'Pagada')
    BEGIN
        INSERT INTO NotasCredito (FacturaID, ClienteID, Monto, Fecha)
        VALUES (@FacturaID, @ClienteID, @Monto, GETDATE());
    END
    ELSE
    BEGIN
        RAISERROR ('La factura no est� pagada. No se puede generar la nota de cr�dito.', 16, 1);
    END
END

-- Otorgamos permisos solo al rol Supervisor
GRANT EXECUTE ON GenerarNotaCredito TO Supervisor

-- Abrimos la clave para poder cifrar los datos
OPEN SYMMETRIC KEY EmpleadosClave
DECRYPTION BY CERTIFICATE EmpleadosCertificado

-- Ejemplo de cifrado de una columna de la tabla Empleados
UPDATE Empleados
SET Nombre = ENCRYPTBYKEY(KEY_GUID('EmpleadosClave'), Nombre),
    Direccion = ENCRYPTBYKEY(KEY_GUID('EmpleadosClave'), Direccion)

-- Cerramos la clave sim�trica
CLOSE SYMMETRIC KEY EmpleadosClave


-- Abrimos la clave para poder descifrar los datos
OPEN SYMMETRIC KEY EmpleadosClave
DECRYPTION BY CERTIFICATE EmpleadosCertificado

-- Seleccionamos y desciframos datos
SELECT
    CAST(DECRYPTBYKEY(Nombre) AS NVARCHAR(50)) AS Nombre,
    CAST(DECRYPTBYKEY(Direccion) AS NVARCHAR(100)) AS Direccion
FROM Empleados

-- Cerramos la clave sim�trica
CLOSE SYMMETRIC KEY EmpleadosClave


--------------Encriptar----------------------------
-- Agregar columnas encriptadas en la tabla de Empleados
CREATE TABLE Empleado (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARBINARY(256) NOT NULL,
    Direccion VARBINARY(256) NOT NULL,
    Telefono VARBINARY(256) NOT NULL
);

-- Clave de encriptaci�n 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ContraseniaSegura';
CREATE CERTIFICATE EmpleadoCertificado WITH SUBJECT = 'Certificado para encriptaci�n de datos de empleados'
CREATE SYMMETRIC KEY EmpleadoClave WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE EmpleadoCertificado

-- Ejemplo para insertar un empleado con datos encriptados
OPEN SYMMETRIC KEY EmpleadoClave DECRYPTION BY CERTIFICATE EmpleadoCertificado
INSERT INTO Empleado (Nombre, Direccion, Telefono)
VALUES (
    EncryptByKey(Key_GUID('EmpleadoClave'), 'Juan Perez'),
    EncryptByKey(Key_GUID('EmpleadoClave'), 'Calle Falsa 123'),
    EncryptByKey(Key_GUID('EmpleadoClave'), '5555-5555')
);
CLOSE SYMMETRIC KEY EmpleadoClave

-- Ejemplo para consultar los datos desencriptados
OPEN SYMMETRIC KEY EmpleadoClave DECRYPTION BY CERTIFICATE EmpleadoCertificado
SELECT
    EmpleadoID,
    CONVERT(VARCHAR, DecryptByKey(Nombre)) AS Nombre,
    CONVERT(VARCHAR, DecryptByKey(Direccion)) AS Direccion,
    CONVERT(VARCHAR, DecryptByKey(Telefono)) AS Telefono
FROM Empleado;
CLOSE SYMMETRIC KEY EmpleadoClave


----------------Respaldos--------------------------
--Copia de Seguridad completa
BACKUP DATABASE AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Full.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Respaldo Completo Semanal'

--Copia de seguridad Diferencial
BACKUP DATABASE AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Diferencial.bak'
WITH DIFFERENTIAL, NAME = 'Respaldo Diferencial'

--Copia de seguridad Incremental
BACKUP LOG AuroraDB
TO DISK = 'C:\Backups\AuroraDB_Log.bak'
WITH NOFORMAT, NAME = 'Respaldo Incremental Diario'


-- Consultas y Reportes en SQL Server

-- Reporte 1: Listar todas las sucursales con sus horarios y tel�fonos
SELECT Ciudad, Direccion, Horario, Telefono
FROM dbo.InformacionComplementaria

-- Reporte 2: Total de ventas por producto
SELECT c.NombreProducto, SUM(v.Cantidad) AS TotalCantidad, SUM(v.Total) AS TotalVentas
FROM dbo.VentasRegistradas v
JOIN dbo.Catalogo c ON v.ProductoID = c.ProductoID
GROUP BY c.NombreProducto

-- Reporte 3: Productos con bajo stock (por ejemplo, menos de 10 unidades)
SELECT ProductoID, NombreProducto, Stock
FROM dbo.Catalogo
WHERE Stock < 10

-- Reporte 4: Costos y proveedores de productos importados
SELECT c.NombreProducto, p.Proveedor, p.Costo, p.FechaImportacion
FROM dbo.ProductosImportados p
JOIN dbo.Catalogo c ON p.ProductoID = c.ProductoID

-- Reporte 5: Ventas mensuales promedio (por cada mes en el a�o)
SELECT DATEPART(MONTH, FechaVenta) AS Mes, AVG(Total) AS PromedioVentasMensual
FROM dbo.VentasRegistradas
GROUP BY DATEPART(MONTH, FechaVenta)
ORDER BY Mes

-- Reporte 6: Listado de todos los productos, su categor�a y precio
SELECT NombreProducto, Categoria, Precio
FROM dbo.Catalogo