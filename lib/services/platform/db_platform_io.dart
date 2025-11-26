import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:postgres/postgres.dart';
import 'dart:io';
import 'db_platform_interface.dart';

/// Implementación para Desktop/Mobile (IO)
class DbPlatformIO implements DbPlatform {
  @override
  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  @override
  Future<dynamic> connectPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    final connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return connection;
  }
}

DbPlatform getPlatformInstance() => DbPlatformIO();
