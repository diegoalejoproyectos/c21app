import '../../models/matriz.dart';
import '../../models/validation_error.dart';
import 'import_strategy.dart';

/// Estrategia de importación para datos de Matriz de Pagos
class MatrizStrategy implements ImportStrategy<PagoMatriz> {
  @override
  String get tableName => 'pagos_matriz';

  @override
  List<String> get conflictColumns => ['nro', 'carnet', 'nro_factura'];

  @override
  List<PagoMatriz> parsear(List<Map<String, dynamic>> datos) {
    print('🔄 [MatrizStrategy] Parseando ${datos.length} registros...');
    final pagos = <PagoMatriz>[];
    int successCount = 0, errorCount = 0;

    for (int i = 0; i < datos.length; i++) {
      try {
        final pago = PagoMatriz.fromMap(datos[i]);
        pagos.add(pago);
        successCount++;

        if (i == 0) {
          print('✅ [MatrizStrategy] Primer pago parseado: ${pago.toString()}');
        }
      } catch (e) {
        errorCount++;
        print('❌ [MatrizStrategy] Error parseando fila $i: $e');
        print('Datos de la fila: ${datos[i]}');
      }
    }

    print(
      '📊 [MatrizStrategy] Parseo completado: $successCount éxitos, $errorCount errores',
    );
    return pagos;
  }

  @override
  List<ValidationError> validar(List<PagoMatriz> items) {
    print('🔍 [MatrizStrategy] Validando ${items.length} pagos...');
    final errors = <ValidationError>[];

    for (int i = 0; i < items.length; i++) {
      final pago = items[i];

      // Validar campos requeridos
      if (pago.nro <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'nro',
            message: 'Número debe ser mayor a 0',
          ),
        );
      }

      if (pago.usuario.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'usuario',
            message: 'Usuario no puede estar vacío',
          ),
        );
      }

      if (pago.nroFactura <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'nro_factura',
            message: 'Número de factura debe ser mayor a 0',
          ),
        );
      }

      if (pago.carnet.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'carnet',
            message: 'Carnet no puede estar vacío',
          ),
        );
      }

      if (pago.nombres.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'nombres',
            message: 'Nombres no puede estar vacío',
          ),
        );
      }

      if (pago.codPago <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'cod_pago',
            message: 'Código de pago debe ser mayor a 0',
          ),
        );
      }

      if (pago.montoTotal <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'monto_total',
            message: 'Monto total debe ser mayor a 0',
          ),
        );
      }
    }

    print(
      '📊 [MatrizStrategy] Validación completada: ${errors.length} errores encontrados',
    );
    return errors;
  }

  @override
  Map<String, dynamic> toMap(PagoMatriz item) {
    return item.toMap();
  }
}
