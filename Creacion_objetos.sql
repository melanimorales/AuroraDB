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
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.
Entregar todo en un zip cuyo nombre sea Grupo_XX.zip mediante la sección de prácticas de
MIEL. Solo uno de los miembros del grupo debe hacer la entrega.
*/

--DROP DATABASE Com2900G04;

--------------------Creacion de la base de datos y esquemas--------------------
CREATE DATABASE Com2900G04;
GO

USE Com2900G04;
GO

CREATE SCHEMA rrhh;
GO

CREATE SCHEMA op;
GO

CREATE SCHEMA func;
GO

-------------------Tablas----------------
CREATE TABLE rrhh.super (
	id int identity(1,1) not null primary key,
	nombre varchar(20) not null,
	cuit char(13) not null
);
go

INSERT INTO rrhh.super (nombre, cuit)
VALUES ('Aurora', '11-22222222-3');
go

CREATE TABLE rrhh.sucursal (
	id int identity(1,1) not null,
	ciudad varchar(30) not null,
	reemplazar_por varchar(30) not null,
	direccion varchar(100) not null,
	horario varchar(50) not null, -- ej: L a V 8 a. m.-9 p. m. S y D 9 a. m.-8 p. m.
	telefono varchar(18) not null, -- ej: +54 9 11 2222-3333
	baja bit default 0,
	constraint PK_sucursal primary key (id)
);
go

CREATE TABLE rrhh.empleado (
	legajo int not null,
	nombre varchar(30) not null,
	apellido varchar(30) not null,
	dni int not null,
	direccion varchar(100) not null,
	email_personal varchar(100),
	email_empresa varchar(100),
	cuil char(13) not null, -- ej: 11-22222222-3
	cargo varchar(20) not null, -- ej: gerente de sucursal
	id_sucursal int not null,
	turno varchar(16), -- ej: jornada completa
	baja bit default 0,
	constraint PK_empleado primary key (legajo),
	constraint CK_email_personal check (
		email_personal like '%@%.%'
	),
	constraint CK_email_empresa check (
		email_empresa like '%@%.%'
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
	medio varchar(11) not null, -- ej: credit card
	traduccion varchar(21) not null, -- ej: billetera electronica
	baja bit default 0,
	constraint PK_medioPago primary key (id)
);
go

CREATE TABLE op.clasificacionProducto (
	id int identity(1,1) not null,
	linea_producto varchar(20) not null,
	producto varchar(100) not null
);
go

/*CREATE TABLE op.categoria (
	id int identity(1,1) not null,
	descripcion varchar(30) not null,
	borrado bit default 0,
	constraint PK_categoria primary key (id)
);
go*/

/*CREATE TABLE op.proveedor (
	id int identity(1,1) not null,
	nombre varchar(50) not null,
	baja bit default 0,
	constraint PK_proveedor primary key (id)
);
go*/

CREATE TABLE op.producto (
	id int identity(1,1) not null,
	nombre varchar(100) not null,
	categoria varchar(25) not null,
	precio decimal(10,2) not null,
	precio_referencia decimal(5,2) null,
	unidad_referencia varchar(10) null,
	cantidad_unidad varchar(20) null,
	precio_dolares decimal(6,2) null,
	proveedor varchar(100) null,
	fecha smalldatetime default getdate(),
	baja bit default 0,
	constraint PK_productos primary key (id)
);
go

CREATE TABLE op.venta (
	id int identity(1,1) not null,
	id_sucursal int not null,
	tipo_cliente char(6) not null,
	fecha date not null,
	hora time not null,
	id_empleado int not null,
	constraint PK_venta primary key (id),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_empleado foreign key
	(id_empleado) references rrhh.empleado(legajo)
);
go

CREATE TABLE op.detalleVenta (
	id int identity(1,1) not null,
	id_venta int not null,
	id_producto int not null,
	cantidad int not null,
	precio_unitario decimal(10,2),
	subtotal AS (cantidad * precio_unitario) PERSISTED,
	constraint PK_detalleVenta primary key (id),
	constraint FK_venta_detalle foreign key
	(id_venta) references op.venta(id),
	constraint FK_producto foreign key
	(id_producto) references op.producto(id)
);
go

CREATE TABLE op.factura (
	id char(11) not null,
	tipo_factura char(1) not null,
	id_venta int not null,
	total_sin_IVA decimal(10,2),
	total AS (total_sin_IVA * 1.21) PERSISTED,
	cuit char(13) not null,
	estado varchar(7) not null,
	constraint PK_factura primary key (id),
	constraint FK_venta_factura foreign key
	(id_venta) references op.venta(id),
	constraint CK_estado check (
		estado = 'Pagada' or estado = 'Anulada'
	)
);
go

CREATE TABLE op.pago (
	id varchar(30) not null,
	id_factura char(11) not null,
	id_medio_pago int not null,
	monto decimal(10,2) not null,
	fecha date not null,
	hora time not null,
	constraint PK_pago primary key (id),
	constraint FK_factura foreign key
	(id_factura) references op.factura(id),
	constraint FK_medio_pago foreign key
	(id_medio_pago) references op.medioPago(id)
);
go

/*CREATE TABLE op.venta (
	id char(11),
	tipo_factura char(1) not null,
	id_sucursal int not null,
	tipo_cliente char(1) not null, -- M o N (Member o Normal)
	genero char(1) not null, -- F o M (female o male)
	cantidad int not null,
	fecha date not null,
	hora time not null,
	id_medio_pago int not null,
	legajo_empleado int not null,
	identificador_pago varchar(23), -- ej: '0000003100099475144530
	cancelado bit default 0, -- cancelacion venta
	constraint PK_venta primary key (id),
	constraint FK_sucursal foreign key
	(id_sucursal) references rrhh.sucursal(id),
	constraint FK_medio_pago foreign key
	(id_medio_pago) references op.medioPago(id)
);
go*/

/*CREATE TABLE op.detalleVenta (
	id int identity(1,1) not null,
	id_venta char(11) not null,
	id_producto int not null,
	cantidad int not null,
	precio_unitario decimal(5,2) not null,
	constraint PK_detalle_venta primary key (id),
	constraint FK_venta foreign key (id_venta) references op.ventas(id),
	constraint FK_producto foreign key (id_producto) references op.productos(id)
);
go*/

/*CREATE TABLE op.factura (
	id char(12),
	fecha smalldatetime default getdate(),
	tipo_factura char(1) not null, -- A, B, C, etc.
	total decimal(10,2) not null,
	id_venta char(11) not null,
	constraint PK_factura primary key (id),
	constraint FK_factura_venta foreign key (id_venta) references op.venta(id)
);
go*/

CREATE OR ALTER PROCEDURE func.formatearTexto
    @texto VARCHAR(MAX),
    @resultado VARCHAR(MAX) OUTPUT
AS
BEGIN -- Elimina espacios a la izquierda y a la derecha, establece como mayuscula la primera letra y en minuscula las siguientes
    SET @resultado = CONCAT(UPPER(SUBSTRING(LTRIM(RTRIM(@texto)), 1, 1)), LOWER(SUBSTRING(LTRIM(RTRIM(@texto)), 2, LEN(LTRIM(RTRIM(@texto))) - 1)));
END;
GO

CREATE FUNCTION func.generarCUIL (
    @dni INT,
	@random UNIQUEIDENTIFIER
) RETURNS CHAR (13)
AS
BEGIN
    DECLARE @prefijo INT
    DECLARE @digitoVerificador INT
    DECLARE @suma INT = 0
	DECLARE @cuil CHAR(13);

    SET @prefijo = (SELECT CASE ABS(CHECKSUM(@random)) % 4
                     WHEN 0 THEN 20
                     WHEN 1 THEN 23
                     WHEN 2 THEN 24
                     ELSE 27
                END)

    -- Pesos para el cálculo del dígito verificador
    DECLARE @pesos TABLE (posicion INT, peso INT)
    INSERT INTO @pesos (posicion, peso)
    VALUES (1, 5), (2, 4), (3, 3), (4, 2), (5, 7), (6, 6), (7, 5), (8, 4), (9, 3), (10, 2)

    DECLARE @numeroCompleto CHAR(10) = CAST(@prefijo AS CHAR(2)) + RIGHT('00000000' + CAST(@dni AS VARCHAR(8)), 8);

    -- Calcular la suma ponderada
    SELECT @suma += CAST(SUBSTRING(@numeroCompleto, p.posicion, 1) AS INT) * p.peso
    FROM @pesos p

    -- Calcular el dígito verificador
    SET @digitoVerificador = (11 - (@suma % 11)) % 11
    IF @digitoVerificador = 10
        SET @digitoVerificador = 9

    -- Construir el CUIL completo
    SET @cuil = CAST(@prefijo AS CHAR(2)) + '-' + RIGHT('00000000' + CAST(@dni AS VARCHAR(8)), 8) + '-' + CAST(@digitoVerificador AS CHAR(1))
	RETURN @cuil;
END;
go

CREATE TABLE func.tipoCambio (
    moneda VARCHAR(10) not null,
    valor DECIMAL(10, 2) not null,
    fecha DATETIME DEFAULT GETDATE()
);
go

CREATE OR ALTER PROCEDURE func.registrarValorDolar
    @valor DECIMAL(18, 4)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mensajeError VARCHAR(200);

    IF @valor <= 0
    BEGIN
        SET @mensajeError = 'El valor del dólar debe ser mayor a cero.';
        THROW 50001, @mensajeError, 1;
    END

    INSERT INTO func.tipoCambio (moneda, valor)
    VALUES ('USD', @valor);
END;
go

CREATE FUNCTION func.convertirDolaresAPesos (
    @precioDolares DECIMAL(18, 2)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @valorDolar DECIMAL(18, 4);

    SELECT TOP 1 @valorDolar = valor
    FROM func.tipoCambio
    WHERE moneda = 'USD'
    ORDER BY fecha DESC;

    IF @valorDolar IS NULL
        RETURN NULL;

    RETURN @precioDolares * @valorDolar;
END;
go