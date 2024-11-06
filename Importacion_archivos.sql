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

----------------------------------ARCHIVO CSV-----------------------------------------------------

----------------------------------"Catálogo"-------------------------------

-- Crear una tabla temporal para almacenar los datos de catalogo.csv
CREATE TABLE #Catalogo (
    ProductoID VARCHAR(MAX),
	Categoria NVARCHAR(MAX),
    Nombre NVARCHAR(MAX),
    Precio VARCHAR(MAX),
    PrecioReferencia VARCHAR(MAX),
	Unidad VARCHAR(MAX),
	Fecha VARCHAR(MAX)
);

DECLARE @archivoC NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\catalogo.csv';


BEGIN TRY
    -- IMPORTAR usando OPENROWSET con el controlador ACE.OLEDB
    INSERT INTO #Catalogo ( ProductoID,
	Categoria,
    Nombre,
    Precio,
    PrecioReferencia,
	Unidad,
	Fecha) -- Asegúrate de que estas columnas coincidan con las columnas de tu tabla temporal
    SELECT *
    FROM OPENROWSET(
        'Microsoft.ACE.OLEDB.12.0', 
        'Text;Database=C:\Users\Public\TP Base de datos aplicada\;HDR=YES;FMT=Delimited(,)', 
        'SELECT * FROM catalogo.csv'
    );
end try
-- Ejecución del BULK INSERT dinámico
BEGIN CATCH
    PRINT 'Error en la importación de catalogo.csv';
	PRINT ERROR_MESSAGE();
	PRINT 'Numero de error:' 
	PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); -- Número de error
    PRINT 'Línea del Error: ' + CAST(ERROR_LINE() AS NVARCHAR(10)); -- Línea del error
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #Catalogo;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #Catalogo;

-------------------------------"Ventas Registradas"----------------------------

-- Crear una tabla temporal para almacenar los datos de ventas_registradas.csv
IF OBJECT_ID('tempdb..#TempVentasRegistradas') IS NOT NULL
    DROP TABLE #TempVentasRegistradas;

CREATE TABLE #TempVentasRegistradas (
    IDFactura varchar(max),
    TipoDeFactura varchar(max),
	Ciudad varchar(max),
	TipoDeCliente varchar(max),
	Genero varchar(max),
	Producto varchar(max),
	PrecioUnitario varchar(max),
    Cantidad varchar(max),
	Fecha varchar(max),
	Hora  varchar(max),
	MedioDePago varchar(max),
	Empleado varchar(max),
	IdentificadorPago varchar(max)
);
-- Asegúrate de tener habilitado Ad Hoc Distributed Queries
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

-- Declara la ruta del archivo en una variable
-- Declaración de la ruta del archivo
DECLARE @archivoC NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Ventas_registradas.csv';

-- Construcción de la sentencia dinámica para BULK INSERT
DECLARE @sql NVARCHAR(MAX);
SET @sql = N'
BULK INSERT #TempVentasRegistradas
FROM ''' + @archivoC + '''
WITH (
    CHECK_CONSTRAINTS,
    FORMAT = ''CSV'',
    CODEPAGE = ''65001'', -- UTF-8
    FIRSTROW = 2,         -- Saltar la primera fila (encabezado)
    FIELDTERMINATOR = '';'', -- Asume que los campos están separados por comas
    ROWTERMINATOR = ''\n'' -- Terminador de línea
);';

-- Ejecución del BULK INSERT dinámico
BEGIN TRY
    EXEC sp_executesql @sql;
    PRINT 'Importación de Ventas_registradas.csv completada exitosamente';
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Ventas_registradas.csv';
    PRINT ERROR_MESSAGE();
    PRINT 'Número de error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT 'Línea del error: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
END CATCH;


-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #TempVentasRegistradas;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #TempVentasRegistradas;

---------------------------------ARCHIVO EXCEL--------------------------------------

------------------------ "Información Complementaria"----------------------------------

--------------------------Sucursal------------------------------------------------------

CREATE TABLE #InformacionComplementaria (
    Ciudad NVARCHAR(50),
    ReemplazarPor NVARCHAR(50),
    Direccion NVARCHAR(255),
    Horario NVARCHAR(255),
    Telefono NVARCHAR(50)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #InformacionComplementaria
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES'',
        ''SELECT * FROM [sucursal$B:F]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Informacion_complementaria.xlsx';
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #InformacionComplementaria;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #InformacionComplementaria;

