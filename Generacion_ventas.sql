USE Com2900G04;
go

DECLARE @productos TABLE (
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10, 2)
);
go

INSERT INTO @productos (id_producto, cantidad, precio_unitario)
VALUES 
    (1, 2, 100.00),
    (2, 1, 50.00),
    (3, 3, 30.00);
go

EXEC sp_registrarVenta 
    @id_caja = 1,
    @id_cajero = 1,
    @productos = @productos,
    @metodo_pago = 'Efectivo',
    @monto_pago = 340.00; -- Suma total de los productos con IVA (opcional)
go

CREATE OR ALTER PROCEDURE sp_registrarVenta
    @id_caja INT,
    @id_cajero INT,
    @productos TABLE (id_producto INT, cantidad INT, precio_unitario DECIMAL(10, 2)),
    @metodo_pago VARCHAR(50), -- Efectivo, Tarjeta, etc.
    @monto_pago DECIMAL(10, 2)
AS
BEGIN
    -- Registrar la venta
    DECLARE @id_venta INT;
    INSERT INTO venta (fecha, id_caja, id_cajero)
    VALUES (GETDATE(), @id_caja, @id_cajero);

    SET @id_venta = SCOPE_IDENTITY();

    -- Registrar el detalle de la venta
    INSERT INTO detalleVenta (id_venta, id_producto, cantidad, precio_unitario, subtotal)
    SELECT @id_venta, p.id_producto, p.cantidad, p.precio_unitario, p.cantidad * p.precio_unitario
    FROM @productos p;

    -- Calcular el subtotal y el IVA
    DECLARE @subtotal DECIMAL(10, 2) = (
        SELECT SUM(cantidad * precio_unitario)
        FROM @productos
    );
    DECLARE @iva DECIMAL(10, 2) = @subtotal * 0.21;
    DECLARE @total DECIMAL(10, 2) = @subtotal + @iva;

    -- Generar la factura
    DECLARE @id_factura INT;
    INSERT INTO factura (id_venta, subtotal, iva, total, estado)
    VALUES (@id_venta, @subtotal, @iva, @total, 'PAGADA');

    SET @id_factura = SCOPE_IDENTITY();

    -- Registrar el pago
    INSERT INTO pago (id_factura, monto, metodo_pago, fecha)
    VALUES (@id_factura, @monto_pago, @metodo_pago, GETDATE());
END;
GO

CREATE OR ALTER PROCEDURE sp_anularVenta
    @id_venta INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar si existe una factura asociada a la venta
        DECLARE @id_factura INT;
        SELECT @id_factura = id_factura FROM factura WHERE id_venta = @id_venta;

        IF @id_factura IS NULL
        BEGIN
            THROW 50001, 'No se encontró una factura asociada a la venta.', 1;
        END

        -- Cambiar el estado de la factura a 'ANULADA'
        UPDATE factura
        SET estado = 'ANULADA'
        WHERE id_factura = @id_factura;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO