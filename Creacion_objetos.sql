create database AuroraDB;
go

use AuroraDB;
go

create schema rrhh;
go

create schema op;
go

create table rrhh.sucursal (
	id int identity(1,1) primary key,
	ciudad varchar(30) not null,
	reemplazo varchar(30) not null, /*que seria?*/
	direccion varchar(100) not null,
	horario varchar(50) not null, /*L a V 8 a. m.-9 p. m. S y D 9 a. m.-8 p. m.*/
	telefono varchar(18) not null /*+54 9 11 2222-3333*/
);
go

create table rrhh.empleado (
	legajo int primary key, /*identity o no?*/
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	dni int not null,
	direccion varchar(100) not null,
	email_laboral varchar(50),
	cuil char(13) not null, /*11-22222222-3*/
	cargo varchar(20) not null, /*gerente de sucursal*/
	id_sucursal int not null,
	turno varchar(16), /*jornada completa*/
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
	id int identity(1,1) primary key,
	valor varchar(11) not null, /*credit card ???*/
	descripcion varchar(21) not null /*billetera electronica*/
);
go

create table op.categoria (
	id int identity(1,1) primary key,
	descripcion varchar(30) not null
);
go

create table op.catalogo (
	id int identity(1,1) primary key,
	id_categoria int not null,
	nombre varchar(50) not null,
	precio decimal(5,2) not null, /*???*/
	precio_referencia decimal(5,2) not null,
	unidad_referencia varchar(6) not null, /*100 ml*/
	fecha smalldatetime default getdate(),
	constraint FK_categoria foreign key
	(id_categoria) references op.categoria(id)
);
go

create table op.proveedor (
	id int identity(1,1) primary key,
	nombre varchar(50) not null
);
go

create table op.importado (
	id int identity(1,1) primary key,
	nombre varchar(50) not null,
	id_proveedor int not null,
	id_categoria int not null,
	cantidad_unidad varchar(20) not null, /*10 cajas x 12 piezas*/
	precio_unidad decimal(5,2) not null /*123,79*/
);
go

create table op.producto_electronico (
	id int identity(1,1) primary key,
	nombre varchar(50) not null,
	precio_dolares decimal(6,2) not null /*1700,00*/
);
go

create table op.venta (
	id char(11) primary key,
	tipo_factura char(1) not null,
	id_sucursal int not null,
	tipo_cliente char(1) not null, /*M o N*/
	genero char(1) not null, /*F o M*/
	id_producto int not null,
	cantidad int not null,
	fecha smalldatetime not null,
	id_medio_pago int not null,
	legajo_empleado int not null,
	identificador_pago varchar(23) /*'0000003100099475144530*/
	cancelado bit not null,
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
);
go

/*----------------SP sucursal-----------------*/
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

create or alter procedure rrhh.borrarSucursal
	@id int
as
begin
	set nocount on;
	delete from rrhh.sucursal where id = @id;
end;
go

/*----------------SP Empleados----------------*/
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

create or alter procedure rrhh.borrarEmpleado
	@legajo int
as
begin
	set nocount on;
	delete from rrhh.empleado where legajo = @legajo;
end;
go

/*----------------Medio de pago----------------*/
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

create or alter procedure op.borrarMedioPago
	@id int
as
begin
	set nocount on;
	delete from op.medioPago where id = @id;
end;