use Com2900G04;
go

----------------SP sucursal-----------------

-- Ingreso de sucursal
CREATE OR ALTER PROCEDURE rrhh.ingresarSucursal
	@ciudad varchar(30),
	@reemplazo varchar(30) = null,
	@direccion varchar(100),
	@horario varchar(50),
	@telefono varchar(18)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @ciudad IS NULL OR LEN(@ciudad) = 0
		SET @mensajes_error += 'La ciudad es requerida. ';
	IF @direccion IS NULL OR LEN(@direccion) = 0
		SET @mensajes_error += 'La dirección es requerida. ';
	IF @horario IS NULL OR LEN(@horario) = 0
		SET @mensajes_error += 'El horario es requerido. ';
	IF @telefono IS NULL OR LEN(@telefono) = 0
		SET @mensajes_error += 'El teléfono es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Inserción si no hubo errores
	INSERT INTO rrhh.sucursal (ciudad, reemplazar_por, direccion, horario, telefono)
	VALUES (@ciudad, @reemplazo, @direccion, @horario, @telefono);

	PRINT 'La sucursal fue ingresada exitosamente.';
END;
GO

-- Modificacion de sucursal
CREATE OR ALTER PROCEDURE rrhh.modificarSucursal
	@id int,
	@ciudad varchar(30),
	@reemplazo varchar(30) = null,
	@direccion varchar(100),
	@horario varchar(50),
	@telefono varchar(18)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
	IF @ciudad IS NULL OR LEN(@ciudad) = 0
		SET @mensajes_error += 'La ciudad es requerida. ';
	IF @direccion IS NULL OR LEN(@direccion) = 0
		SET @mensajes_error += 'La dirección es requerida. ';
	IF @horario IS NULL OR LEN(@horario) = 0
		SET @mensajes_error += 'El horario es requerido. ';
	IF @telefono IS NULL OR LEN(@telefono) = 0
		SET @mensajes_error += 'El teléfono es requerido. ';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Modificación si no hubo errores
	UPDATE rrhh.sucursal
	SET ciudad = @ciudad,
		reemplazar_por = @reemplazo,
		direccion = @direccion,
		horario = @horario,
		telefono = @telefono
	WHERE id = @id;
END;
GO

-- Baja de sucursal
CREATE OR ALTER PROCEDURE rrhh.borrarSucursal
	@id int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	-- Validación para evitar baja lógica repetida
	IF EXISTS (SELECT 1 FROM rrhh.sucursal WHERE id = @id AND baja = 1)
		SET @mensajes_error += 'La sucursal ya está dada de baja.';

	-- Mostrar errores y salir si hay algún mensaje
	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END;

	-- Borrado lógico si no hubo errores
	UPDATE rrhh.sucursal
	SET baja = 1
	WHERE id = @id;
END;
GO





---------------SP Empleados----------------

-- Ingreso de empleado
CREATE OR ALTER PROCEDURE rrhh.ingresarEmpleado
	--@siguiente_legajo int,
	@nombre varchar(30),
	@apellido varchar(30),
	@dni int,
	@direccion varchar(100),
	@email_laboral varchar(50),
	@cuil char(13),
	@cargo varchar(20),
	@id_sucursal int,
	@turno varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @siguiente_legajo INT;
	DECLARE @mensajes_error VARCHAR(MAX) = '';
	SELECT @siguiente_legajo = ISNULL(MAX(legajo), 0) + 1 FROM rrhh.empleado;

	IF @dni IS NULL OR @dni <= 0
    SET @mensajes_error = @mensajes_error + 'El DNI no puede ser nulo o menor o igual a 0.';

	-- Validación para comprobar que no exista un empleado con el mismo DNI
	IF EXISTS (SELECT 1 FROM rrhh.empleado WHERE dni = @dni)
	    SET @mensajes_error = @mensajes_error + 'Ya existe un empleado con el DNI proporcionado.';
	ELSE BEGIN
		IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
			SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío.';

		IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
			SET @mensajes_error = @mensajes_error + 'El apellido no puede ser nulo o vacío.';

		IF @direccion IS NULL OR LTRIM(RTRIM(@direccion)) = ''
			SET @mensajes_error = @mensajes_error + 'La dirección no puede ser nula o vacía.';

		IF @email_laboral IS NULL OR LTRIM(RTRIM(@email_laboral)) = '' OR @email_laboral NOT LIKE '%@%.%'
			SET @mensajes_error = @mensajes_error + 'El email laboral no puede ser nulo, vacío o tener un formato inválido.';

		IF @cuil IS NULL OR @cuil NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
			SET @mensajes_error += 'El CUIL es inválido. ';

		IF @cargo IS NULL OR LTRIM(RTRIM(@cargo)) = ''
			SET @mensajes_error = @mensajes_error + 'El cargo no puede ser nulo o vacío.';

		IF @id_sucursal IS NULL OR @id_sucursal <= 0
			SET @mensajes_error = @mensajes_error + 'El ID de la sucursal no puede ser nulo o menor o igual a 0.';

		IF @turno NOT IN ('TM', 'TT', 'Jornada completa')
			SET @mensajes_error = @mensajes_error + 'El turno debe ser uno de los siguientes valores: Mañana, Tarde, Noche.';
	END

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO rrhh.empleado (legajo, nombre, apellido, dni, direccion, email_empresa, cuil, cargo, id_sucursal, turno)
	VALUES (@siguiente_legajo, @nombre, @apellido, @dni, @direccion, @email_laboral, @cuil, @cargo, @id_sucursal, @turno);

	PRINT 'Empleado ingresado exitosamente';
