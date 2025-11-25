import 'db_platform_interface.dart';

/// Implementación Stub (se usa cuando no hay implementación específica)
class DbPlatformStub implements DbPlatform {
  @override
  Future<void> init() async {
    // No-op
  }

  @override
  Future<dynamic> connectPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    throw UnsupportedError('PostgreSQL no soportado en esta plataforma');
  }
}

DbPlatform getPlatformInstance() => DbPlatformStub();
