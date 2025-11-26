/// Resultado de una operación de importación a base de datos
class ImportResult {
  /// Indica si la operación fue exitosa
  final bool success;

  /// Mensaje descriptivo del resultado
  final String message;

  /// Número de filas insertadas
  final int insertedRows;

  /// Número de filas actualizadas (opcional, para UPSERT)
  final int? updatedRows;

  /// Número de filas omitidas por errores (opcional)
  final int? skippedRows;

  ImportResult({
    required this.success,
    required this.message,
    required this.insertedRows,
    this.updatedRows,
    this.skippedRows,
  });

  /// Total de filas procesadas
  int get totalProcessed => insertedRows + (updatedRows ?? 0);
}
