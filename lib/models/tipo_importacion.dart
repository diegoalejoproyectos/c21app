/// Tipos de importación soportados por el sistema
enum TipoImportacion {
  /// Importación de datos de matriz de pagos
  matriz,

  /// Importación de extracto bancario
  extractoBancario;

  /// Nombre legible para mostrar en UI
  String get displayName {
    switch (this) {
      case TipoImportacion.matriz:
        return 'Matriz de Pagos';
      case TipoImportacion.extractoBancario:
        return 'Extracto Bancario';
    }
  }

  /// Nombre de la tabla en la base de datos
  String get tableName {
    switch (this) {
      case TipoImportacion.matriz:
        return 'pagos_matriz';
      case TipoImportacion.extractoBancario:
        return 'movimientos_bancarios';
    }
  }
}
