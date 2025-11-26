import 'package:sqflite/sqflite.dart';
import '../models/import_result.dart';
import 'database_service.dart';

/// Servicio para importar datos a SQLite local
class SqliteImportService {
  /// Importa una lista de items a SQLite usando batch insert
  ///
  /// [items] - Lista de objetos a importar
  /// [tableName] - Nombre de la tabla destino
  /// [toMapFunction] - Función para convertir cada item a Map
  /// Returns resultado de la importación con contadores
  static Future<ImportResult> importar<T>({
    required List<T> items,
    required String tableName,
    required Map<String, dynamic> Function(T) toMapFunction,
  }) async {
    if (items.isEmpty) {
      return ImportResult(
        success: false,
        message: 'No hay datos para importar',
        insertedRows: 0,
      );
    }

    print(
      '🔄 [SqliteImport] Importando ${items.length} registros a $tableName...',
    );

    try {
      final db = await DatabaseService().initLocalDatabase();
      int insertedRows = 0;
      int errorRows = 0;

      // Usar batch para mejor rendimiento
      final batch = db.batch();

      for (final item in items) {
        try {
          final map = toMapFunction(item);
          // Usar REPLACE para manejar conflictos (similar a UPSERT)
          batch.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          insertedRows++;
        } catch (e) {
          errorRows++;
          print('❌ [SqliteImport] Error preparando item: $e');
        }
      }

      // Ejecutar batch
      await batch.commit(noResult: true);

      print(
        '✅ [SqliteImport] Importación completada: $insertedRows insertados, $errorRows errores',
      );

      return ImportResult(
        success: true,
        message:
            'Se importaron $insertedRows de ${items.length} registros a SQLite',
        insertedRows: insertedRows,
        skippedRows: errorRows,
      );
    } catch (e) {
      print('❌ [SqliteImport] Error durante importación: $e');
      return ImportResult(
        success: false,
        message: 'Error al importar a SQLite: $e',
        insertedRows: 0,
      );
    }
  }

  /// Limpia todos los datos de una tabla
  static Future<void> limpiarTabla(String tableName) async {
    try {
      final db = await DatabaseService().initLocalDatabase();
      await db.delete(tableName);
      print('🗑️ [SqliteImport] Tabla $tableName limpiada');
    } catch (e) {
      print('❌ [SqliteImport] Error limpiando tabla $tableName: $e');
    }
  }

  /// Cuenta los registros en una tabla
  static Future<int> contarRegistros(String tableName) async {
    try {
      final db = await DatabaseService().initLocalDatabase();
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('❌ [SqliteImport] Error contando registros en $tableName: $e');
      return 0;
    }
  }
}
