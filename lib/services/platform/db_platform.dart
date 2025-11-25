import 'db_platform_interface.dart';
import 'db_platform_stub.dart'
    if (dart.library.io) 'db_platform_io.dart'
    if (dart.library.html) 'db_platform_web.dart';

class DbPlatformHelper {
  static final DbPlatform _instance = getPlatformInstance();

  static Future<void> init() => _instance.init();

  static Future<dynamic> connectPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) => _instance.connectPostgres(
    host: host,
    port: port,
    database: database,
    username: username,
    password: password,
  );
}