END;
GO

-- Modificacion de empleado
CREATE OR ALTER PROCEDURE rrhh.modificarEmpleado
	@dni int,
	@nombre varchar(30),
	@apellido varchar(30),
	@direccion varchar(100),
	@email_laboral varchar(50),
	@cuil char(13),
	@cargo varchar(20),
	@id_sucursal int,
	@turno varchar(16)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @dni IS NULL OR @dni <= 0
		SET @mensajes_error += 'El DNI es inválido o debe ser mayor que cero. ';

	IF NOT EXISTS (SELECT 1 FROM rrhh.empleado WHERE dni = @dni)
	    SET @mensajes_error = @mensajes_error + 'No existe un empleado con el DNI proporcionado';
	ELSE BEGIN	
		IF @nombre IS NULL OR LEN(@nombre) = 0
			SET @mensajes_error += 'El nombre es requerido.';

		IF @apellido IS NULL OR LEN(@apellido) = 0
			SET @mensajes_error += 'El apellido es requerido.';

		IF @direccion IS NULL OR LEN(@direccion) = 0
			SET @mensajes_error += 'La dirección es requerida.';

		IF @email_laboral IS NOT NULL AND @email_laboral NOT LIKE '%@%.com'
			SET @mensajes_error += 'El email laboral es inválido.';

		IF @cuil IS NULL OR @cuil NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
			SET @mensajes_error += 'El CUIL es inválido.';

		IF @cargo IS NULL OR LEN(@cargo) = 0
			SET @mensajes_error += 'El cargo es requerido.';

		IF @id_sucursal IS NULL OR @id_sucursal <= 0
			SET @mensajes_error += 'El id_sucursal es inválido o debe ser mayor que cero.';

		IF @turno IS NULL OR LEN(@turno) = 0
			SET @mensajes_error += 'El turno es requerido.';
	END;

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Modificación si no hubo errores
	UPDATE rrhh.empleado
	SET nombre = @nombre,
		apellido = @apellido,
		direccion = @direccion,
		email_empresa = @email_laboral,
		cuil = @cuil,
		cargo = @cargo,
		id_sucursal = @id_sucursal,
		turno = @turno
	WHERE dni = @dni;
END;
go

-- Baja de empleado
CREATE OR ALTER PROCEDURE rrhh.borrarEmpleado
	@dni int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @dni IS NULL OR @dni <= 0
		SET @mensajes_error += 'El dni es inválido o debe ser mayor que cero. ';
	ELSE IF NOT EXISTS (SELECT 1 FROM rrhh.empleado WHERE dni = @dni)
	    SET @mensajes_error = @mensajes_error + 'No existe un empleado con el DNI proporcionado';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Borrado lógico si no hubo errores
	UPDATE rrhh.empleado
	SET baja = 1
	WHERE dni = @dni;
END;
go





----------------SP Medio de pago----------------

-- Ingreso de medio de pago
CREATE OR ALTER PROCEDURE op.ingresarMedioPago
	@valor varchar(11),
	@descripcion varchar(21)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @valor IS NULL OR LTRIM(RTRIM(@valor)) = ''
		SET @mensajes_error = @mensajes_error + 'El valor no puede ser nulo o vacío.';

	IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
		SET @mensajes_error = @mensajes_error + 'La descripción no puede ser nula o vacía.';

	IF LEN(@valor) < 1 OR LEN(@valor) > 11
		SET @mensajes_error = @mensajes_error + 'El valor debe tener entre 1 y 11 caracteres.';

	IF LEN(@descripcion) < 1 OR LEN(@descripcion) > 21
		SET @mensajes_error = @mensajes_error + 'La descripción debe tener entre 1 y 21 caracteres.';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.medioPago (medio, traduccion)
	VALUES (@valor, @descripcion);

	PRINT 'Medio de pago ingresado exitosamente.';
