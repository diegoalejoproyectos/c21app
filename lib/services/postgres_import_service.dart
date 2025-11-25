// services/postgres_import_service.dart
import 'package:postgres/postgres.dart';
import '../models/movimiento_bancario.dart';
import '../models/database_config.dart';

class PostgresImportService {
  /// Convierte datos importados a objetos MovimientoBancario
  static List<MovimientoBancario> parseMovimientosBancarios(
    List<Map<String, dynamic>> datosImportados,
  ) {
    print('🔄 Parseando ${datosImportados.length} registros...');
    final movimientos = <MovimientoBancario>[];
    int successCount = 0, errorCount = 0;

    for (int i = 0; i < datosImportados.length; i++) {
      try {
        final movimiento = MovimientoBancario.fromMap(datosImportados[i]);
        movimientos.add(movimiento);
        successCount++;

        if (i == 0) {
          print('✅ Primer movimiento parseado: ${movimiento.toString()}');
        }
      } catch (e) {
        errorCount++;
        print('❌ Error parseando fila $i: $e');
        print('Datos de la fila: ${datosImportados[i]}');
      }
    }

    print('📊 Parseo completado: $successCount éxitos, $errorCount errores');
    return movimientos;
  }

  /// Validación estricta de movimientos
  static List<ValidationError> validarMovimientos(
    List<MovimientoBancario> movimientos,
  ) {
    print('🔍 Validando ${movimientos.length} movimientos...');
    final errors = <ValidationError>[];

    for (int i = 0; i < movimientos.length; i++) {
      final mov = movimientos[i];

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

    print('📊 Validación completada: ${errors.length} errores encontrados');
    return errors;
  }

  /// Validación relajada solo para debugging
  static List<ValidationError> validarMovimientosRelajada(
    List<MovimientoBancario> movimientos,
  ) {
    print('🔍 Validación RELAJADA de ${movimientos.length} movimientos...');
    final errors = <ValidationError>[];

    for (int i = 0; i < movimientos.length; i++) {
      final mov = movimientos[i];
      if (mov.codigo <= 0) {
        errors.add(
          ValidationError(
            row: i + 1,
            field: 'codigo',
            message: 'Código debe ser mayor a 0',
          ),
        );
      }
    }

    print(
      '📊 Validación relajada completada: ${errors.length} errores encontrados',
    );
    return errors;
  }

  /// Importación simple (solo inserción)
  static Future<ImportResult> importarMovimientosBancarios({
    required List<MovimientoBancario> movimientos,
    required DatabaseConfig config,
  }) async {
    if (!config.useRemoteDatabase) {
      return ImportResult(
        success: false,
        message: 'Modo PostgreSQL no habilitado',
        insertedRows: 0,
      );
    }

    PostgreSQLConnection? connection;
    int insertedRows = 0, errorRows = 0;

    try {
      connection = PostgreSQLConnection(
        config.host,
        config.port,
        config.databaseName,
        username: config.username,
        password: config.password,
      );

      await connection.open();
      print('🔗 Conexión establecida a PostgreSQL');

      const insertQuery = '''
        INSERT INTO movimientos_bancarios
        (codigo, fecha, depto, detalle, ref_bancaria, monto)
        VALUES (@codigo, @fecha, @depto, @detalle, @ref_bancaria, @monto)
      ''';

      for (int i = 0; i < movimientos.length; i++) {
        try {
          await connection.execute(
            insertQuery,
            substitutionValues: {
              'codigo': movimientos[i].codigo,
              'fecha': movimientos[i].fecha,
              'depto': movimientos[i].depto,
              'detalle': movimientos[i].detalle,
              'ref_bancaria': movimientos[i].refBancaria,
              'monto': movimientos[i].monto,
            },
          );
          insertedRows++;
        } catch (e) {
          errorRows++;
          print('❌ Error insertando fila ${i + 1}: $e');
        }
      }

      print(
        '✅ Importación completada: $insertedRows insertados, $errorRows errores',
      );
      return ImportResult(
        success: true,
        message:
            'Se importaron $insertedRows de ${movimientos.length} registros',
        insertedRows: insertedRows,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Error: $e',
        insertedRows: insertedRows,
      );
    } finally {
      await connection?.close();
      print('🔒 Conexión cerrada');
    }
  }

  /// UPSERT: Inserta nuevos o actualiza existentes
  static Future<ImportResult> importarMovimientosConUpsert({
    required List<MovimientoBancario> movimientos,
    required DatabaseConfig config,
  }) async {
    PostgreSQLConnection? connection;
    int insertados = 0, actualizados = 0;

    try {
      connection = PostgreSQLConnection(
        config.host,
        config.port,
        config.databaseName,
        username: config.username,
        password: config.password,
      );

      await connection.open();
      print('🔗 Conexión establecida a PostgreSQL (UPSERT)');

      const upsertQuery = '''
        INSERT INTO movimientos_bancarios (
          codigo, fecha, depto, detalle, ref_bancaria, monto
        ) VALUES (
          @codigo, @fecha, @depto, @detalle, @ref_bancaria, @monto
        )
        ON CONFLICT (codigo, fecha, ref_bancaria)
        DO UPDATE SET
          depto = EXCLUDED.depto,
          detalle = EXCLUDED.detalle,
          monto = EXCLUDED.monto
        RETURNING xmax = 0 AS inserted;
      ''';

      for (final m in movimientos) {
        final result = await connection.query(
          upsertQuery,
          substitutionValues: {
            'codigo': m.codigo,
            'fecha': m.fecha,
            'depto': m.depto,
            'detalle': m.detalle,
            'ref_bancaria': m.refBancaria,
            'monto': m.monto,
          },
        );

        final inserted = result.first[0] as bool;
        inserted ? insertados++ : actualizados++;
      }

      return ImportResult(
        success: true,
        message:
            "inserción completada: $insertados nuevos, $actualizados actualizados",
        insertedRows: insertados,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: "Error de inserción: $e",
        insertedRows: insertados,
      );
    } finally {
      await connection?.close();
      print('🔒 Conexión cerrada (inserción)');
    }
  }
}

/// Resultado de importación
class ImportResult {
  final bool success;
  final String message;
  final int insertedRows;

  ImportResult({
    required this.success,
    required this.message,
    required this.insertedRows,
  });
}

/// Error de validación
class ValidationError {
  final int row;
  final String field;
  final String message;

  ValidationError({
    required this.row,
    required this.field,
    required this.message,
  });

  @override
  String toString() => 'Fila $row, Campo $field: $message';
}
