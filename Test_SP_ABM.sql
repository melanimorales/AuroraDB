use Com2900G04;
go

BEGIN TRY
    EXEC rrhh.ingresarSucursal 
        @ciudad = 'Buenos Aires', 
        @reemplazo = 'Juan Perez', 
        @direccion = 'Av. Libertador 1234', 
        @horario = '9:00 - 18:00', 
        @telefono = '1234567890';
    PRINT 'Test de ingreso correcto completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarSucursal: ' + ERROR_MESSAGE();
END CATCH;




-- Insertar empleados

BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Juan', 
        @apellido = 'Perez', 
        @dni = 12345678, 
        @direccion = 'Av. Corrientes 1000', 
        @email_laboral = 'juan.perez@empresa.com', 
        @cuil = '20-12345678-9', 
        @cargo = 'Analista', 
        @id_sucursal = 1, 
        @turno = 'TM';
    PRINT 'Test de ingresarEmpleado (Empleado 1) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (Empleado 1): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Maria', 
        @apellido = 'Gomez', 
        @dni = 87654321, 
        @direccion = 'Calle Falsa 123', 
        @email_laboral = 'maria.gomez@empresa.com', 
        @cuil = '20-87654321-9', 
        @cargo = 'Desarrolladora', 
        @id_sucursal = 2, 
        @turno = 'TT';
    PRINT 'Test de ingresarEmpleado (Empleado 2) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (Empleado 2): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Carlos', 
        @apellido = 'Lopez', 
        @dni = 11223344, 
        @direccion = 'Calle Principal 456', 
        @email_laboral = 'carlos.lopez@empresa.com', 
        @cuil = '20-11223344-3', 
        @cargo = 'Gerente', 
        @id_sucursal = 1, 
        @turno = 'Jornada completa';
    PRINT 'Test de ingresarEmpleado (Empleado 3) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (Empleado 3): ' + ERROR_MESSAGE();
END CATCH;





------Medio Pago-------

BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '12345678901', 
        @descripcion = 'Tarjeta de cr�dito';
    PRINT 'Test de ingresarMedioPago (Medio de pago 1) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (Medio de pago 1): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '1234567890', 
        @descripcion = 'Transferencia bancaria';
    PRINT 'Test de ingresarMedioPago (Medio de pago 2) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (Medio de pago 2): ' + ERROR_MESSAGE();
END CATCH;






-----Categoria-----
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Electr�nica';
    PRINT 'Test de ingresarCategoria (Electr�nica) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Electr�nica): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Ropa y Accesorios';
    PRINT 'Test de ingresarCategoria (Ropa y Accesorios) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Ropa y Accesorios): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Alimentos y Bebidas';
    PRINT 'Test de ingresarCategoria (Alimentos y Bebidas) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Alimentos y Bebidas): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Tecnolog�a';
    PRINT 'Test de ingresarCategoria (Tecnolog�a) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Tecnolog�a): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Juguetes y Juegos';
    PRINT 'Test de ingresarCategoria (Juguetes y Juegos) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Juguetes y Juegos): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Herramientas y Accesorios';
    PRINT 'Test de ingresarCategoria (Herramientas y Accesorios) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (Herramientas y Accesorios): ' + ERROR_MESSAGE();
END CATCH;





-----Proveedor-----

BEGIN TRY
    EXEC op.ingresarProveedor 
        @nombre = 'Proveedor A';
    PRINT 'Test de ingresarProveedor (Proveedor A) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarProveedor (Proveedor A): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarProveedor 
        @nombre = 'Distribuidora XYZ';
    PRINT 'Test de ingresarProveedor (Distribuidora XYZ) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarProveedor (Distribuidora XYZ): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarProveedor 
        @nombre = 'Suministros Globales';
    PRINT 'Test de ingresarProveedor (Suministros Globales) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarProveedor (Suministros Globales): ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC op.ingresarProveedor 
        @nombre = 'Tecnolog�a Plus S.A.';
    PRINT 'Test de ingresarProveedor (Tecnolog�a Plus S.A.) completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarProveedor (Tecnolog�a Plus S.A.): ' + ERROR_MESSAGE();
