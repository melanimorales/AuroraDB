/* Materia: Base de datos aplicada
Fecha de entrega: 05/11/2024
Grupo: 4
Nombres y DNI: Melani Antonella Morales Castillo(42242365).
				Tomas Osorio (43035245)
				Pablo Mela(41027430)

Enunciado:Entrega 3
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la
base de datos.
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
*/

-- Creación de la base de datos
create database AuroraDB;
go

-- Selección de la base de datos creada
use AuroraDB;
go

-- Creación de los esquemas
create schema rrhh;
go

create schema op;
go

-- Creación de las tablas
create table rrhh.sucursal (
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

create table rrhh.empleado (
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

create table op.medioPago (
	id int identity(1,1) not null,
	valor varchar(11) not null, -- ej: credit card ???
	descripcion varchar(21) not null, -- ej: billetera electronica
	baja bit default 0, -- borrado logico
	constraint PK_medioPago primary key (id)
);
go

create table op.categoria (
	id int identity(1,1) not null,
	descripcion varchar(30) not null,
	borrado bit default 0, -- borrado logico
	constraint PK_categoria primary key (id)
);
go

create table op.proveedor (
	id int identity(1,1) not null,
	nombre varchar(50) not null,
	baja bit default 0, -- borrado logico
	constraint PK_proveedor primary key (id)
);
go

create table op.productos (
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

create table op.ventas (
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
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_producto foreign key
	(id_producto) references op.productos(id),
	constraint FK_medio_pago foreign key
	(id_medio_pago) references op.medioPago(id),
);
go

/* Borrado fisico
create or alter procedure op.borrarCategoria
	@id int
as
begin
	set nocount on;
	delete from op.categoria where id = @id;
end;
go
*/

-- SP de inserción, modificación y borrado de las tablas}

/*----------------SP sucursal-----------------*/

-- Ingreso de sucursal
create or alter procedure rrhh.ingresarSucursal
	@ciudad varchar(30),
	@reemplazo varchar(30) = null,
	@direccion varchar(100),
	@horario varchar(50),
	@telefono varchar(18)
as
begin
	set nocount on;
	insert into rrhh.sucursal (ciudad, reemplazo, direccion, horario, telefono)
	values (@ciudad, @reemplazo, @direccion, @horario, @telefono);
end;
go

-- Modificacion de sucursal
create or alter procedure rrhh.modificarSucursal
	@id int,
	@ciudad varchar(30) = null,
	@reemplazo varchar(30) = null,
	@direccion varchar(100) = null,
	@horario varchar(50) = null,
	@telefono varchar(18) = null
as
begin
	set nocount on;
	update rrhh.sucursal set
		ciudad = coalesce(@ciudad, ciudad),
		reemplazo = coalesce(@reemplazo, reemplazo),
		direccion = coalesce(@direccion, direccion),
		horario = coalesce(@horario, horario),
		telefono = coalesce(@telefono, telefono)
	where id = @id;
end;
go

-- Baja de sucursal
create or alter procedure rrhh.borrarSucursal
	@id int
as
begin
	set nocount on;
	update rrhh.sucursal set
		baja = 1
	where id = @id;
end;
go

/*----------------SP Empleados----------------*/

-- Ingreso de empleado
create or alter procedure rrhh.ingresarEmpleado
	@legajo int,
	@nombre varchar(30),
	@apellido varchar(30),
	@dni int,
	@direccion varchar(100),
	@email_laboral varchar(50),
	@cuil char(13),
	@cargo varchar(20),
	@id_sucursal int,
	@turno varchar(16)
as
begin
	set nocount on;
	insert into rrhh.empleado (legajo, nombre, apellido, dni, direccion, email_laboral, cuil, cargo, id_sucursal, turno)
	values (@legajo, @nombre, @apellido, @dni, @direccion, @email_laboral, @cuil, @cargo, @id_sucursal, @turno);
end;
go

-- Modificacion de empleado
create or alter procedure rrhh.modificarEmpleado
	@legajo int,
	@nombre varchar(30),
	@apellido varchar(30),
	@dni int,
	@direccion varchar(100),
	@email_laboral varchar(50),
	@cuil char(13),
	@cargo varchar(20),
	@id_sucursal int,
	@turno varchar(16)
as
begin
	set nocount on;
	update rrhh.empleado set
		nombre = coalesce(@nombre, nombre)
		apellido = coalesce(@apellido, apellido),
		dni = coalesce(@dni, dni),
		direccion = coalesce(@direccion, direccion),
		email_laboral = coalesce(@email_laboral, email_laboral),
		cuil = coalesce(@cuil, cuil),
		cargo = coalesce(@cargo, cargo),
		id_sucursal = coalesce(@id_sucursal, id_sucursal),
		turno = coalesce(@turno, turno)
	where legajo = @legajo;
end;
go

-- Baja de empleado
create or alter procedure rrhh.borrarEmpleado
	@legajo int
as
begin
	set nocount on;
	update rrhh.empleado set
		baja = 1
	where legajo = @legajo;
end;
go

/*----------------Medio de pago----------------*/

-- Ingreso de medio de pago
create or alter procedure op.ingresarMedioPago
	@valor varchar(11),
	@descripcion varchar(21)
as
begin
	set nocount on;
	insert into op.medioPago (valor, descripcion)
	values (@valor, @descripcion);
end;
go

-- Modificacion de medio de pago
create or alter procedure op.modificarMedioPago
	@id int,
	@valor varchar(11) = null,
	@descripcion varchar(21) = null
as
begin
	set nocount on;
	update op.medioPago set
		valor = coalesce(@valor, valor),
		descripcion = coalesce(@descripcion, descripcion)
	where id = @id;
end;
go

-- Baja de medio de pago
create or alter procedure op.borrarMedioPago
	@id int
as
begin
	set nocount on;
	update op.medioPago set
		baja = 1
	where id = @id;
end;
go

/*---------------Categoría---------------*/

-- Ingreso de categoria
create or alter procedure op.ingresarCategoria
	@descripcion varchar(30)
as
begin
	set nocount on;
	insert into op.categoria (descripcion)
	values (@descripcion);
end;
go

-- Modificacion de categoria
create or alter procedure op.modificarCategoria
	@id int,
	@descripcion varchar(30) = null
as
begin
	set nocount on;
	update op.categoria set
		descripcion = coalesce(@descripcion, descripcion)
	where id = @id;
end;
go

-- Borrado de categoria
create or alter procedure op.borrarCategoria
	@id int
as
begin
	set nocount on;
	update op.categoria set
		borrado = 1
	where id = @id;
end;
go

/*---------------Proveedor---------------*/

-- Ingreso de proveedor
create or alter procedure op.ingresarProveedor
	@nombre varchar(50)
as
begin
	set nocount on;
	insert into op.proveedor (nombre)
	values (@nombre);
end;
go

-- Modificacion de proveedor
create or alter procedure op.modificarProveedor
	@id int,
	@nombre varchar(50) = null
as
begin
	set nocount on;
	update op.proveedor set
		nombre = coalesce(@nombre, nombre)
	where id = @id;
end;
go

-- Baja de proveedor
create or alter procedure op.borrarProveedor
	@id int
as
begin
	set nocount on;
	update op.proveedor set
		baja = 1
	where id = @id;
end;
go

/*---------------Productos---------------*/

-- Ingreso de producto
CREATE OR ALTER PROCEDURE op.ingresarProducto
    @nombre varchar(50),
	@id_categoria int,
	@precio decimal(5,2),
	@precio_referencia decimal(5,2),
	@unidad_referencia varchar(6),
	@cantidad_unidad varchar(20),
	@precio_dolares decimal(6,2),
	@id_proveedor int
AS
BEGIN
    INSERT INTO op.productos (nombre, id_categoria, precio, precio_referencia, unidad_referencia, cantidad_unidad, precio_dolares, id_proveedor)
    VALUES (@nombre, @id_categoria, @precio, @precio_referencia, @unidad_referencia, @cantidad_unidad, @precio_dolares, @id_proveedor);
END;
GO

-- Modificacion de productos
CREATE OR ALTER PROCEDURE op.modificarProducto
	@id int,
    @nombre varchar(50) = null,
	@id_categoria int = null,
	@precio decimal(5,2) = null,
	@precio_referencia decimal(5,2) = null,
	@unidad_referencia varchar(6) = null,
	@cantidad_unidad varchar(20) = null,
	@precio_dolares decimal(6,2) = null,
	@id_proveedor int = null
AS
BEGIN
    UPDATE op.productos
    SET 
        nombre = COALESCE(@nombre, nombre),
        id_categoria = COALESCE(@id_categoria, id_categoria),
        precio = COALESCE(@precio, precio),
        precio_referencia = COALESCE(@precio_referencia, precio_referencia),
		unidad_referencia = COALESCE(@unidad_referencia, unidad_referencia),
		cantidad_unidad = COALESCE(@cantidad_unidad, cantidad_unidad),
		precio_dolares = COALESCE(@precio_dolares, precio_dolares),
		id_proveedor = COALESCE(@id_proveedor, id_proveedor)
    WHERE id = @id;
END;
GO

-- Baja de producto
CREATE OR ALTER PROCEDURE op.borrarProducto
    @id INT
AS
BEGIN
	set nocount on;
    update op.productos set
		baja = 1
    WHERE id = @id;
END;
GO

/*---------------Ventas---------------*/

-- Ingreso de venta
CREATE OR ALTER PROCEDURE op.ingresarVenta
	@tipo_factura char(1),
	@id_sucursal int,
	@tipo_cliente char(1),
	@genero char(1),
	@id_producto int,
	@cantidad int,
	@fecha smalldatetime,
	@id_medio_pago int,
	@legajo_empleado int,
	@identificador_pago varchar(23),
AS
BEGIN
    INSERT INTO op.ventas (tipo_factura, id_sucursal, tipo_cliente, genero, id_producto, cantidad, id_producto, fecha, id_medio_pago, legajo_empleado, identificador_pago)
    VALUES (@tipo_factura, @id_sucursal, @tipo_cliente, @genero, @id_producto, @cantidad, @id_producto, @fecha, @id_medio_pago, @legajo_empleado, @identificador_pago);
END;
GO

-- Modificacion de venta
CREATE OR ALTER PROCEDURE op.modificarVenta
	@id int,
    @tipo_factura char(1),
	@id_sucursal int,
	@tipo_cliente char(1),
	@genero char(1),
	@id_producto int,
	@cantidad int,
	@fecha smalldatetime,
	@id_medio_pago int,
	@legajo_empleado int,
	@identificador_pago varchar(23)
AS
BEGIN
    UPDATE Ventas
    SET
        tipo_factura = coalesce(@tipo_factura, tipo_factura),
		id_sucursal = coalesce(@id_sucursal, id_sucursal),
		tipo_cliente = coalesce(@tipo_cliente, tipo_cliente),
		genero = coalesce(@genero, genero),
		id_producto = coalesce(@id_producto, id_producto),
		cantidad = coalesce(@cantidad, cantidad),
		fecha = coalesce(@fecha, fecha),
		id_medio_pago = coalesce(@id_medio_pago, id_medio_pago),
		legajo_empleado = coalesce(@legajo_empleado, legajo_empleado),
		identificador_pago = coalesce(@identificador_pago, identificador_pago)
    WHERE id = @id;
END;
GO

-- Cancelacion de venta
CREATE OR ALTER PROCEDURE op.cancelarVenta
    @id INT
AS
BEGIN
    UPDATE op.ventas
	set
		cancelado = 1,
	WHERE id = @id;
END;
GO