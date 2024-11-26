/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Gabriel Osorio (43035245)

Enunciado: Entrega 4
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


-- Opciones necesarias para utilizar OPENROWSET para importar los archivos
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

USE Com2900G04;
go

----------------------------------SP Importacion CSV-----------------------------------------------------

----------------------------------catalogo.csv-------------------------------

sp_configure 'show advanced options', 1;
RECONFIGURE;
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;



CREATE OR ALTER PROCEDURE op.importarCatalogo
	@ruta varchar(1000)
AS
BEGIN
	BEGIN TRY
		CREATE TABLE #catalogo (
		    id VARCHAR(max),
			categoria VARCHAR(max),
		    nombre VARCHAR(max),
		    precio VARCHAR(max),
		    precio_referencia VARCHAR(max),
			unidad_referencia VARCHAR(max),
			fecha VARCHAR(max)
		);
		
		DECLARE @sql NVARCHAR(MAX) = N'
		    BULK INSERT #catalogo
		    FROM ''' + @ruta + ''' 
		    WITH (
		        FIELDTERMINATOR = '','', -- Delimitador de campos
		        ROWTERMINATOR = ''\n'',  -- Fin de línea
		        FIRSTROW = 2           -- Omitir encabezado
		    );'

		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de catalogo.csv' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO op.producto (nombre, categoria, precio, fecha)
	SELECT c.nombre, cp.linea_producto AS categoria, CAST(ROUND(c.precio, 2) AS decimal(10,2)) AS precio, c.fecha
	FROM #catalogo AS c
	LEFT JOIN op.clasificacionProducto AS cp
	ON cp.producto = c.categoria;
	
	DROP TABLE #catalogo;
END;
go

/*SELECT * FROM OPENROWSET(
		        'Microsoft.ACE.OLEDB.12.0', 
		        'Text;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\;HDR=YES;FMT=Delimited(,)', 
		        'SELECT * FROM catalogo.csv'
		    );*/

-------------------------------"Ventas Registradas"----------------------------

CREATE OR ALTER PROCEDURE op.importarVentasRegistradas
	@ruta varchar(1000)
AS
BEGIN
	BEGIN TRY
		CREATE TABLE #ventasRegistradas (
			id_factura varchar(20),
			tipo_factura varchar(5),
			ciudad varchar(20),
			tipo_cliente varchar(20),
			genero varchar(20),
			producto varchar(1000),
			precio_unitario varchar(10),
			cantidad varchar(10),
			fecha varchar(20),
			hora varchar(10),
			medio_pago varchar(20),
			empleado varchar(10),
			identificador_pago varchar(50)
		);

		DECLARE @sql NVARCHAR(MAX) = N'
		    BULK INSERT #ventasRegistradas
		    FROM ''' + @ruta + ''' 
		    WITH (
		        FIELDTERMINATOR = '';'', -- Delimitador de campos
		        ROWTERMINATOR = ''\n'',  -- Fin de línea
		        FIRSTROW = 2           -- Omitir encabezado
		    );'

	    EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de Ventas_registradas.csv' + ERROR_MESSAGE();
	END CATCH;

	-- Insertar en op.venta
	INSERT INTO op.venta (id_sucursal, tipo_cliente, fecha, hora, id_empleado)
    SELECT s.id AS id_sucursal, CAST(tipo_cliente AS char(6)),
			CAST(vr.fecha AS date), CAST(vr.hora AS time), CAST(vr.empleado AS int)
    FROM #ventasRegistradas AS vr
	JOIN rrhh.sucursal AS s ON vr.ciudad = s.ciudad;

	-- Insertar en op.detalleVenta
    INSERT INTO op.detalleVenta (id_venta, id_producto, cantidad, precio_unitario)
    SELECT 
        (SELECT id FROM op.venta 
         WHERE id_empleado = vr.empleado 
           AND fecha = vr.fecha 
           AND hora = vr.hora) AS id_venta,
        p.id AS id_producto, 
        CAST(vr.cantidad AS int), 
        CAST(vr.precio_unitario AS decimal(10,2))
    FROM #ventasRegistradas vr
    JOIN op.producto p ON p.nombre = vr.producto;

	--- Insertar en op.factura solo si no existe un registro con la misma clave primaria (id_factura)
INSERT INTO op.factura (id, tipo_factura, id_venta, total_sin_IVA, cuit, estado)
SELECT 
    CAST(vr.id_factura AS char(11)), 
    CAST(vr.tipo_factura AS char(1)),
    v.id AS id_venta,
    CAST(vr.cantidad AS int) * CAST(vr.precio_unitario AS decimal(10,2)) AS total_sin_IVA,
    (SELECT TOP 1 cuit FROM rrhh.super) AS cuit, 
    'Pagada' AS estado
FROM #ventasRegistradas vr
JOIN op.venta v 
    ON v.id_empleado = vr.empleado 
    AND v.fecha = vr.fecha 
    AND v.hora = vr.hora
WHERE NOT EXISTS (
    SELECT 1 
    FROM op.factura 
    WHERE id = CAST(vr.id_factura AS char(11))  
);