END CATCH;






-----Productos-----

-- Producto 1
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Laptop HP', 
        @nombre_categoria = 'Electr�nica',
        @precio = 500.00,
        @precio_referencia = 600.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 550.00,
        @nombre_proveedor = 'Proveedor A';
    PRINT 'Producto 1 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 1: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 2
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Mouse inal�mbrico', 
        @nombre_categoria = 'Accesorios',
        @precio = 25.00,
        @precio_referencia = 30.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 28.00,
        @nombre_proveedor = 'Distribuidora XYZ';
    PRINT 'Producto 2 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 2: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 3
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Teclado mec�nico', 
        @nombre_categoria = 'Accesorios',
        @precio = 80.00,
        @precio_referencia = 100.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 85.00,
        @nombre_proveedor = 'Tecnolog�a Plus';
    PRINT 'Producto 3 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 3: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 4
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Monitor 24 pulgadas', 
        @nombre_categoria = 'Electr�nica',
        @precio = 150.00,
        @precio_referencia = 200.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 160.00,
        @nombre_proveedor = 'Proveedor A';
    PRINT 'Producto 4 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 4: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 5
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Auriculares Sony', 
        @nombre_categoria = 'Accesorios',
        @precio = 70.00,
        @precio_referencia = 90.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 75.00,
        @nombre_proveedor = 'Distribuidora XYZ';
    PRINT 'Producto 5 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 5: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 6
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Smartphone Xiaomi', 
        @nombre_categoria = 'Electr�nica',
        @precio = 300.00,
        @precio_referencia = 350.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 310.00,
        @nombre_proveedor = 'Tecnolog�a Plus';
    PRINT 'Producto 6 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 6: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 7
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Tablet Samsung', 
        @nombre_categoria = 'Electr�nica',
        @precio = 220.00,
        @precio_referencia = 260.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 230.00,
        @nombre_proveedor = 'Proveedor A';
    PRINT 'Producto 7 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 7: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 8
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Cargador r�pido', 
        @nombre_categoria = 'Accesorios',
        @precio = 15.00,
        @precio_referencia = 20.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 17.00,
        @nombre_proveedor = 'Distribuidora XYZ';
    PRINT 'Producto 8 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 8: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 9
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Estuche para laptop', 
        @nombre_categoria = 'Accesorios',
        @precio = 25.00,
        @precio_referencia = 35.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 28.00,
        @nombre_proveedor = 'Tecnolog�a Plus';
    PRINT 'Producto 9 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 9: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 10
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Webcam Logitech', 
        @nombre_categoria = 'Accesorios',
        @precio = 50.00,
        @precio_referencia = 70.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 55.00,
        @nombre_proveedor = 'Distribuidora XYZ';
    PRINT 'Producto 10 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 10: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 11
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Silla ergon�mica', 
        @nombre_categoria = 'Muebles',
        @precio = 120.00,
        @precio_referencia = 150.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 125.00,
        @nombre_proveedor = 'Suministros Globales';
    PRINT 'Producto 11 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 11: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 12
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Escritorio oficina', 
        @nombre_categoria = 'Muebles',
        @precio = 200.00,
        @precio_referencia = 250.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 210.00,
        @nombre_proveedor = 'Suministros Globales';
    PRINT 'Producto 12 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 12: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 13
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'L�mpara LED', 
        @nombre_categoria = 'Muebles',
        @precio = 45.00,
        @precio_referencia = 55.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 48.00,
        @nombre_proveedor = 'Mobiliarios S.A.';
    PRINT 'Producto 13 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 13: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 14
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Cafetera el�ctrica', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 80.00,
        @precio_referencia = 100.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 85.00,
        @nombre_proveedor = 'Muebles y Equipos';
    PRINT 'Producto 14 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 14: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 15
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Tetera el�ctrica', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 40.00,
        @precio_referencia = 50.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 42.00,
        @nombre_proveedor = 'Muebles y Equipos';
    PRINT 'Producto 15 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 15: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 16
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Licuadora', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 60.00,
        @precio_referencia = 75.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 63.00,
        @nombre_proveedor = 'Muebles y Equipos';
    PRINT 'Producto 16 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 16: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 17
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Aspiradora', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 150.00,
        @precio_referencia = 180.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 155.00,
        @nombre_proveedor = 'Muebles y Equipos';
    PRINT 'Producto 17 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 17: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 18
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Ventilador', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 30.00,
        @precio_referencia = 40.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 32.00,
        @nombre_proveedor = 'Muebles y Equipos';
    PRINT 'Producto 18 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 18: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 19
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Secador de cabello', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 20.00,
        @precio_referencia = 30.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 22.00,
        @nombre_proveedor = 'Electrodom�sticos S.A.';
    PRINT 'Producto 19 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 19: ' + ERROR_MESSAGE();
