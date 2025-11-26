import '../../models/validation_error.dart';

/// Estrategia abstracta para importación de datos
///
/// Define el contrato que deben cumplir todas las estrategias de importación.
/// Cada estrategia es responsable de:
/// - Parsear datos crudos a objetos tipados
/// - Validar los datos parseados
/// - Proporcionar información sobre la tabla destino
abstract class ImportStrategy<T> {
  /// Convierte una lista de mapas (datos crudos del CSV/Excel)
  /// a una lista de objetos tipados
  ///
  /// [datos] - Lista de mapas con los datos importados del archivo
  /// Returns lista de objetos parseados del tipo T
  List<T> parsear(List<Map<String, dynamic>> datos);

  /// Valida una lista de objetos parseados
  ///
  /// [items] - Lista de objetos a validar
  /// Returns lista de errores de validación encontrados (vacía si no hay errores)
  List<ValidationError> validar(List<T> items);

  /// Nombre de la tabla en la base de datos donde se guardarán los datos
  String get tableName;

  /// Columnas que definen un conflicto en UPSERT (para PostgreSQL)
  /// Por ejemplo: ['codigo', 'fecha', 'ref_bancaria']
  List<String> get conflictColumns;

  /// Convierte un objeto del tipo T a un mapa para inserción en BD
  ///
  /// [item] - Objeto a convertir
  /// Returns mapa con los campos y valores para la base de datos
  Map<String, dynamic> toMap(T item);
}
