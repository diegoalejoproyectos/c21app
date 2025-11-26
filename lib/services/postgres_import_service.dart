// services/postgres_import_service.dart
import 'package:postgres/postgres.dart';
import '../models/database_config.dart';
import '../models/import_result.dart';

/// Servicio genérico para importar datos a PostgreSQL
///
/// Utiliza el patrón Strategy para trabajar con cualquier tipo de dato
class PostgresImportService {
  /// Importa datos a PostgreSQL usando UPSERT (INSERT ... ON CONFLICT DO UPDATE)
  ///
  /// [items] - Lista de objetos a importar
  /// [config] - Configuración de conexión a PostgreSQL
  /// [tableName] - Nombre de la tabla destino
  /// [conflictColumns] - Columnas que definen un conflicto (para ON CONFLICT)
  /// [toMapFunction] - Función para convertir cada item a Map
  /// Returns resultado de la importación con contadores
  static Future<ImportResult> importarConUpsert<T>({
    required List<T> items,
    required DatabaseConfig config,
    required String tableName,
    required List<String> conflictColumns,
    required Map<String, dynamic> Function(T) toMapFunction,
  }) async {
    if (!config.useRemoteDatabase) {
      return ImportResult(
        success: false,
        message: 'Modo PostgreSQL no habilitado',
        insertedRows: 0,
      );
    }

    if (items.isEmpty) {
      return ImportResult(
        success: false,
        message: 'No hay datos para importar',
        insertedRows: 0,
      );
    }

    Connection? connection;
    int insertados = 0, actualizados = 0, errores = 0;

    try {
      connection = await Connection.open(
        Endpoint(
          host: config.host,
          port: config.port,
          database: config.databaseName,
          username: config.username,
          password: config.password,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
      print('🔗 [PostgresImport] Conexión establecida a PostgreSQL');
      print('📊 [PostgresImport] Tabla: $tableName, Items: ${items.length}');

      // Obtener el primer item para construir la query
      final firstMap = toMapFunction(items.first);
      final columns = firstMap.keys.where((k) => k != 'id').toList();

      // Construir query UPSERT dinámicamente
      final columnsList = columns.join(', ');
      final valuesList = columns.map((c) => '@$c').join(', ');
      final updateList = columns
          .where((c) => !conflictColumns.contains(c))
          .map((c) => '$c = EXCLUDED.$c')
          .join(', ');
      final conflictList = conflictColumns.join(', ');

      final upsertQuery =
          '''
        INSERT INTO $tableName ($columnsList)
        VALUES ($valuesList)
        ON CONFLICT ($conflictList)
        DO UPDATE SET $updateList
        RETURNING xmax = 0 AS inserted;
      ''';

      print('🔍 [PostgresImport] Query generada:');
      print(upsertQuery);

      // Ejecutar UPSERT para cada item
      for (int i = 0; i < items.length; i++) {
        try {
          final map = toMapFunction(items[i]);

          // Remover el ID si existe (será auto-generado)
          map.remove('id');

          final result = await connection.execute(
            Sql.named(upsertQuery),
            parameters: map,
          );

          final inserted = result.first[0] as bool;
          inserted ? insertados++ : actualizados++;

          if (i == 0) {
            print('✅ [PostgresImport] Primer item procesado correctamente');
          }
        } catch (e) {
          errores++;
          print('❌ [PostgresImport] Error en item ${i + 1}: $e');
        }
      }

      print('✅ [PostgresImport] Importación completada:');
      print('   - Insertados: $insertados');
      print('   - Actualizados: $actualizados');
      print('   - Errores: $errores');

      return ImportResult(
        success: true,
        message:
            'Importación completada: $insertados nuevos, $actualizados actualizados',
        insertedRows: insertados,
        updatedRows: actualizados,
        skippedRows: errores,
      );
    } catch (e) {
      print('❌ [PostgresImport] Error durante importación: $e');
      return ImportResult(
        success: false,
        message: 'Error de importación: $e',
        insertedRows: insertados,
        updatedRows: actualizados,
        skippedRows: errores,
      );
    } finally {
      await connection?.close();
      print('🔒 [PostgresImport] Conexión cerrada');
    }
  }

  /// Verifica la conexión a PostgreSQL
  static Future<bool> verificarConexion(DatabaseConfig config) async {
    if (!config.useRemoteDatabase) {
      return false;
    }

    Connection? connection;

    try {
      connection = await Connection.open(
        Endpoint(
          host: config.host,
          port: config.port,
          database: config.databaseName,
          username: config.username,
          password: config.password,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
      await connection.execute('SELECT 1');
      return true;
    } catch (e) {
      print('❌ [PostgresImport] Error de conexión: $e');
      return false;
    } finally {
      await connection?.close();
    }
  }
}
