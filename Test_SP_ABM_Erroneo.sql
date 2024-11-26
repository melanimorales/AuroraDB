-- 2. Prueba de ingresarSucursal con ciudad vacía (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarSucursal 
        @ciudad = '', 
        @reemplazo = 'Juan Perez', 
        @direccion = 'Av. Libertador 1234', 
        @horario = '9:00 - 18:00', 
        @telefono = '1234567890';
    PRINT 'Test de ingreso con ciudad vacía completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarSucursal (ciudad vacía): ' + ERROR_MESSAGE();
END CATCH;

-- 3. Prueba de ingresarSucursal sin reemplazo (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarSucursal 
        @ciudad = 'Buenos Aires', 
        @reemplazo = NULL, 
        @direccion = 'Av. Libertador 1234', 
        @horario = '9:00 - 18:00', 
        @telefono = '1234567890';
    PRINT 'Test de ingreso sin reemplazo completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarSucursal (sin reemplazo): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de modificarSucursal con id correcto y todos los parámetros (modificación exitosa)
BEGIN TRY
    EXEC rrhh.modificarSucursal 
        @id = 1, 
        @ciudad = 'Cordoba', 
        @reemplazo = 'Carlos Lopez', 
        @direccion = 'Calle Ficticia 456', 
        @horario = '8:00 - 17:00', 
        @telefono = '9876543210';
    PRINT 'Test de modificación con todos los parámetros completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de modificarSucursal: ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de modificarSucursal con un id incorrecto (Error esperado)
BEGIN TRY
    EXEC rrhh.modificarSucursal 
        @id = -1, 
        @ciudad = 'Cordoba', 
        @reemplazo = 'Carlos Lopez', 
        @direccion = 'Calle Ficticia 456', 
        @horario = '8:00 - 17:00', 
        @telefono = '9876543210';
    PRINT 'Test de modificación con id incorrecto completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de modificarSucursal (id incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de modificarSucursal con parámetros nulos (modificación parcial exitosa)
BEGIN TRY
    EXEC rrhh.modificarSucursal 
        @id = 1, 
        @ciudad = NULL, 
        @reemplazo = NULL, 
        @direccion = 'Nueva direccion 789', 
        @horario = NULL, 
        @telefono = '123123123';
    PRINT 'Test de modificación con parámetros nulos completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de modificarSucursal (parámetros nulos): ' + ERROR_MESSAGE();
END CATCH;

-- 7. Prueba de borrarSucursal con id correcto (baja lógica exitosa)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = 1;
    PRINT 'Test de baja lógica completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de borrarSucursal: ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de borrarSucursal con id incorrecto (Error esperado)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = -1;
    PRINT 'Test de baja lógica con id incorrecto completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de borrarSucursal (id incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 9. Prueba de borrarSucursal con id de una sucursal ya dada de baja (baja lógica repetida)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = 1;
    PRINT 'Test de baja lógica repetida completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de borrarSucursal (baja repetida): ' + ERROR_MESSAGE();
END CATCH;






-- 4. Prueba de ingresarEmpleado con DNI duplicado (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Ana', 
        @apellido = 'Martinez', 
        @dni = 12345678, -- Mismo DNI que el Empleado 1
        @direccion = 'Av. Santa Fe 1234', 
        @email_laboral = 'ana.martinez@empresa.com', 
        @cuil = '20-12345678-9', 
        @cargo = 'Contadora', 
        @id_sucursal = 3, 
        @turno = 'TM';
    PRINT 'Test de ingresarEmpleado con DNI duplicado completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (DNI duplicado): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarEmpleado con email inválido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Laura', 
        @apellido = 'Diaz', 
        @dni = 55555555, 
        @direccion = 'Av. Libertador 7890', 
        @email_laboral = 'laura.diaz@empresa', -- Email inválido
        @cuil = '20-55555555-5', 
        @cargo = 'Secretaria', 
        @id_sucursal = 1, 
        @turno = 'TT';
    PRINT 'Test de ingresarEmpleado con email inválido completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (email inválido): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarEmpleado con CUIL inválido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Pedro', 
        @apellido = 'Ruiz', 
        @dni = 33445566, 
        @direccion = 'Calle 123', 
        @email_laboral = 'pedro.ruiz@empresa.com', 
        @cuil = '20-1234567A-9', -- CUIL inválido
        @cargo = 'Vendedor', 
        @id_sucursal = 1, 
        @turno = 'TM';
    PRINT 'Test de ingresarEmpleado con CUIL inválido completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (CUIL inválido): ' + ERROR_MESSAGE();
END CATCH;

-- 7. Prueba de ingresarEmpleado con turno incorrecto (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Roberto', 
        @apellido = 'Fernandez', 
        @dni = 99887766, 
        @direccion = 'Calle Nueva 789', 
        @email_laboral = 'roberto.fernandez@empresa.com', 
        @cuil = '20-99887766-7', 
        @cargo = 'Supervisor', 
        @id_sucursal = 2, 
        @turno = 'Mañana'; -- Turno incorrecto
    PRINT 'Test de ingresarEmpleado con turno incorrecto completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (turno incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de ingresarEmpleado con id_sucursal inválido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Julieta', 
        @apellido = 'Gonzalez', 
        @dni = 77665544, 
        @direccion = 'Av. Independencia 234', 
        @email_laboral = 'julieta.gonzalez@empresa.com', 
        @cuil = '20-77665544-1', 
        @cargo = 'Jefe de RRHH', 
        @id_sucursal = -1, -- ID de sucursal inválido
        @turno = 'TT';
    PRINT 'Test de ingresarEmpleado con id_sucursal inválido completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (id_sucursal inválido): ' + ERROR_MESSAGE();
END CATCH;






-- 3. Prueba de ingresarMedioPago con valor vacío (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '', -- Valor vacío
        @descripcion = 'Pago en efectivo';
    PRINT 'Test de ingresarMedioPago con valor vacío completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor vacío): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de ingresarMedioPago con descripción vacía (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '9876543210', 
        @descripcion = ''; -- Descripción vacía
    PRINT 'Test de ingresarMedioPago con descripción vacía completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripción vacía): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarMedioPago con valor demasiado largo (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '123456789012', -- Valor de más de 11 caracteres
        @descripcion = 'Pago por cheque';
    PRINT 'Test de ingresarMedioPago con valor demasiado largo completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor demasiado largo): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarMedioPago con descripción demasiado larga (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '1234567890', 
        @descripcion = 'Este es un medio de pago con una descripción extremadamente larga que excede el límite de caracteres permitido';
    PRINT 'Test de ingresarMedioPago con descripción demasiado larga completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripción demasiado larga): ' + ERROR_MESSAGE();
END CATCH;

-- 7. Prueba de ingresarMedioPago con valor nulo (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = NULL, -- Valor nulo
        @descripcion = 'Cheque';
    PRINT 'Test de ingresarMedioPago con valor nulo completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor nulo): ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de ingresarMedioPago con descripción nula (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '1234567890', 
        @descripcion = NULL; -- Descripción nula
    PRINT 'Test de ingresarMedioPago con descripción nula completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripción nula): ' + ERROR_MESSAGE();
END CATCH;





-- 2. Prueba de ingresarCategoria con descripción vacía (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = '';  -- Descripción vacía
    PRINT 'Test de ingresarCategoria con descripción vacía completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripción vacía): ' + ERROR_MESSAGE();
END CATCH;

-- 3. Prueba de ingresarCategoria con descripción nula (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = NULL;  -- Descripción nula
    PRINT 'Test de ingresarCategoria con descripción nula completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripción nula): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de ingresarCategoria con descripción demasiado corta (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'A';  -- Descripción con solo un carácter
    PRINT 'Test de ingresarCategoria con descripción demasiado corta completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripción demasiado corta): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarCategoria con descripción demasiado larga (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Esta categoría tiene una descripción excesivamente larga que excede los 30 caracteres permitidos';  -- Descripción demasiado larga
    PRINT 'Test de ingresarCategoria con descripción demasiado larga completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripción demasiado larga): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarCategoria con espacios en blanco solo (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = '     ';  -- Descripción con solo espacios
    PRINT 'Test de ingresarCategoria con espacios en blanco completado con éxito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (espacios en blanco): ' + ERROR_MESSAGE();
END CATCH;
