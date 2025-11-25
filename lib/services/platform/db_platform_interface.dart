/// Interfaz abstracta para operaciones de base de datos específicas de plataforma
abstract class DbPlatform {
  /// Inicializa la base de datos (por ejemplo, sqflite FFI en desktop)
  Future<void> init();

  /// Conecta a PostgreSQL
  Future<dynamic> connectPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  });
}