-------------------------------Empleados---------------------------------


CREATE TABLE #InformacionComplementariaEmpleados (
    ID varchar(max),
    Nombre VARCHAR(255),
    Apellido VARCHAR(255),
    DNI VARCHAR(255),
    Direccion VARCHAR(255),
	EmailPersonal  VARCHAR(255),
	EmailEmpresa VARCHAR(255),
	Cuil VARCHAR(255),
	Cargo VARCHAR(max),
	Sucursal VARCHAR(max),
	Turno VARCHAR(max)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #InformacionComplementariaEmpleados
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES'+';HDR=YES'',
        ''SELECT * FROM [Empleados$]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Informacion_complementaria.xlsx';
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #InformacionComplementariaEmpleados;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #InformacionComplementariaEmpleados;

-------------------------------Medios de Pago---------------------------------


CREATE TABLE #MediosDePago (
	Medio VARCHAR(20),
	Traduccion  VARCHAR(30)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #MediosDePago
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES' + ';HDR=YES'',
        ''SELECT * FROM [medios de pago$B:C]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Informacion_complementaria.xlsx';
	PRINT ERROR_MESSAGE()
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #MediosDePago;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #MediosDePago;

-------------------------------Clasificacion de productos---------------------------------


CREATE TABLE #ClaProdu (
	Linea VARCHAR(30),
	Producto  VARCHAR(50)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #ClaProdu
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES'',
        ''SELECT * FROM [Clasificacion productos$B:C]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Informacion_complementaria.xlsx';
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #ClaProdu;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #ClaProdu;


----------------------------------Catalogo--------------------------------------


CREATE TABLE #InfoCatalogo (
	Productos VARCHAR(50)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #InfoCatalogo
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES' + ';HDR=YES'',
        ''SELECT * FROM [catalogo$B:B]'') 
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Informacion_complementaria.xlsx';
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #InfoCatalogo;

-- Limpieza: eliminar la tabla temporal después de su uso
Drop TABLE #InfoCatalogo;


------------------------------"Productos Importados"------------------------------------

IF OBJECT_ID('tempdb..#ProductosImportados') IS NOT NULL
    DROP TABLE #ProductosImportados;

CREATE TABLE #Productosimportados (
    ProductoID INT,
	NombreProducto VARCHAR(50),
    Proveedor VARCHAR(100),
	Categoria VARCHAR(20),
	CantidadPorUnidad VARCHAR(30),
    PrecioUnidad DECIMAL(10, 2)
);

-- Procedimiento almacenado para importar datos de "Productos_importados.xlsx"
DECLARE @ProductosFilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Productos_importados.xlsx';

BEGIN TRY
    EXEC('
    INSERT INTO #ProductosImportados
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @ProductosFilePath + ';HDR=YES'',
        ''SELECT * FROM [Listado de Productos$]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de Productos_importados.xlsx';
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #Productosimportados;

-- Limpieza: eliminar la tabla temporal después de su uso
DROP TABLE #Productosimportados;

------------------------Electronic Accesories-----------------------
-- Creamos la tabla de destino si aún no existe
IF OBJECT_ID('ElectronicAccessories', 'U') IS NULL
BEGIN
    CREATE TABLE #ElectronicAccessories (
        Product NVARCHAR(255),
        UnitPriceUSD DECIMAL(10, 2)
    );
END

-- Importar datos desde el archivo Excel
DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Electronic accessories.xlsx';

/*EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;*/

BEGIN TRY
    EXEC('
    INSERT INTO #ElectronicAccessories
    SELECT *
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;Database=' + @FilePath + ';HDR=YES'',
        ''SELECT * FROM [Sheet1$B:C]'')
    ');
END TRY
BEGIN CATCH
    PRINT 'Error en la importación de ElectronicAccessories.xlsx';
END CATCH;







-- Procedimientos para verificar la carga de datos

SELECT * FROM #InformacionComplementaria
SELECT * FROM ##Catalogo
SELECT * FROM #ProductosImportados
SELECT * FROM #TempVentasRegistradas
SELECT * FROM #ElectronicAccessories

-- Limpieza (si es necesario)
-- DROP TABLE #InformacionComplementaria
-- DROP TABLE #Catalogo
-- DROP TABLE #ProductosImportados
-- DROP TABLE #VentasRegistradas
