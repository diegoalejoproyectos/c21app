/// Error de validación encontrado durante el parseo o validación de datos
class ValidationError {
  /// Número de fila donde ocurrió el error (1-indexed)
  final int row;

  /// Campo que causó el error
  final String field;

  /// Mensaje descriptivo del error
  final String message;

  ValidationError({
    required this.row,
    required this.field,
    required this.message,
  });

  @override
  String toString() => 'Fila $row, Campo $field: $message';
}
