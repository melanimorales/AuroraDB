use AuroraDB;
go

----------------SP sucursal-----------------

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
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @ciudad IS NULL OR LEN(@ciudad) = 0
		SET @error_msg += 'La ciudad es requerida. ';
	IF @reemplazo IS NULL OR LEN(@reemplazo) = 0
		SET @error_msg += 'El campo reemplazo es requerido. ';
	IF @direccion IS NULL OR LEN(@direccion) = 0
		SET @error_msg += 'La dirección es requerida. ';
	IF @horario IS NULL OR LEN(@horario) = 0
		SET @error_msg += 'El horario es requerido. ';
	IF @telefono IS NULL OR LEN(@telefono) = 0
		SET @error_msg += 'El teléfono es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Inserción si no hubo errores
	INSERT INTO rrhh.sucursal (ciudad, reemplazo, direccion, horario, telefono)
	VALUES (@ciudad, @reemplazo, @direccion, @horario, @telefono);
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
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @ciudad IS NULL OR LEN(@ciudad) = 0
		SET @error_msg += 'La ciudad es requerida. ';
	IF @reemplazo IS NULL OR LEN(@reemplazo) = 0
		SET @error_msg += 'El campo reemplazo es requerido. ';
	IF @direccion IS NULL OR LEN(@direccion) = 0
		SET @error_msg += 'La dirección es requerida. ';
	IF @horario IS NULL OR LEN(@horario) = 0
		SET @error_msg += 'El horario es requerido. ';
	IF @telefono IS NULL OR LEN(@telefono) = 0
		SET @error_msg += 'El teléfono es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE rrhh.sucursal
	SET ciudad = @ciudad,
		reemplazo = @reemplazo,
		direccion = @direccion,
		horario = @horario,
		telefono = @telefono
	WHERE id = @id;
end;
go

-- Baja de sucursal
create or alter procedure rrhh.borrarSucursal
	@id int
as
begin
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE rrhh.sucursal
	SET baja = 1
	WHERE id = @id;
end;
go




---------------SP Empleados----------------