-- Insertar en op.pago solo si no existe un registro con la misma clave primaria
INSERT INTO op.pago (id, id_factura, id_medio_pago, monto, fecha, hora)
SELECT 
    vr.identificador_pago, 
    vr.id_factura, 
    mp.id AS id_medio_pago,
    CAST(vr.cantidad AS int) * CAST(vr.precio_unitario AS decimal(10,2)) AS monto, 
    vr.fecha, 
    vr.hora
FROM #ventasRegistradas vr
JOIN op.medioPago mp ON mp.medio = vr.medio_pago
WHERE NOT EXISTS (
    SELECT 1 
    FROM op.pago 
    WHERE id = vr.identificador_pago
);

    

	DROP TABLE #ventasRegistradas;
END;

EXEC op.importarVentasRegistradas @ruta = N'C:\Users\brand\OneDrive\Escritorio\TP Base de datos aplicada\TP_integrador_Archivos\Ventas_registradas.csv';
go



/*CREATE TABLE #ventasRegistradas (
			id varchar(max),
			tipo_factura varchar(max),
			ciudad varchar(max),
			tipo_cliente varchar(max),
			genero varchar(max),
			producto varchar(max),
			precio_unitario varchar(max),
			cantidad varchar(max),
			fecha varchar(max),
			hora varchar(max),
			medio_pago varchar(max),
			empleado varchar(max),
			identificador_pago varchar(max)
		);
go

BULK INSERT #ventasRegistradas
			FROM 'C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Ventas_registradas.csv'
			WITH (
			    CHECK_CONSTRAINTS,
			    FORMAT = 'CSV',
			    CODEPAGE = '65001', -- UTF-8
			    FIRSTROW = 2,
			    FIELDTERMINATOR = ';',
			    ROWTERMINATOR = '\n'
			);
go

select * from #ventasRegistradas;
go

drop table #ventasRegistradas;
go*/

-- Habilitar configuraciones avanzadas
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

---------------------------------ARCHIVO EXCEL--------------------------------------

------------------------Información Complementaria----------------------------------

--------------------------Sucursal------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.importarSucursales
    @ruta VARCHAR(1000)
AS
BEGIN    
    BEGIN TRY
		CREATE TABLE #informacionComplementariaSucursal (
		    ciudad VARCHAR(50),
		    reemplazar_por VARCHAR(50),
		    direccion VARCHAR(500),
		    horario VARCHAR(100),
		    telefono VARCHAR(50)
		);

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        INSERT INTO #informacionComplementariaSucursal
        SELECT * FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
            ''SELECT * FROM [sucursal$B:F]''
        );';

        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'Error en la importación de Informacion_complementaria.xlsx: ' + ERROR_MESSAGE();
    END CATCH;

	INSERT INTO rrhh.sucursal(ciudad, reemplazar_por, direccion, horario, telefono)
	SELECT ciudad, reemplazar_por, direccion, horario, telefono
	FROM #informacionComplementariaSucursal;

    DROP TABLE #informacionComplementariaSucursal;
END;
go

/*SELECT * FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.12.0', 
            'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
            'SELECT * FROM [Sucursal$B2:F]'
        );*/

-------------------------------Empleados---------------------------------

CREATE OR ALTER PROCEDURE rrhh.importarEmpleados
    @ruta VARCHAR(1000)
AS
BEGIN	
	BEGIN TRY
		CREATE TABLE #informacionComplementariaEmpleado (
		    legajo varchar(50),
		    nombre VARCHAR(100),
		    apellido VARCHAR(100),
		    dni VARCHAR(50),
		    direccion VARCHAR(500),
			email_personal VARCHAR(500),
			email_empresa VARCHAR(500),
			cuil VARCHAR(50),
			cargo VARCHAR(50),
			sucursal VARCHAR(50),
			turno VARCHAR(50)
		);

	    DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
	    INSERT INTO #informacionComplementariaEmpleado
	    SELECT * FROM OPENROWSET(
	        ''Microsoft.ACE.OLEDB.12.0'', 
	        ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
	        ''SELECT * FROM [Empleados$]''
	    );';
		
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de Informacion_complementaria.xlsx: ' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO rrhh.empleado(legajo, nombre, apellido, dni, direccion, email_personal, email_empresa, cuil, cargo, id_sucursal, turno)
	SELECT CAST(e.legajo AS INT) AS legajo, e.nombre, e.apellido, CAST(CAST(e.dni AS float) AS int) AS dni, e.direccion, e.email_personal,
			e.email_empresa, func.generarCUIL(CAST(CAST(e.dni AS float) AS int), NEWID()) AS cuil, e.cargo, s.id AS id_sucursal, e.turno
	FROM #informacionComplementariaEmpleado AS e
	JOIN rrhh.sucursal AS s ON e.sucursal = s.reemplazar_por;
	--WHERE e.legajo <> null;
	
	DROP TABLE #informacionComplementariaEmpleado;
END;
go

/*SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [Empleados$]'
	    );*/

-------------------------------Medios de Pago---------------------------------

