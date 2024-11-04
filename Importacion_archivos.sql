/* Materia: Base de datos aplicada
Fecha de entrega: 05/11/2024
Grupo: 4
Nombres y DNI: Melani Antonella Morales Castillo(42242365).
				Tomas Osorio (43035245)
				Pablo Mela(41027430)

Enunciado:Entrega 4
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

-- Selecci�n de la base de datos creada anteriormente
use AuroraDB;
go

-- Creaci�n de las tablas temporales para la importaci�n de los archivos
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

create table catalogo (
	id varchar(10) not null,
	categoria varchar(50) not null,
	nombre varchar(200) not null,
	precio varchar(20) not null,
	precio_referencia varchar(10) not null,
	unidad_referencia varchar(10) not null,
	fecha varchar(50),
	constraint PK_catalogo primary key (id)
);
go

drop table catalogo
go
/*
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

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
go
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
go

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
go
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
go

create or alter procedure importarCatalogo
as
begin
	INSERT INTO catalogo (id, categoria, nombre, precio, precio_referencia, unidad_referencia, fecha)
	SELECT *
	FROM OPENROWSET(
		'Microsoft.ACE.OLEDB.12.0', 
		'Text;Database=C:\Users\Tomas Osorio\Desktop\TP_integrador_Archivos\Productos\;HDR=YES;FMT=Delimited', 
		'SELECT * FROM catalogo.csv'
	);
end

exec importarCatalogo;
go

select top 20 * from dbo.catalogo
go