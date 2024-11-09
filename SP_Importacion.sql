/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Gabriel Osorio (43035245)

Enunciado: Entrega 4
Se requiere que importe toda la informaci�n antes mencionada a la base de datos:
� Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibir�n archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
� Considere este comportamiento al generar el c�digo. Debe admitir la importaci�n de
novedades peri�dicamente.
� Cada maestro debe importarse con un SP distinto. No se aceptar�n scripts que
realicen tareas por fuera de un SP.
� La estructura/esquema de las tablas a generar ser� decisi�n suya. Puede que deba
realizar procesos de transformaci�n sobre los maestros recibidos para adaptarlos a la
estructura requerida.
� Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, err�neos, etc., deber� contemplarlo y realizar las correcciones
en el fuente SQL. (Ser�a una excepci�n si el archivo est� malformado y no es posible
interpretarlo como JSON o CSV). 
*/

use AuroraDB;
go

/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Osorio (43035245)

Enunciado: Entrega 4
Se requiere que importe toda la informaci�n antes mencionada a la base de datos:
� Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibir�n archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
� Considere este comportamiento al generar el c�digo. Debe admitir la importaci�n de
novedades peri�dicamente.
� Cada maestro debe importarse con un SP distinto. No se aceptar�n scripts que
realicen tareas por fuera de un SP.
� La estructura/esquema de las tablas a generar ser� decisi�n suya. Puede que deba
realizar procesos de transformaci�n sobre los maestros recibidos para adaptarlos a la
estructura requerida.
� Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, err�neos, etc., deber� contemplarlo y realizar las correcciones
en el fuente SQL. (Ser�a una excepci�n si el archivo est� malformado y no es posible
interpretarlo como JSON o CSV). 
*/

-- Configuraremos tablas temporales y procedimientos almacenados para importar los datos.

----------------------------------ARCHIVO CSV-----------------------------------------------------

----------------------------------"Cat�logo"-------------------------------

use AuroraDB
go

-- Crear una tabla temporal para almacenar los datos de catalogo.csv
CREATE TABLE #Catalogo (
    ProductoID INT,
	Categoria NVARCHAR(1000),
    Nombre NVARCHAR(1000),
    Precio DECIMAL(10, 2),
    PrecioReferencia DECIMAL(10, 2),
	Unidad CHAR(2),
	Fecha DATETIME2
);

DECLARE @archivoC NVARCHAR(255) = 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\catalogo.csv';
DECLARE @sql NVARCHAR(MAX);

-- Construcci�n de la sentencia din�mica para BULK INSERT
SET @sql = N'
BULK INSERT #Catalogo
FROM ''' + @archivoC + '''
WITH (
    CHECK_CONSTRAINTS,
    FORMAT = ''CSV'',
    CODEPAGE = ''65001'', -- UTF-8
    FIRSTROW = 2,         -- Saltar la primera fila (encabezado)
    FIELDTERMINATOR = '','', 
    ROWTERMINATOR = ''\n''
);';

-- Ejecuci�n del BULK INSERT din�mico
BEGIN TRY
    EXEC sp_executesql @sql;
    PRINT 'Importaci�n de catalogo.csv completada exitosamente';
END TRY
BEGIN CATCH
    PRINT 'Error en la importaci�n de catalogo.csv';
	PRINT ERROR_MESSAGE();
	PRINT 'Numero de error:' 
	PRINT 'N�mero de Error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); -- N�mero de error
    PRINT 'L�nea del Error: ' + CAST(ERROR_LINE() AS NVARCHAR(10)); -- L�nea del error
END CATCH;

-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #Catalogo;

-- Limpieza: eliminar la tabla temporal despu�s de su uso
DROP TABLE #Catalogo;

-------------------------------"Ventas Registradas"----------------------------

-- Crear una tabla temporal para almacenar los datos de ventas_registradas.csv
IF OBJECT_ID('tempdb..#TempVentasRegistradas') IS NOT NULL
    DROP TABLE #TempVentasRegistradas;

CREATE TABLE #TempVentasRegistradas (
    IDFactura char(11),
    TipoDeFactura INT,
	Ciudad varchar(20),
	TipoDeCliente varchar(10),
	Genero varchar(10),
	Producto varchar(50),
	PrecioUnitario decimal(10,2),
    Cantidad int,
	Fecha date,
	Hora  time,
	MedioDePago varchar(20),
	Empleado int,
	IdentificadorPago varchar(25)
);

-- Declara la ruta del archivo en una variable
DECLARE @archivoV NVARCHAR(255) = 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Ventas_registradas.csv';

-- Definici�n de la consulta din�mica para insertar datos en una tabla temporal
DECLARE @sql NVARCHAR(MAX) = N'
    BULK INSERT #TempVentasRegistradas
    FROM ''' + @archivoV + '''
    WITH (
        FORMAT = ''CSV'', 
        FIELDTERMINATOR = '','', 
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'', 
        FIRSTROW = 2
    );';

-- Ejecutar la consulta din�mica
BEGIN TRY
    EXEC sp_executesql @sql;
END TRY
BEGIN CATCH
    PRINT 'Error en la importaci�n de ventas_registradas.csv';
    PRINT ERROR_MESSAGE();
END CATCH;
-- Opcional: Visualizar los datos importados (para verificar)
SELECT * FROM #TempVentasRegistradas;

-- Limpieza: eliminar la tabla temporal despu�s de su uso
DROP TABLE #TempVentasRegistradas;

---------------------------------ARCHIVO EXCEL--------------------------------------

------------------------ "Informaci�n Complementaria"----------------------------------

use AuroraDB;
go

CREATE TABLE #InformacionComplementaria (
    Ciudad NVARCHAR(50),
    ReemplazarPor NVARCHAR(50),
    Direccion NVARCHAR(255),
    Horario NVARCHAR(255),
    Telefono NVARCHAR(50)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx';

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
    PRINT 'Error en la importaci�n de Informacion_complementaria.xlsx';
END CATCH;

-- Procedimiento almacenado para importar datos de "Productos_importados.xlsx"
DECLARE @ProductosFilePath NVARCHAR(255) = 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\Productos_importados.xlsx';

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
    PRINT 'Error en la importaci�n de Productos_importados.xlsx';
END CATCH;

------------------------Electronic Accesories-----------------------
-- Creamos la tabla de destino si a�n no existe
IF OBJECT_ID('ElectronicAccessories', 'U') IS NULL
BEGIN
    CREATE TABLE #ElectronicAccessories (
        Producto NVARCHAR(255),
        PrecioUSD DECIMAL(10, 2)
    );
END

-- Importar datos desde el archivo Excel
INSERT INTO #ElectronicAccessories (Producto, PrecioUSD)
SELECT Producto, PrecioUSD
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0', 
    'Excel 12.0;Database="C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\Electronic accessories.xlsx";HDR=YES',
    'SELECT * FROM [Sheet1$]'
);






-- Procedimientos para verificar la carga de datos

SELECT * FROM #InformacionComplementaria
SELECT * FROM ##Catalogo
SELECT * FROM #ProductosImportados
SELECT * FROM #TempVentasRegistradas

-- Limpieza (si es necesario)
-- DROP TABLE #InformacionComplementaria
-- DROP TABLE #Catalogo
-- DROP TABLE #ProductosImportados
-- DROP TABLE #VentasRegistradas