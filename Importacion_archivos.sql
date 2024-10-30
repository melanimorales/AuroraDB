/* Materia: Base de datos aplicada
Fecha de entrega: 12/11/2024
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
	cantidad_unidad varchar(20) not null, /*10 cajas x 12 piezas*/
	precio_unidad decimal(5,2) not null /*123,79*/
);
go

create table #producto_electronico (
	id int identity(1,1) primary key,
	nombre varchar(50) not null,
	precio_dolares decimal(6,2) not null /*1700,00*/
);
go

create table #catalogo (
	id int identity(1,1) primary key,
	id_categoria int not null,
	nombre varchar(50) not null,
	precio decimal(5,2) not null,
	precio_referencia decimal(5,2) not null,
	unidad_referencia varchar(6) not null, /*100 ml*/
	fecha smalldatetime default getdate(),
	constraint FK_categoria foreign key
	(id_categoria) references op.categoria(id)
);
go