import '../../models/movimiento_bancario.dart';
import '../../models/validation_error.dart';
import 'import_strategy.dart';

/// Estrategia de importación para datos de Extracto Bancario
class ExtractoStrategy implements ImportStrategy<MovimientoBancario> {
  @override
  String get tableName => 'movimientos_bancarios';

  @override
  List<String> get conflictColumns => ['codigo', 'fecha', 'ref_bancaria'];

  @override
  List<MovimientoBancario> parsear(List<Map<String, dynamic>> datos) {
    print('🔄 [ExtractoStrategy] Parseando ${datos.length} registros...');
    final movimientos = <MovimientoBancario>[];
    int successCount = 0, errorCount = 0;

    for (int i = 0; i < datos.length; i++) {
      try {
        final movimiento = MovimientoBancario.fromMap(datos[i]);
        movimientos.add(movimiento);
        successCount++;

        if (i == 0) {
          print(
            '✅ [ExtractoStrategy] Primer movimiento parseado: ${movimiento.toString()}',
          );
        }
      } catch (e) {
        errorCount++;
        print('❌ [ExtractoStrategy] Error parseando fila $i: $e');
        print('Datos de la fila: ${datos[i]}');
      }
    }

    print(
      '📊 [ExtractoStrategy] Parseo completado: $successCount éxitos, $errorCount errores',
    );
    return movimientos;
  }

  @override
  List<ValidationError> validar(List<MovimientoBancario> items) {
    print('🔍 [ExtractoStrategy] Validando ${items.length} movimientos...');
    final errors = <ValidationError>[];

    for (int i = 0; i < items.length; i++) {
      final mov = items[i];

      // Validar campos requeridos
      if (mov.codigo <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'codigo',
            message: 'Código debe ser mayor a 0',
          ),
        );
      }

      if (mov.depto.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'depto',
            message: 'Departamento no puede estar vacío',
          ),
        );
      }

      if (mov.detalle.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'detalle',
            message: 'Detalle no puede estar vacío',
          ),
        );
      }

      if (mov.refBancaria.isEmpty) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'ref_bancaria',
            message: 'Referencia bancaria no puede estar vacía',
          ),
        );
      }

      if (mov.monto == 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'monto',
            message: 'Monto no puede ser 0',
          ),
        );
      }
    }

    print(
      '📊 [ExtractoStrategy] Validación completada: ${errors.length} errores encontrados',
    );
    return errors;
  }

  @override
  Map<String, dynamic> toMap(MovimientoBancario item) {
    return item.toMap();
  }
}
