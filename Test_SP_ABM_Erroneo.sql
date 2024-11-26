-- 2. Prueba de ingresarSucursal con ciudad vac�a (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarSucursal 
        @ciudad = '', 
        @reemplazo = 'Juan Perez', 
        @direccion = 'Av. Libertador 1234', 
        @horario = '9:00 - 18:00', 
        @telefono = '1234567890';
    PRINT 'Test de ingreso con ciudad vac�a completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarSucursal (ciudad vac�a): ' + ERROR_MESSAGE();
END CATCH;

-- 3. Prueba de ingresarSucursal sin reemplazo (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarSucursal 
        @ciudad = 'Buenos Aires', 
        @reemplazo = NULL, 
        @direccion = 'Av. Libertador 1234', 
        @horario = '9:00 - 18:00', 
        @telefono = '1234567890';
    PRINT 'Test de ingreso sin reemplazo completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarSucursal (sin reemplazo): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de modificarSucursal con id correcto y todos los par�metros (modificaci�n exitosa)
BEGIN TRY
    EXEC rrhh.modificarSucursal 
        @id = 1, 
        @ciudad = 'Cordoba', 
        @reemplazo = 'Carlos Lopez', 
        @direccion = 'Calle Ficticia 456', 
        @horario = '8:00 - 17:00', 
        @telefono = '9876543210';
    PRINT 'Test de modificaci�n con todos los par�metros completado con �xito.';
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
    PRINT 'Test de modificaci�n con id incorrecto completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de modificarSucursal (id incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de modificarSucursal con par�metros nulos (modificaci�n parcial exitosa)
BEGIN TRY
    EXEC rrhh.modificarSucursal 
        @id = 1, 
        @ciudad = NULL, 
        @reemplazo = NULL, 
        @direccion = 'Nueva direccion 789', 
        @horario = NULL, 
        @telefono = '123123123';
    PRINT 'Test de modificaci�n con par�metros nulos completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de modificarSucursal (par�metros nulos): ' + ERROR_MESSAGE();
END CATCH;

-- 7. Prueba de borrarSucursal con id correcto (baja l�gica exitosa)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = 1;
    PRINT 'Test de baja l�gica completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de borrarSucursal: ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de borrarSucursal con id incorrecto (Error esperado)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = -1;
    PRINT 'Test de baja l�gica con id incorrecto completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de borrarSucursal (id incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 9. Prueba de borrarSucursal con id de una sucursal ya dada de baja (baja l�gica repetida)
BEGIN TRY
    EXEC rrhh.borrarSucursal 
        @id = 1;
    PRINT 'Test de baja l�gica repetida completado con �xito.';
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
    PRINT 'Test de ingresarEmpleado con DNI duplicado completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (DNI duplicado): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarEmpleado con email inv�lido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Laura', 
        @apellido = 'Diaz', 
        @dni = 55555555, 
        @direccion = 'Av. Libertador 7890', 
        @email_laboral = 'laura.diaz@empresa', -- Email inv�lido
        @cuil = '20-55555555-5', 
        @cargo = 'Secretaria', 
        @id_sucursal = 1, 
        @turno = 'TT';
    PRINT 'Test de ingresarEmpleado con email inv�lido completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (email inv�lido): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarEmpleado con CUIL inv�lido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Pedro', 
        @apellido = 'Ruiz', 
        @dni = 33445566, 
        @direccion = 'Calle 123', 
        @email_laboral = 'pedro.ruiz@empresa.com', 
        @cuil = '20-1234567A-9', -- CUIL inv�lido
        @cargo = 'Vendedor', 
        @id_sucursal = 1, 
        @turno = 'TM';
    PRINT 'Test de ingresarEmpleado con CUIL inv�lido completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (CUIL inv�lido): ' + ERROR_MESSAGE();
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
        @turno = 'Ma�ana'; -- Turno incorrecto
    PRINT 'Test de ingresarEmpleado con turno incorrecto completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (turno incorrecto): ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de ingresarEmpleado con id_sucursal inv�lido (Error esperado)
BEGIN TRY
    EXEC rrhh.ingresarEmpleado 
        @nombre = 'Julieta', 
        @apellido = 'Gonzalez', 
        @dni = 77665544, 
        @direccion = 'Av. Independencia 234', 
        @email_laboral = 'julieta.gonzalez@empresa.com', 
        @cuil = '20-77665544-1', 
        @cargo = 'Jefe de RRHH', 
        @id_sucursal = -1, -- ID de sucursal inv�lido
        @turno = 'TT';
    PRINT 'Test de ingresarEmpleado con id_sucursal inv�lido completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarEmpleado (id_sucursal inv�lido): ' + ERROR_MESSAGE();
END CATCH;






-- 3. Prueba de ingresarMedioPago con valor vac�o (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '', -- Valor vac�o
        @descripcion = 'Pago en efectivo';
    PRINT 'Test de ingresarMedioPago con valor vac�o completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor vac�o): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de ingresarMedioPago con descripci�n vac�a (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '9876543210', 
        @descripcion = ''; -- Descripci�n vac�a
    PRINT 'Test de ingresarMedioPago con descripci�n vac�a completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripci�n vac�a): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarMedioPago con valor demasiado largo (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '123456789012', -- Valor de m�s de 11 caracteres
        @descripcion = 'Pago por cheque';
    PRINT 'Test de ingresarMedioPago con valor demasiado largo completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor demasiado largo): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarMedioPago con descripci�n demasiado larga (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '1234567890', 
        @descripcion = 'Este es un medio de pago con una descripci�n extremadamente larga que excede el l�mite de caracteres permitido';
    PRINT 'Test de ingresarMedioPago con descripci�n demasiado larga completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripci�n demasiado larga): ' + ERROR_MESSAGE();
END CATCH;

-- 7. Prueba de ingresarMedioPago con valor nulo (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = NULL, -- Valor nulo
        @descripcion = 'Cheque';
    PRINT 'Test de ingresarMedioPago con valor nulo completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (valor nulo): ' + ERROR_MESSAGE();
END CATCH;

-- 8. Prueba de ingresarMedioPago con descripci�n nula (Error esperado)
BEGIN TRY
    EXEC op.ingresarMedioPago 
        @valor = '1234567890', 
        @descripcion = NULL; -- Descripci�n nula
    PRINT 'Test de ingresarMedioPago con descripci�n nula completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarMedioPago (descripci�n nula): ' + ERROR_MESSAGE();
END CATCH;





-- 2. Prueba de ingresarCategoria con descripci�n vac�a (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = '';  -- Descripci�n vac�a
    PRINT 'Test de ingresarCategoria con descripci�n vac�a completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripci�n vac�a): ' + ERROR_MESSAGE();
END CATCH;

-- 3. Prueba de ingresarCategoria con descripci�n nula (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = NULL;  -- Descripci�n nula
    PRINT 'Test de ingresarCategoria con descripci�n nula completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripci�n nula): ' + ERROR_MESSAGE();
END CATCH;

-- 4. Prueba de ingresarCategoria con descripci�n demasiado corta (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'A';  -- Descripci�n con solo un car�cter
    PRINT 'Test de ingresarCategoria con descripci�n demasiado corta completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripci�n demasiado corta): ' + ERROR_MESSAGE();
END CATCH;

-- 5. Prueba de ingresarCategoria con descripci�n demasiado larga (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = 'Esta categor�a tiene una descripci�n excesivamente larga que excede los 30 caracteres permitidos';  -- Descripci�n demasiado larga
    PRINT 'Test de ingresarCategoria con descripci�n demasiado larga completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (descripci�n demasiado larga): ' + ERROR_MESSAGE();
END CATCH;

-- 6. Prueba de ingresarCategoria con espacios en blanco solo (Error esperado)
BEGIN TRY
    EXEC op.ingresarCategoria 
        @descripcion = '     ';  -- Descripci�n con solo espacios
    PRINT 'Test de ingresarCategoria con espacios en blanco completado con �xito.';
END TRY
BEGIN CATCH
    PRINT 'Error en el test de ingresarCategoria (espacios en blanco): ' + ERROR_MESSAGE();
END CATCH;
