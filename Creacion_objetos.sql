/* Materia: Base de datos aplicada
Fecha de entrega: 12/11/2024
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

create table op.proveedor (
	id int identity(1,1) primary key,
	nombre varchar(50) not null
);
go

create table op.productos (
	id int identity(1,1) primary key,
	id_categoria int not null,
	nombre varchar(50) not null,
	precio decimal(5,2) not null, /*???*/
	precio_referencia decimal(5,2) not null,
	unidad_referencia varchar(6) not null, /*100 ml*/
	cantidad_unidad varchar(20) not null,
	precio_dolares decimal(6,2) not null,
	id_proveedor int not null,
	fecha smalldatetime default getdate(),
	constraint FK_categoria foreign key
	(id_categoria) references op.categoria(id),
	constraint FK_proveedor foreign key
	(id_proveedor) references op.categoria(id)
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
	identificador_pago varchar(23), /*'0000003100099475144530*/
	cancelado bit not null,
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_producto foreign key
	(id_producto) references op.productos(id),
	constraint FK_medio_pago foreign key
	(id_medio_pago) references op.medioPago(id),
);
go


-- SP de inserción, modificación y borrado de las tablas
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
go

/*---------------Categoría---------------*/
create or alter procedure op.ingresarCategoria
	@descripcion varchar(30)
as
begin
	set nocount on;
	insert into op.categoria (descripcion)
	values (@descripcion);
end;
go

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

create or alter procedure op.borrarCategoria
	@id int
as
begin
	set nocount on;
	delete from op.categoria where id = @id;
end;
go

/*---------------Proveedor---------------*/
create or alter procedure op.ingresarProveedor
	@nombre varchar(50)
as
begin
	set nocount on;
	insert into op.proveedor (nombre)
	values (@nombre);
end;
go

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

create or alter procedure op.borrarProveedor
	@id int
as
begin
	set nocount on;
	delete from op.proveedor where id = @id;
end;
go

/*---------------Productos---------------*/

-- Inserción en Productos
CREATE PROCEDURE InsertarProducto
    @Nombre NVARCHAR(100),
    @Categoria NVARCHAR(50),
    @Precio DECIMAL(10, 2),
    @Stock INT
AS
BEGIN
    INSERT INTO Productos (Nombre, Categoria, Precio, Stock)
    VALUES (@Nombre, @Categoria, @Precio, @Stock);
END;
GO

-- Modificación en Productos
CREATE PROCEDURE ModificarProducto
    @ProductoID INT,
    @Nombre NVARCHAR(100) = NULL,
    @Categoria NVARCHAR(50) = NULL,
    @Precio DECIMAL(10, 2) = NULL,
    @Stock INT = NULL
AS
BEGIN
    UPDATE Productos
    SET 
        Nombre = COALESCE(@Nombre, Nombre),
        Categoria = COALESCE(@Categoria, Categoria),
        Precio = COALESCE(@Precio, Precio),
        Stock = COALESCE(@Stock, Stock)
    WHERE ProductoID = @ProductoID;
END;
GO

-- Borrado en Productos
CREATE PROCEDURE BorrarProducto
    @ProductoID INT
AS
BEGIN
    DELETE FROM Productos
    WHERE ProductoID = @ProductoID;
END;
GO

/*---------------Ventas---------------*/

-- Inserción en Ventas
CREATE PROCEDURE InsertarVenta
    @ProductoID INT,
    @Cantidad INT,
    @FechaVenta DATE,
    @Total DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Ventas (ProductoID, Cantidad, FechaVenta, Total)
    VALUES (@ProductoID, @Cantidad, @FechaVenta, @Total);
END;
GO

-- Modificación en Ventas
CREATE PROCEDURE ModificarVenta
    @VentaID INT,
    @ProductoID INT = NULL,
    @Cantidad INT = NULL,
    @FechaVenta DATE = NULL,
    @Total DECIMAL(10, 2) = NULL
AS
BEGIN
    UPDATE Ventas
    SET 
        ProductoID = COALESCE(@ProductoID, ProductoID),
        Cantidad = COALESCE(@Cantidad, Cantidad),
        FechaVenta = COALESCE(@FechaVenta, FechaVenta),
        Total = COALESCE(@Total, Total)
    WHERE VentaID = @VentaID;
END;
GO

-- Borrado en Ventas
CREATE PROCEDURE BorrarVenta
    @VentaID INT
AS
BEGIN
    DELETE FROM Ventas
    WHERE VentaID = @VentaID;
END;
GO
