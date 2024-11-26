use Com2900G04;
go

EXEC op.importarMediosPago @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx';
go
SELECT * FROM op.medioPago;
go

EXEC op.importarClasificacionProducto @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx';
go
SELECT * FROM op.clasificacionProducto;
go

EXEC rrhh.importarSucursales @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx';
go
SELECT * FROM rrhh.sucursal;
go

EXEC rrhh.importarEmpleados @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Informacion_complementaria.xlsx';
go
SELECT * FROM rrhh.empleado;
go

EXEC func.registrarValorDolar 1130;
go
EXEC op.importarElectronicAccessories @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
go
SELECT * FROM op.producto;
go

EXEC op.importarProductosImportados @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Productos\Productos_importados.xlsx';
go
SELECT * FROM op.producto;
go

EXEC op.importarCatalogo @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Productos\';
go
SELECT * FROM op.producto;
go

EXEC rrhh.importarVentasRegistradas @ruta = N'T:\Documentos\UNLaM\Base_datos_aplicada\TP\TP_integrador_Archivos\Ventas_registradas.csv';
go