END CATCH;

-- Producto 20
BEGIN TRY
    EXEC op.ingresarProducto 
        @nombre = 'Plancha de ropa', 
        @nombre_categoria = 'Electrodom�sticos',
        @precio = 25.00,
        @precio_referencia = 35.00,
        @unidad_referencia = 'Unidad',
        @cantidad_unidad = '1',
        @precio_dolares = 27.00,
        @nombre_proveedor = 'Electrodom�sticos S.A.';
    PRINT 'Producto 20 ingresado exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en el Producto 20: ' + ERROR_MESSAGE();
END CATCH;







-- Venta 1
BEGIN TRY
    EXEC op.ingresarVenta 
        @tipo_factura = 'A', 
        @id_sucursal = 1,
        @tipo_cliente = 'F',
        @genero = 'M',
        @id_producto = 3,  -- Sup�n que el producto con ID 3 es v�lido
        @cantidad = 2,
        @fecha = '2024-11-01 14:30',
        @id_medio_pago = 2,  -- Sup�n que el medio de pago con ID 2 es v�lido
        @legajo_empleado = 101,
        @identificador_pago = 'IDP000123456789012345';
    PRINT 'Venta 1 ingresada exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en la Venta 1: ' + ERROR_MESSAGE();
END CATCH;

-- Venta 2
BEGIN TRY
    EXEC op.ingresarVenta 
        @tipo_factura = 'B', 
        @id_sucursal = 1,
        @tipo_cliente = 'J',
        @genero = 'F',
        @id_producto = 5,  -- Sup�n que el producto con ID 5 es v�lido
        @cantidad = 3,
        @fecha = '2024-11-02 09:15',
        @id_medio_pago = 2,  -- Sup�n que el medio de pago con ID 3 es v�lido
        @legajo_empleado = 102,
        @identificador_pago = 'IDP001234567890123456';
    PRINT 'Venta 2 ingresada exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en la Venta 2: ' + ERROR_MESSAGE();
END CATCH;

-- Venta 3
BEGIN TRY
    EXEC op.ingresarVenta 
        @tipo_factura = 'A', 
        @id_sucursal = 1,
        @tipo_cliente = 'F',
        @genero = 'M',
        @id_producto = 7,  -- Sup�n que el producto con ID 7 es v�lido
        @cantidad = 1,
        @fecha = '2024-11-03 17:45',
        @id_medio_pago = 1,  -- Sup�n que el medio de pago con ID 1 es v�lido
        @legajo_empleado = 103,
        @identificador_pago = 'IDP002345678901234567';
    PRINT 'Venta 3 ingresada exitosamente.';
END TRY
BEGIN CATCH
    PRINT 'Error en la Venta 3: ' + ERROR_MESSAGE();
END CATCH;
