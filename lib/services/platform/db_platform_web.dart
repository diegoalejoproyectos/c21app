import 'db_platform_interface.dart';

/// Implementación para Web
class DbPlatformWeb implements DbPlatform {
  @override
  Future<void> init() async {
    // No inicializar sqflite FFI en web
  }

  @override
  Future<dynamic> connectPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    // PostgreSQL directo no soportado en web sin proxy/websocket
    throw UnsupportedError('Conexión directa a PostgreSQL no soportada en Web');
  }
}

DbPlatform getPlatformInstance() => DbPlatformWeb();
