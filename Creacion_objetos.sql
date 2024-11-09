/*
Materia: Base de datos Aplicada
Fecha de entrega: 12/11/2024
Grupo: 4
Nombre y DNI: Melani Antonella Morales Castillo (42242365)
				Tomas Gabriel Osorio (43035245)

Enunciado: Entrega 3
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store PROCEDUREs para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store PROCEDUREs NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/


----------------------Base de datos y esquemas-------------------
-- Crear la base de datos
CREATE DATABASE AuroraDB;
GO

-- Usar la base de datos recién creada
USE AuroraDB;
GO

-- Crear esquemas
CREATE SCHEMA rrhh;
GO

CREATE SCHEMA op;
GO


-------------------Tablas----------------
CREATE TABLE rrhh.sucursal (
	id int identity(1,1) not null,
	ciudad varchar(30) not null,
	reemplazo varchar(30) not null, -- que seria?
	direccion varchar(100) not null,
	horario varchar(50) not null, -- ej: L a V 8 a. m.-9 p. m. S y D 9 a. m.-8 p. m.
	telefono varchar(18) not null, -- ej: +54 9 11 2222-3333
	baja bit default 0, -- borrado logico
	constraint PK_sucursal primary key (id)
);
go

CREATE TABLE rrhh.empleado (
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
go

CREATE TABLE op.medioPago (
	id int identity(1,1) not null,
	valor varchar(11) not null, -- ej: credit card ???
	descripcion varchar(21) not null, -- ej: billetera electronica
	baja bit default 0, -- borrado logico
	constraint PK_medioPago primary key (id)
);
go

CREATE TABLE op.categoria (
	id int identity(1,1) not null,
	descripcion varchar(30) not null,
	borrado bit default 0, -- borrado logico
	constraint PK_categoria primary key (id)
);
go

CREATE TABLE op.proveedor (
	id int identity(1,1) not null,
	nombre varchar(50) not null,
	baja bit default 0, -- borrado logico
	constraint PK_proveedor primary key (id)
);
go

CREATE TABLE op.producto (
	id int identity(1,1) not null,
	nombre varchar(50) not null,
	id_categoria int not null,
	precio decimal(5,2) not null, -- ???
	precio_referencia decimal(5,2) not null,
	unidad_referencia varchar(6) not null, -- ej: 100 ml
	cantidad_unidad varchar(20) not null,
	precio_dolares decimal(6,2) not null,
	id_proveedor int not null,
	fecha smalldatetime default getdate(), -- fecha y hora actual
	baja bit default 0, -- borrado logico
	constraint PK_productos primary key (id),
	constraint FK_categoria foreign key
	(id_categoria) references op.categoria(id),
	constraint FK_proveedor foreign key
	(id_proveedor) references op.proveedor(id)
);
go

CREATE TABLE op.venta (
	id char(11) primary key,
	tipo_factura char(1) not null,
	id_sucursal int not null,
	tipo_cliente char(1) not null, -- M o N (Member o Normal)
	genero char(1) not null, -- F o M (female o male)
	id_producto int not null,
	cantidad int not null,
	fecha smalldatetime not null,
	id_medio_pago int not null,
	legajo_empleado int not null,
	identificador_pago varchar(23), -- ej: '0000003100099475144530
	cancelado bit default 0, -- cancelacion venta
	constraint PK_venta primary key (id),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_producto foreign key
	(id_producto) references op.productos(id),
	constraint FK_medio_pago foreign key
	(id_medio_pago) references op.medioPago(id),
);
go

CREATE TABLE op.detalleVenta (
	id int identity(1,1) not null,
	id_venta char(11) not null,
	id_producto int not null,
	cantidad int not null,
	precio_unitario decimal(5,2) not null,
	precio_total decimal(6,2) as (cantidad * precio_unitario) persisted, -- cálculo automático
	constraint PK_detalle_venta primary key (id),
	constraint FK_venta foreign key (id_venta) references op.ventas(id),
	constraint FK_producto foreign key (id_producto) references op.productos(id)
);
go

CREATE TABLE op.factura (
	id char(12),
	fecha smalldatetime default getdate(),
	tipo_factura char(1) not null, -- A, B, C, etc.
	total decimal(10,2) not null,
	id_venta char(11) not null,
	constraint PK_factura primary key (id_factura),
	constraint FK_factura_venta foreign key (id_venta) references op.ventas(id)
);
go

CREATE TABLE op.detalleFactura (
	id int identity(1,1) not null,
	id_factura char(12) not null,
	id_producto int not null,
	cantidad int not null,
	precio_unitario decimal(5,2) not null,
	precio_total decimal(6,2) as (cantidad * precio_unitario) persisted,
	constraint PK_detalle_factura primary key (id),
	constraint FK_factura foreign key (id_factura) references op.factura(id),
	constraint FK_producto_factura foreign key (id_producto) references op.productos(id)
);
go