-- Ingreso de empleado
CREATE OR ALTER PROCEDURE rrhh.ingresarEmpleado
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
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @legajo IS NULL OR @legajo <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El legajo no puede ser nulo o menor o igual a 0. ';
	END

	IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío. ';
	END

	IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El apellido no puede ser nulo o vacío. ';
	END

	IF @dni IS NULL OR @dni <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El DNI no puede ser nulo o menor o igual a 0. ';
	END

	IF @direccion IS NULL OR LTRIM(RTRIM(@direccion)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La dirección no puede ser nula o vacía. ';
	END

	IF @email_laboral IS NULL OR LTRIM(RTRIM(@email_laboral)) = '' OR 
	   @email_laboral NOT LIKE '%_@__%.__%'
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El email laboral no puede ser nulo, vacío o tener un formato inválido. ';
	END

	IF @cuil IS NULL OR LEN(@cuil) != 13
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El CUIL debe tener 13 caracteres. ';
	END

	IF @cargo IS NULL OR LTRIM(RTRIM(@cargo)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El cargo no puede ser nulo o vacío. ';
	END

	IF @id_sucursal IS NULL OR @id_sucursal <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID de la sucursal no puede ser nulo o menor o igual a 0. ';
	END

	IF @turno NOT IN ('Mañana', 'Tarde', 'Noche')
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El turno debe ser uno de los siguientes valores: Mañana, Tarde, Noche. ';
	END

	IF EXISTS (SELECT 1 FROM rrhh.empleado WHERE legajo = @legajo)
	BEGIN
		SET @mensajes_error = @mensajes_error + 'Ya existe un empleado con el legajo proporcionado. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO rrhh.empleado (legajo, nombre, apellido, dni, direccion, email_laboral, cuil, cargo, id_sucursal, turno)
	VALUES (@legajo, @nombre, @apellido, @dni, @direccion, @email_laboral, @cuil, @cargo, @id_sucursal, @turno);

	PRINT 'Empleado ingresado exitosamente';
END;
GO

-- Modificacion de empleado
CREATE OR ALTER PROCEDURE rrhh.modificarEmpleado
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
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @legajo IS NULL OR @legajo <= 0
		SET @error_msg += 'El legajo es inválido o debe ser mayor que cero. ';
	IF @nombre IS NULL OR LEN(@nombre) = 0
		SET @error_msg += 'El nombre es requerido. ';
	IF @apellido IS NULL OR LEN(@apellido) = 0
		SET @error_msg += 'El apellido es requerido. ';
	IF @dni IS NULL OR @dni <= 0
		SET @error_msg += 'El DNI es inválido o debe ser mayor que cero. ';
	IF @direccion IS NULL OR LEN(@direccion) = 0
		SET @error_msg += 'La dirección es requerida. ';
	IF @email_laboral IS NOT NULL AND @email_laboral NOT LIKE '%@%.com'
		SET @error_msg += 'El email laboral es inválido. ';
	IF @cuil IS NULL OR @cuil NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
		SET @error_msg += 'El CUIL es inválido. ';
	IF @cargo IS NULL OR LEN(@cargo) = 0
		SET @error_msg += 'El cargo es requerido. ';
	IF @id_sucursal IS NULL OR @id_sucursal <= 0
		SET @error_msg += 'El id_sucursal es inválido o debe ser mayor que cero. ';
	IF @turno IS NULL OR LEN(@turno) = 0
		SET @error_msg += 'El turno es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE rrhh.empleado
	SET nombre = @nombre,
		apellido = @apellido,
		dni = @dni,
		direccion = @direccion,
		email_laboral = @email_laboral,
		cuil = @cuil,
		cargo = @cargo,
		id_sucursal = @id_sucursal,
		turno = @turno
	WHERE legajo = @legajo;
END;
go

-- Baja de empleado
CREATE OR ALTER PROCEDURE rrhh.borrarEmpleado
	@legajo int
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @legajo IS NULL OR @legajo <= 0
		SET @error_msg += 'El legajo es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE rrhh.empleado
	SET baja = 1
	WHERE legajo = @legajo;
END;
go





----------------SP Medio de pago----------------

-- Ingreso de medio de pago
CREATE OR ALTER PROCEDURE op.ingresarMedioPago
	@valor varchar(11),
	@descripcion varchar(21)
as
BEGIN
	set nocount on;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @valor IS NULL OR LTRIM(RTRIM(@valor)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El valor no puede ser nulo o vacío. ';
	END

	IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La descripción no puede ser nula o vacía. ';
	END

	IF LEN(@valor) < 1 OR LEN(@valor) > 11
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El valor debe tener entre 1 y 11 caracteres. ';
	END

	IF LEN(@descripcion) < 1 OR LEN(@descripcion) > 21
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La descripción debe tener entre 1 y 21 caracteres. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.medioPago (valor, descripcion)
	VALUES (@valor, @descripcion);

	PRINT 'Medio de pago ingresado exitosamente';
END;
GO

-- Modificacion de medio de pago
CREATE OR ALTER PROCEDURE op.modificarMedioPago
	@id int,
	@valor varchar(11) = null,
	@descripcion varchar(21) = null
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @valor IS NULL OR LEN(@valor) = 0
		SET @error_msg += 'El valor es requerido. ';
	IF @descripcion IS NULL OR LEN(@descripcion) = 0
		SET @error_msg += 'La descripción es requerida. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE op.medioPago
	SET valor = @valor,
		descripcion = @descripcion
	WHERE id = @id;
END;
go

-- Baja de medio de pago
CREATE OR ALTER PROCEDURE op.borrarMedioPago
	@id int
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.medioPago
	SET baja = 1
	WHERE id = @id;
END;
go






---------------SP Categoria---------------

-- Ingreso de categoria
CREATE OR ALTER PROCEDURE op.ingresarCategoria
	@descripcion varchar(30)
as
BEGIN
	set nocount on;
	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La descripción no puede ser nula o vacía. ';
	END

	IF LEN(@descripcion) < 1 OR LEN(@descripcion) > 30
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La descripción debe tener entre 1 y 30 caracteres. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.categoria (descripcion)
	VALUES (@descripcion);

	PRINT 'Categoría ingresada exitosamente';
END;
GO

-- Modificacion de categoria
CREATE OR ALTER PROCEDURE op.modificarCategoria
	@id int,
	@descripcion varchar(30) = null
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @descripcion IS NULL OR LEN(@descripcion) = 0
		SET @error_msg += 'La descripción es requerida. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE op.categoria
	SET descripcion = @descripcion
	WHERE id = @id;
END;
go

-- Borrado de categoria
CREATE OR ALTER PROCEDURE op.borrarCategoria
	@id int
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.categoria
	SET borrado = 1
	WHERE id = @id;
END;
go





---------------SP Proveedor---------------

-- Ingreso de proveedor
CREATE OR ALTER PROCEDURE op.ingresarProveedor
	@nombre VARCHAR(50)
as
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío. ';
	END

	IF LEN(@nombre) < 1 OR LEN(@nombre) > 50
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El nombre debe tener entre 1 y 50 caracteres. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.proveedor (nombre)
	VALUES (@nombre);

	PRINT 'Proveedor ingresado exitosamente';
END;
GO


-- Modificacion de proveedor
CREATE OR ALTER PROCEDURE op.modificarProveedor
	@id int,
	@nombre varchar(50) = null
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @nombre IS NULL OR LEN(@nombre) = 0
		SET @error_msg += 'El nombre es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE op.proveedor
	SET nombre = @nombre
	WHERE id = @id;
END;
go

-- Baja de proveedor
CREATE OR ALTER PROCEDURE op.borrarProveedor
	@id int
as
BEGIN
	set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.proveedor
	SET baja = 1
	WHERE id = @id;
END;
go





---------------SP Productos---------------

-- Ingreso de producto
CREATE OR ALTER PROCEDURE op.ingresarProducto
    @nombre VARCHAR(50),
	@id_categoria INT,
	@precio DECIMAL(5,2),
	@precio_referencia DECIMAL(5,2),
	@unidad_referencia VARCHAR(6),
	@cantidad_unidad VARCHAR(20),
	@precio_dolares DECIMAL(6,2),
	@id_proveedor INT
as
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío. ';
	END

	IF LEN(@nombre) < 1 OR LEN(@nombre) > 50
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El nombre debe tener entre 1 y 50 caracteres. ';
	END

	IF @id_categoria IS NULL OR @id_categoria <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID de la categoría debe ser un valor válido y mayor a 0. ';
	END

	IF @precio IS NULL OR @precio < 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El precio debe ser un valor válido y mayor o igual a 0. ';
	END

	IF @precio_referencia IS NULL OR @precio_referencia < 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El precio de referencia debe ser un valor válido y mayor o igual a 0. ';
	END

	IF @unidad_referencia IS NULL OR LTRIM(RTRIM(@unidad_referencia)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La unidad de referencia no puede ser nula o vacía. ';
	END

	IF LEN(@unidad_referencia) < 1 OR LEN(@unidad_referencia) > 6
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La unidad de referencia debe tener entre 1 y 6 caracteres. ';
	END

	IF @cantidad_unidad IS NULL OR LTRIM(RTRIM(@cantidad_unidad)) = ''
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La cantidad de unidad no puede ser nula o vacía. ';
	END

	IF LEN(@cantidad_unidad) < 1 OR LEN(@cantidad_unidad) > 20
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La cantidad de unidad debe tener entre 1 y 20 caracteres. ';
	END

	IF @precio_dolares IS NULL OR @precio_dolares < 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El precio en dólares debe ser un valor válido y mayor o igual a 0. ';
	END

	IF @id_proveedor IS NULL OR @id_proveedor <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID del proveedor debe ser un valor válido y mayor a 0. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.productos (nombre, id_categoria, precio, precio_referencia, unidad_referencia, cantidad_unidad, precio_dolares, id_proveedor)
	VALUES (@nombre, @id_categoria, @precio, @precio_referencia, @unidad_referencia, @cantidad_unidad, @precio_dolares, @id_proveedor);

	PRINT 'Producto ingresado exitosamente';
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
as
BEGIN
	set nocount on;
    DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @nombre IS NULL OR LEN(@nombre) = 0
		SET @error_msg += 'El nombre es requerido. ';
	IF @id_categoria IS NULL OR @id_categoria <= 0
		SET @error_msg += 'El id de categoría es inválido o debe ser mayor que cero. ';
	IF @precio IS NULL OR @precio <= 0
		SET @error_msg += 'El precio es requerido y debe ser mayor que cero. ';
	IF @precio_referencia IS NULL OR @precio_referencia <= 0
		SET @error_msg += 'El precio de referencia es requerido y debe ser mayor que cero. ';
	IF @unidad_referencia IS NULL OR LEN(@unidad_referencia) = 0
		SET @error_msg += 'La unidad de referencia es requerida. ';
	IF @cantidad_unidad IS NULL OR LEN(@cantidad_unidad) = 0
		SET @error_msg += 'La cantidad por unidad es requerida. ';
	IF @precio_dolares IS NULL OR @precio_dolares <= 0
		SET @error_msg += 'El precio en dólares es requerido y debe ser mayor que cero. ';
	IF @id_proveedor IS NULL OR @id_proveedor <= 0
		SET @error_msg += 'El id del proveedor es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE op.productos
	SET nombre = @nombre,
		id_categoria = @id_categoria,
		precio = @precio,
		precio_referencia = @precio_referencia,
		unidad_referencia = @unidad_referencia,
		cantidad_unidad = @cantidad_unidad,
		precio_dolares = @precio_dolares,
		id_proveedor = @id_proveedor
	WHERE id = @id;
END;
GO

-- Baja de producto
CREATE OR ALTER PROCEDURE op.borrarProducto
    @id INT
as
BEGIN
	set nocount on;
    DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.productos
	SET baja = 1
	WHERE id = @id;
END;
GO





---------------SP Ventas---------------

-- Ingreso de venta
CREATE OR ALTER PROCEDURE op.ingresarVenta
	@tipo_factura CHAR(1),
	@id_sucursal INT,
	@tipo_cliente CHAR(1),
	@genero CHAR(1),
	@id_producto INT,
	@cantidad INT,
	@fecha SMALLDATETIME,
	@id_medio_pago INT,
	@legajo_empleado INT,
	@identificador_pago VARCHAR(23)
as
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @tipo_factura IS NULL OR @tipo_factura NOT IN ('A', 'B')
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El tipo de factura debe ser "A" o "B". ';
	END

	IF @id_sucursal IS NULL OR @id_sucursal <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID de la sucursal debe ser un valor válido y mayor a 0. ';
	END

	IF @tipo_cliente IS NULL OR @tipo_cliente NOT IN ('F', 'J')
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El tipo de cliente debe ser "F" (Final) o "J" (Jurídico). ';
	END

	IF @genero IS NULL OR @genero NOT IN ('M', 'F')
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El género debe ser "M" (Masculino) o "F" (Femenino). ';
	END

	IF @id_producto IS NULL OR @id_producto <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID del producto debe ser un valor válido y mayor a 0. ';
	END

	IF @cantidad IS NULL OR @cantidad <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La cantidad debe ser un valor mayor a 0. ';
	END

	IF @fecha IS NULL OR @fecha > GETDATE()
	BEGIN
		SET @mensajes_error = @mensajes_error + 'La fecha no puede ser nula o mayor que la fecha actual. ';
	END

	IF @id_medio_pago IS NULL OR @id_medio_pago <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El ID del medio de pago debe ser un valor válido y mayor a 0. ';
	END

	IF @legajo_empleado IS NULL OR @legajo_empleado <= 0
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El legajo del empleado debe ser un valor válido y mayor a 0. ';
	END

	IF @identificador_pago IS NULL OR LEN(@identificador_pago) < 1 OR LEN(@identificador_pago) > 23
	BEGIN
		SET @mensajes_error = @mensajes_error + 'El identificador de pago debe tener entre 1 y 23 caracteres. ';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.ventas (tipo_factura, id_sucursal, tipo_cliente, genero, id_producto, cantidad, fecha, id_medio_pago, legajo_empleado, identificador_pago)
	VALUES (@tipo_factura, @id_sucursal, @tipo_cliente, @genero, @id_producto, @cantidad, @fecha, @id_medio_pago, @legajo_empleado, @identificador_pago);

	PRINT 'Venta ingresada exitosamente';
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
as
BEGIN
    set nocount on;
	DECLARE @error_msg VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR LEN(@id) <> 11
		SET @error_msg += 'El id es requerido y debe tener 11 caracteres. ';
	IF @tipo_factura NOT IN ('A', 'B', 'C')
		SET @error_msg += 'El tipo de factura debe ser A, B, o C. ';
	IF @id_sucursal IS NULL OR @id_sucursal <= 0
		SET @error_msg += 'El id de sucursal es inválido o debe ser mayor que cero. ';
	IF @tipo_cliente NOT IN ('M', 'N')
		SET @error_msg += 'El tipo de cliente debe ser M (Member) o N (Normal). ';
	IF @genero NOT IN ('F', 'M')
		SET @error_msg += 'El género debe ser F (Female) o M (Male). ';
	IF @id_producto IS NULL OR @id_producto <= 0
		SET @error_msg += 'El id de producto es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @error_msg += 'La cantidad es requerida y debe ser mayor que cero. ';
	IF @fecha IS NULL
		SET @error_msg += 'La fecha es requerida. ';
	IF @id_medio_pago IS NULL OR @id_medio_pago <= 0
		SET @error_msg += 'El id del medio de pago es inválido o debe ser mayor que cero. ';
	IF @legajo_empleado IS NULL OR @legajo_empleado <= 0
		SET @error_msg += 'El legajo del empleado es inválido o debe ser mayor que cero. ';
	IF @identificador_pago IS NULL OR LEN(@identificador_pago) = 0
		SET @error_msg += 'El identificador de pago es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Modificación si no hubo errores
	UPDATE op.ventas
	SET tipo_factura = @tipo_factura,
		id_sucursal = @id_sucursal,
		tipo_cliente = @tipo_cliente,
		genero = @genero,
		id_producto = @id_producto,
		cantidad = @cantidad,
		fecha = @fecha,
		id_medio_pago = @id_medio_pago,
		legajo_empleado = @legajo_empleado,
		identificador_pago = @identificador_pago
	WHERE id = @id;
END;
GO

-- Cancelacion de venta
CREATE OR ALTER PROCEDURE op.cancelarVenta
    @id INT
as
BEGIN
	set nocount on;
    DECLARE @error_msg VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR LEN(@id) <> 11
		SET @error_msg += 'El id es requerido y debe tener 11 caracteres. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.ventas
	SET cancelado = 1
	WHERE id = @id;
END;
GO





--------------SP Detalle_venta--------------

-- Inserción en detalle_venta
CREATE PROCEDURE op.ingresarDetalleVenta
	@id_venta CHAR(11),
	@id_producto INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id_venta IS NULL OR LEN(@id_venta) <> 11
		SET @error_msg += 'El id_venta es inválido o nulo. ';
	IF @id_producto IS NULL OR @id_producto <= 0
		SET @error_msg += 'El id_producto es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @error_msg += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @error_msg += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	INSERT INTO op.detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
	VALUES (@id_venta, @id_producto, @cantidad, @precio_unitario);
END;
GO

-- Modificación en detalle_venta
CREATE PROCEDURE op.modificarDetalleVenta
	@id INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @error_msg += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @error_msg += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.detalle_venta
	SET cantidad = @cantidad,
		precio_unitario = @precio_unitario
	WHERE id = @id;
END;
GO

-- Borrado lógico en detalle_venta
CREATE PROCEDURE op.borrarDetalleVenta
	@id INT
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.detalle_venta
	SET baja = 1
	WHERE id = @id;
END;
GO

-- Inserción en factura con validaciones
CREATE PROCEDURE op.ingresarFactura
	@id_factura CHAR(12),
	@tipo_factura CHAR(1),
	@total DECIMAL(10,2),
	@id_venta CHAR(11)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @error_msg += 'El id_factura es inválido o nulo. ';
	IF @tipo_factura IS NULL OR NOT @tipo_factura IN ('A', 'B', 'C')
		SET @error_msg += 'El tipo_factura es inválido o nulo (debe ser A, B o C). ';
	IF @total IS NULL OR @total <= 0
		SET @error_msg += 'El total es inválido o debe ser mayor que cero. ';
	IF @id_venta IS NULL OR LEN(@id_venta) <> 11
		SET @error_msg += 'El id_venta es inválido o nulo. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	INSERT INTO op.factura (id_factura, tipo_factura, total, id_venta)
	VALUES (@id_factura, @tipo_factura, @total, @id_venta);
END;
GO

-- Modificación en factura
CREATE PROCEDURE op.modificarFactura
	@id_factura CHAR(12),
	@total DECIMAL(10,2)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @error_msg += 'El id_factura es inválido o nulo. ';
	IF @total IS NULL OR @total <= 0
		SET @error_msg += 'El total es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.factura
	SET total = @total
	WHERE id_factura = @id_factura;
END;
GO

-- Borrado lógico en factura
CREATE PROCEDURE op.borrarFactura
	@id_factura CHAR(12)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @error_msg += 'El id_factura es inválido o nulo. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.factura
	SET baja = 1
	WHERE id_factura = @id_factura;
END;
GO





-----------SP Detalle_factura-----------

-- Inserción en detalle_factura
CREATE PROCEDURE op.ingresarDetalleFactura
	@id_factura CHAR(12),
	@id_producto INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @error_msg += 'El id_factura es inválido o nulo. ';
	IF @id_producto IS NULL OR @id_producto <= 0
		SET @error_msg += 'El id_producto es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @error_msg += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @error_msg += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	INSERT INTO op.detalle_factura (id_factura, id_producto, cantidad, precio_unitario)
	VALUES (@id_factura, @id_producto, @cantidad, @precio_unitario);
END;
GO

-- Modificación en detalle_factura
CREATE PROCEDURE op.modificarDetalleFactura
	@id INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @error_msg += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @error_msg += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.detalle_factura
	SET cantidad = @cantidad,
		precio_unitario = @precio_unitario
	WHERE id = @id;
END;
GO

-- Borrado lógico en detalle_factura
CREATE PROCEDURE op.borrarDetalleFactura
	@id INT
AS
BEGIN
	DECLARE @error_msg VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @error_msg += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@error_msg) > 0
	BEGIN
		RAISERROR (@error_msg, 16, 1);
		RETURN;
	END;

	UPDATE op.detalle_factura
	SET baja = 1
	WHERE id = @id;
END;
GO