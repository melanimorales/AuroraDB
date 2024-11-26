/* Materia: Base de datos aplicada
Fecha de entrega: 05/11/2024
Grupo: 4
Nombres y DNI: Melani Antonella Morales Castillo(42242365).
				Tomas Osorio (43035245)
				Pablo Mela(41027430)

Enunciado:Entrega 4
Se requiere que importe toda la información antes mencionada a la base de datos: 
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los 
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de 
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.  
• Considere este comportamiento al generar el código. Debe admitir la importación de 
novedades periódicamente. 
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que 
realicen tareas por fuera de un SP. 
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba 
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la 
estructura requerida.  
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal 
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones 
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible 
interpretarlo como JSON o CSV). 
*/

-- Selección de la base de datos creada anteriormente
use AuroraDB;
go

-- Creación de las tablas temporales para la importación de los archivos
create table #importado (
	id int identity(1,1) primary key,
	nombre varchar(50) not null,
	id_proveedor int not null,
	id_categoria int not null,
	cantidad_unidad varchar(20) not null, -- 10 cajas x 12 piezas
	precio_unidad decimal(5,2) not null -- 123,79
);
go

create table #producto_electronico (
	id int identity(1,1) primary key,
	nombre varchar(50) not null,
	precio_dolares decimal(6,2) not null -- 1700,00
);
go

-- SUPUESTAMENTE NO SE PUEDE IMPORTAR A UNA TABLA TEMPORAL CON BULK INSERT
CREATE TABLE catalogo (
    id INT NOT NULL PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL,
    nombre NVARCHAR(200) NOT NULL,
    precio DECIMAL(5, 2) NOT NULL,
    precio_referencia DECIMAL(5, 2) NOT NULL,
    unidad_referencia VARCHAR(10) NOT NULL,
    fecha DATETIME
);
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

--drop table catalogo
--go
/*
CON ESTE SP NO LO PUDE IMPORTAR PORQUE ALGUNAS LINEAS DEL ARCHIVO CONTIENEN
UNA COMA DENTRO DE UNO DE LOS CAMPOS, QUE ADEMAS ESTA ENCERRADO EN COMILLAS DOBLES

create or alter procedure importarCatalogo
as
begin
	BULK INSERT catalogo
	FROM 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\catalogo.csv'
	WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001',
    FIRSTROW = 2
	);
end
go
*/
/*
ESTAS CONFIGURACIONES SON NECESARIAS PARA UTILIZAR OPENROWSET

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
go
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
go

LUEGO DE EJECUTAR LAS SIGUIENTES LINEAS Y AL INTENTAR CREAR EL SP NUEVAMENTE, SE DETIENE EL SERVER

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1;
go
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;
go
*/
CREATE OR ALTER PROCEDURE importarCatalogo
    @filePath NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        -- Usar OPENROWSET para leer los datos del CSV
        INSERT INTO catalogo (id, categoria, nombre, precio, precio_referencia, unidad_referencia, fecha)
        SELECT *
        FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.16.0', 
            'Text;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\;HDR=YES;FMT=Delimited', 
            'SELECT * FROM catalogo.csv'
        );
        
        PRINT 'Datos importados exitosamente';
    END TRY
    BEGIN CATCH
        PRINT 'Error al importar los datos: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

exec importarCatalogo;
go

select top 20 * from dbo.catalogo
go