END;
GO

-- Modificacion de medio de pago
CREATE OR ALTER PROCEDURE op.modificarMedioPago
	@id int,
	@valor varchar(11) = null,
	@descripcion varchar(21) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
	IF @valor IS NULL OR LEN(@valor) = 0
		SET @mensajes_error += 'El valor es requerido. ';
	IF @descripcion IS NULL OR LEN(@descripcion) = 0
		SET @mensajes_error += 'La descripción es requerida. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Modificación si no hubo errores
	UPDATE op.medioPago
	SET medio = @valor,
		traduccion = @descripcion
	WHERE id = @id;
END;
go

-- Baja de medio de pago
CREATE OR ALTER PROCEDURE op.borrarMedioPago
	@id int
AS
BEGIN
	set nocount on;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
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
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
		SET @mensajes_error = @mensajes_error + 'La descripción no puede ser nula o vacía.';

	IF LEN(@descripcion) < 1 OR LEN(@descripcion) > 30
		SET @mensajes_error = @mensajes_error + 'La descripción debe tener entre 1 y 30 caracteres.';

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
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
	IF @descripcion IS NULL OR LEN(@descripcion) = 0
		SET @mensajes_error += 'La descripción es requerida. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
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
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
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
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mensajes_error VARCHAR(MAX);
	SET @mensajes_error = '';

	IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
		SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío.';

	IF LEN(@nombre) < 1 OR LEN(@nombre) > 50
		SET @mensajes_error = @mensajes_error + 'El nombre debe tener entre 1 y 50 caracteres.';

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
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
	IF @nombre IS NULL OR LEN(@nombre) = 0
		SET @mensajes_error += 'El nombre es requerido. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Modificación si no hubo errores
	UPDATE op.proveedor
	SET nombre = @nombre
	WHERE id = @id;
END;
GO

-- Baja de proveedor
CREATE OR ALTER PROCEDURE op.borrarProveedor
	@id int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
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
    @nombre_categoria VARCHAR(50),
    @precio DECIMAL(5,2),
    @precio_referencia DECIMAL(5,2),
    @unidad_referencia VARCHAR(6),
    @cantidad_unidad VARCHAR(20),
    @precio_dolares DECIMAL(6,2),
    @nombre_proveedor VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensajes_error VARCHAR(MAX);
    SET @mensajes_error = '';
    
    DECLARE @id_categoria INT;
    DECLARE @id_proveedor INT;

    -- Validaciones de parámetros
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @mensajes_error = @mensajes_error + 'El nombre no puede ser nulo o vacío. ';
    
    IF LEN(@nombre) < 1 OR LEN(@nombre) > 50
        SET @mensajes_error = @mensajes_error + 'El nombre debe tener entre 1 y 50 caracteres. ';

    IF @nombre_categoria IS NULL OR LTRIM(RTRIM(@nombre_categoria)) = ''
        SET @mensajes_error = @mensajes_error + 'El nombre de la categoría no puede ser nulo o vacío. ';
    
    IF @nombre_proveedor IS NULL OR LTRIM(RTRIM(@nombre_proveedor)) = ''
        SET @mensajes_error = @mensajes_error + 'El nombre del proveedor no puede ser nulo o vacío. ';

    IF @precio IS NULL OR @precio < 0
        SET @mensajes_error = @mensajes_error + 'El precio debe ser un valor válido y mayor o igual a 0. ';
    
    IF @precio_referencia IS NULL OR @precio_referencia < 0
        SET @mensajes_error = @mensajes_error + 'El precio de referencia debe ser un valor válido y mayor o igual a 0. ';
    
    IF @unidad_referencia IS NULL OR LTRIM(RTRIM(@unidad_referencia)) = ''
        SET @mensajes_error = @mensajes_error + 'La unidad de referencia no puede ser nula o vacía. ';
    
    IF LEN(@unidad_referencia) < 1 OR LEN(@unidad_referencia) > 6
        SET @mensajes_error = @mensajes_error + 'La unidad de referencia debe tener entre 1 y 6 caracteres. ';
    
    IF @cantidad_unidad IS NULL OR LTRIM(RTRIM(@cantidad_unidad)) = ''
        SET @mensajes_error = @mensajes_error + 'La cantidad de unidad no puede ser nula o vacía. ';
    
    IF LEN(@cantidad_unidad) < 1 OR LEN(@cantidad_unidad) > 20
        SET @mensajes_error = @mensajes_error + 'La cantidad de unidad debe tener entre 1 y 20 caracteres. ';
    
    IF @precio_dolares IS NULL OR @precio_dolares < 0
        SET @mensajes_error = @mensajes_error + 'El precio en dólares debe ser un valor válido y mayor o igual a 0. ';

    SELECT @id_categoria = id
    FROM op.categoria
    WHERE descripcion = @nombre_categoria;

    IF @id_categoria IS NULL
        SET @mensajes_error = @mensajes_error + 'No se encontró una categoría con el nombre especificado. ';
    
    SELECT @id_proveedor = id
    FROM op.proveedor
    WHERE nombre = @nombre_proveedor;

    IF @id_proveedor IS NULL
        SET @mensajes_error = @mensajes_error + 'No se encontró un proveedor con el nombre especificado. ';

    IF LEN(@mensajes_error) > 0
    BEGIN
        PRINT @mensajes_error;
        RETURN;
    END

    INSERT INTO op.producto (nombre, categoria, precio, precio_referencia, unidad_referencia, cantidad_unidad, precio_dolares, proveedor)
    VALUES (@nombre, @id_categoria, @precio, @precio_referencia, @unidad_referencia, @cantidad_unidad, @precio_dolares, @id_proveedor);

    PRINT 'Producto ingresado exitosamente';