CREATE OR ALTER PROCEDURE op.importarMediosPago
	@ruta VARCHAR(1000)
AS
BEGIN
	BEGIN TRY
		CREATE TABLE #informacionComplementariaMedioPago (
			medio VARCHAR(20),
			traduccion  VARCHAR(30)
		);

	    DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
	    INSERT INTO #informacionComplementariaMedioPago
	    SELECT * FROM OPENROWSET(
	        ''Microsoft.ACE.OLEDB.12.0'', 
	        ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
	        ''SELECT * FROM [medios de pago$B:C]''
	    );';

		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de Informacion_complementaria.xlsx' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO op.medioPago (medio, traduccion)
	SELECT medio, traduccion
	FROM #informacionComplementariaMedioPago;
	
	DROP TABLE #informacionComplementariaMedioPago;
END;
go

/*SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [medios de pago$B:C]'
	    );*/

-------------------------------Clasificacion de productos---------------------------------

CREATE OR ALTER PROCEDURE op.importarClasificacionProducto
	@ruta VARCHAR(1000)
AS
BEGIN	
	BEGIN TRY
		CREATE TABLE #informacionComplementariaClaProdu (
			linea_producto VARCHAR(30),
			producto VARCHAR(50)
		);

	    DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
	    INSERT INTO #informacionComplementariaClaProdu
	    SELECT * FROM OPENROWSET(
	        ''Microsoft.ACE.OLEDB.12.0'', 
	        ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
	        ''SELECT * FROM [Clasificacion productos$B:C]''
	    );';

		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de Informacion_complementaria.xlsx' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO op.clasificacionProducto (linea_producto, producto)
	SELECT linea_producto, producto
	FROM #informacionComplementariaClaProdu;
	
	DROP TABLE #informacionComplementariaClaProdu;
END;
go

/*SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [Clasificacion productos$B:C]'
	    );*/

----------------------------------Catalogo--------------------------------------


/*CREATE TABLE #InfoCatalogo (
	Productos VARCHAR(50)
);

-- Procedimiento almacenado para importar datos de "Informacion_complementaria.xlsx"

DECLARE @FilePath NVARCHAR(255) = 'C:\Users\Public\TP Base de datos aplicada\Informacion_complementaria.xlsx';

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

SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [catalogo$B:B]'
	    );*/





------------------------------"Productos Importados"------------------------------------


CREATE OR ALTER PROCEDURE op.importarProductosImportados
	@ruta varchar(1000)
AS
BEGIN	
	BEGIN TRY
		CREATE TABLE #productosImportados (
			id_producto varchar(5),
			nombre VARCHAR(50),
		    proveedor VARCHAR(100),
			categoria VARCHAR(20),
			cantidad_unidad VARCHAR(30),
		    precio_unidad VARCHAR(10)
		);

	    DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
	    INSERT INTO #productosImportados
	    SELECT *
	    FROM OPENROWSET(
	        ''Microsoft.ACE.OLEDB.12.0'', 
	        ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
	        ''SELECT * FROM [Listado de Productos$]''
	    );';

		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de Productos_importados.xlsx' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO op.producto (nombre, categoria, precio, cantidad_unidad, proveedor)
	SELECT nombre, categoria, CAST(precio_unidad AS decimal(10,2)) AS precio, cantidad_unidad, proveedor
	FROM #productosImportados;

	DROP TABLE #productosimportados;
END;
go

/*SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\Productos_importados.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [Listado de Productos$]'
	    );*/

------------------------Electronic Accesories-----------------------

CREATE OR ALTER PROCEDURE op.importarElectronicAccessories
	@ruta VARCHAR(1000)
AS
BEGIN
	BEGIN TRY
		CREATE TABLE #electronicAccessories (
		    nombre VARCHAR(100),
		    precio_dolares VARCHAR(10)
		);

		DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
	    INSERT INTO #electronicAccessories
	    SELECT *
	    FROM OPENROWSET(
	        ''Microsoft.ACE.OLEDB.12.0'', 
	        ''Excel 12.0;Database=' + @ruta + N';HDR=YES'',
	        ''SELECT * FROM [Sheet1$B:C]''
	    );';

		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
	    PRINT 'Error en la importación de ElectronicAccessories.xlsx' + ERROR_MESSAGE();
	END CATCH;

	INSERT INTO op.producto (nombre, categoria, precio, precio_dolares)
	SELECT ea.nombre, 'Electronic Accesories' AS categoria,
			func.convertirDolaresAPesos(CAST(precio_dolares AS decimal(18,2))) AS precio,
			ea.precio_dolares
	FROM #electronicAccessories AS ea
	WHERE NOT EXISTS (
		SELECT 1
		FROM op.producto AS p
		WHERE p.nombre = ea.nombre
	);

	DROP TABLE #electronicAccessories;
END;
go

/*SELECT * FROM OPENROWSET(
	        'Microsoft.ACE.OLEDB.12.0', 
	        'Excel 12.0;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\Electronic accessories.xlsx;HDR=YES;HDR=YES',
	        'SELECT * FROM [Sheet1$B:C]'
	    );*/