END;
GO

-- Modificacion de productos
CREATE OR ALTER PROCEDURE op.modificarProducto
    @id INT,
    @nombre VARCHAR(50) = NULL,
    @nombre_categoria VARCHAR(50) = NULL,
    @nombre_proveedor VARCHAR(50) = NULL,
    @precio DECIMAL(5,2) = NULL,
    @precio_referencia DECIMAL(5,2) = NULL,
    @unidad_referencia VARCHAR(6) = NULL,
    @cantidad_unidad VARCHAR(20) = NULL,
    @precio_dolares DECIMAL(6,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @mensajes_error VARCHAR(4000) = '';
    DECLARE @id_categoria INT;
    DECLARE @id_proveedor INT;

    -- Validaciones de parámetros
    IF @id IS NULL OR @id <= 0
        SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
    
    IF @nombre IS NULL OR LEN(@nombre) = 0
        SET @mensajes_error += 'El nombre es requerido. ';
    
    IF @nombre_categoria IS NOT NULL
    BEGIN
        -- Obtener id_categoria desde el nombre de la categoría
        SELECT @id_categoria = id
        FROM op.categoria
        WHERE descripcion = @nombre_categoria;

        IF @id_categoria IS NULL
            SET @mensajes_error += 'No se encontró una categoría con el nombre especificado. ';
    END
    
    IF @nombre_proveedor IS NOT NULL
    BEGIN
        -- Obtener id_proveedor desde el nombre del proveedor
        SELECT @id_proveedor = id
        FROM op.proveedor
        WHERE nombre = @nombre_proveedor;

        IF @id_proveedor IS NULL
            SET @mensajes_error += 'No se encontró un proveedor con el nombre especificado. ';
    END
    
    IF @precio IS NULL OR @precio <= 0
        SET @mensajes_error += 'El precio es requerido y debe ser mayor que cero. ';
    
    IF @precio_referencia IS NULL OR @precio_referencia <= 0
        SET @mensajes_error += 'El precio de referencia es requerido y debe ser mayor que cero. ';
    
    IF @unidad_referencia IS NULL OR LEN(@unidad_referencia) = 0
        SET @mensajes_error += 'La unidad de referencia es requerida. ';
    
    IF @cantidad_unidad IS NULL OR LEN(@cantidad_unidad) = 0
        SET @mensajes_error += 'La cantidad por unidad es requerida. ';
    
    IF @precio_dolares IS NULL OR @precio_dolares <= 0
        SET @mensajes_error += 'El precio en dólares es requerido y debe ser mayor que cero. ';
    
    IF LEN(@mensajes_error) > 0
    BEGIN
        PRINT @mensajes_error;
        RETURN;
    END;

    -- Modificación si no hubo errores
    UPDATE op.producto
    SET 
        nombre = ISNULL(@nombre, nombre),
        categoria = ISNULL(@id_categoria, categoria),
        precio = ISNULL(@precio, precio),
        precio_referencia = ISNULL(@precio_referencia, precio_referencia),
        unidad_referencia = ISNULL(@unidad_referencia, unidad_referencia),
        cantidad_unidad = ISNULL(@cantidad_unidad, cantidad_unidad),
        precio_dolares = ISNULL(@precio_dolares, precio_dolares),
        proveedor = ISNULL(@id_proveedor, proveedor)
    WHERE id = @id;
    
    PRINT 'Producto modificado exitosamente';
END;
GO


-- Baja de producto
CREATE OR ALTER PROCEDURE op.borrarProducto
    @id INT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Borrado lógico si no hubo errores
	UPDATE op.producto
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
		SET @mensajes_error = @mensajes_error + 'El tipo de factura debe ser "A" o "B".';

	IF @id_sucursal IS NULL OR @id_sucursal <= 0
		SET @mensajes_error = @mensajes_error + 'El ID de la sucursal debe ser un valor válido y mayor a 0.';

	IF @tipo_cliente IS NULL OR @tipo_cliente NOT IN ('F', 'J')
		SET @mensajes_error = @mensajes_error + 'El tipo de cliente debe ser "F" (Final) o "J" (Jurídico).';

	IF @genero IS NULL OR @genero NOT IN ('M', 'F')
		SET @mensajes_error = @mensajes_error + 'El género debe ser "M" (Masculino) o "F" (Femenino).';

	IF @cantidad IS NULL OR @cantidad <= 0
		SET @mensajes_error = @mensajes_error + 'La cantidad debe ser un valor mayor a 0.';

	IF @fecha IS NULL OR @fecha > GETDATE()
		SET @mensajes_error = @mensajes_error + 'La fecha no puede ser nula o mayor que la fecha actual.';

	IF @id_medio_pago IS NULL OR @id_medio_pago <= 0
		SET @mensajes_error = @mensajes_error + 'El ID del medio de pago debe ser un valor válido y mayor a 0.';

	IF @legajo_empleado IS NULL OR @legajo_empleado <= 0
		SET @mensajes_error = @mensajes_error + 'El legajo del empleado debe ser un valor válido y mayor a 0.';

	IF @identificador_pago IS NULL OR LEN(@identificador_pago) < 1 OR LEN(@identificador_pago) > 23
		SET @mensajes_error = @mensajes_error + 'El identificador de pago debe tener entre 1 y 23 caracteres.';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN;
	END

	INSERT INTO op.venta (id_sucursal, tipo_cliente, fecha, id_empleado)
	VALUES (@id_sucursal, @tipo_cliente, @fecha, @legajo_empleado);

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
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validaciones
	IF @id IS NULL OR LEN(@id) <> 11
		SET @mensajes_error += 'El id es requerido y debe tener 11 caracteres. ';
	IF @tipo_factura NOT IN ('A', 'B', 'C')
		SET @mensajes_error += 'El tipo de factura debe ser A, B, o C. ';
	IF @id_sucursal IS NULL OR @id_sucursal <= 0
		SET @mensajes_error += 'El id de sucursal es inválido o debe ser mayor que cero. ';
	IF @tipo_cliente NOT IN ('M', 'N')
		SET @mensajes_error += 'El tipo de cliente debe ser M (Member) o N (Normal). ';
	IF @genero NOT IN ('F', 'M')
		SET @mensajes_error += 'El género debe ser F (Female) o M (Male). ';
	IF @id_producto IS NULL OR @id_producto <= 0
		SET @mensajes_error += 'El id de producto es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @mensajes_error += 'La cantidad es requerida y debe ser mayor que cero. ';
	IF @fecha IS NULL
		SET @mensajes_error += 'La fecha es requerida. ';
	IF @id_medio_pago IS NULL OR @id_medio_pago <= 0
		SET @mensajes_error += 'El id del medio de pago es inválido o debe ser mayor que cero. ';
	IF @legajo_empleado IS NULL OR @legajo_empleado <= 0
		SET @mensajes_error += 'El legajo del empleado es inválido o debe ser mayor que cero. ';
	IF @identificador_pago IS NULL OR LEN(@identificador_pago) = 0
		SET @mensajes_error += 'El identificador de pago es requerido. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	-- Modificación si no hubo errores
	UPDATE op.venta
	SET 
		id_sucursal = @id_sucursal,
		tipo_cliente = @tipo_cliente,
		fecha = @fecha,
		id_empleado = @legajo_empleado
	WHERE id = @id;
END;
GO

-- Cancelacion de venta
CREATE OR ALTER PROCEDURE op.cancelarVenta
    @id INT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @mensajes_error VARCHAR(4000) = '';

	-- Validación
	IF @id IS NULL OR LEN(@id) <> 11
		SET @mensajes_error += 'El id es requerido y debe tener 11 caracteres. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;
END;
GO





--------------SP Detalle_venta--------------

-- Inserción en detalle_venta
CREATE OR ALTER PROCEDURE op.ingresarDetalleVenta
	@id_venta CHAR(11),
	@id_producto INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id_venta IS NULL OR LEN(@id_venta) <> 11
		SET @mensajes_error += 'El id_venta es inválido o nulo. ';
	IF @id_producto IS NULL OR @id_producto <= 0
		SET @mensajes_error += 'El id_producto es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @mensajes_error += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @mensajes_error += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	INSERT INTO op.detalleventa (id_venta, id_producto, cantidad, precio_unitario)
	VALUES (@id_venta, @id_producto, @cantidad, @precio_unitario);
END;
GO

-- Modificación en detalle_venta
CREATE OR ALTER PROCEDURE op.modificarDetalleVenta
	@id INT,
	@cantidad INT,
	@precio_unitario DECIMAL(5,2)
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';
	IF @cantidad IS NULL OR @cantidad <= 0
		SET @mensajes_error += 'La cantidad es inválida o debe ser mayor que cero. ';
	IF @precio_unitario IS NULL OR @precio_unitario <= 0
		SET @mensajes_error += 'El precio_unitario es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		PRINT @mensajes_error;
		RETURN
	END;

	UPDATE op.detalleventa
	SET cantidad = @cantidad,
		precio_unitario = @precio_unitario
	WHERE id = @id;
END;
GO

-- Borrado lógico en detalle_venta
CREATE OR ALTER PROCEDURE op.borrarDetalleVenta
	@id INT
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id IS NULL OR @id <= 0
		SET @mensajes_error += 'El id es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		RAISERROR (@mensajes_error, 16, 1);
		RETURN;
	END;

END;
GO

-- Inserción en factura con validaciones
CREATE or Alter PROCEDURE op.ingresarFactura
	@id_factura CHAR(12),
	@tipo_factura CHAR(1),
	@total DECIMAL(10,2),
	@id_venta CHAR(11)
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @mensajes_error += 'El id_factura es inválido o nulo. ';
	IF @tipo_factura IS NULL OR NOT @tipo_factura IN ('A', 'B', 'C')
		SET @mensajes_error += 'El tipo_factura es inválido o nulo (debe ser A, B o C). ';
	IF @total IS NULL OR @total <= 0
		SET @mensajes_error += 'El total es inválido o debe ser mayor que cero. ';
	IF @id_venta IS NULL OR LEN(@id_venta) <> 11
		SET @mensajes_error += 'El id_venta es inválido o nulo. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		RAISERROR (@mensajes_error, 16, 1);
		RETURN;
	END;

	INSERT INTO op.factura (id, tipo_factura, total_sin_IVA, id_venta)
	VALUES (@id_factura, @tipo_factura, @total, @id_venta);
END;
GO

-- Modificación en factura
CREATE or alter PROCEDURE op.modificarFactura
	@id_factura CHAR(12),
	@total DECIMAL(10,2)
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @mensajes_error += 'El id_factura es inválido o nulo. ';
	IF @total IS NULL OR @total <= 0
		SET @mensajes_error += 'El total es inválido o debe ser mayor que cero. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		RAISERROR (@mensajes_error, 16, 1);
		RETURN;
	END;

	UPDATE op.factura
	SET total_sin_IVA = @total
	WHERE id = @id_factura;
END;
GO

-- Borrado lógico en factura
CREATE or alter PROCEDURE op.borrarFactura
	@id_factura CHAR(12)
AS
BEGIN
	DECLARE @mensajes_error VARCHAR(4000) = '';

	IF @id_factura IS NULL OR LEN(@id_factura) <> 12
		SET @mensajes_error += 'El id_factura es inválido o nulo. ';

	IF LEN(@mensajes_error) > 0
	BEGIN
		RAISERROR (@mensajes_error, 16, 1);
		RETURN;
	END;

	UPDATE op.factura
	SET estado = 'Anulada'
	WHERE id = @id_factura;
END;
GO
