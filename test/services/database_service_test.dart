import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c21app/models/database_config.dart';
import 'package:c21app/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService', () {
    late DatabaseService service;

    setUp(() {
      service = DatabaseService();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await service.clearConfig();
    });

    test('getConfig returns default config when no config saved', () async {
      final config = await service.getConfig();

      expect(config.useRemoteDatabase, false);
      expect(config.host, 'localhost');
      expect(config.port, 5432);
    });

    test('saveConfig persists configuration', () async {
      final testConfig = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'test.example.com',
        port: 5433,
        databaseName: 'testdb',
        username: 'testuser',
        password: 'testpass',
      );

      await service.saveConfig(testConfig);
      final retrieved = await service.getConfig();

      expect(retrieved.useRemoteDatabase, testConfig.useRemoteDatabase);
      expect(retrieved.host, testConfig.host);
      expect(retrieved.port, testConfig.port);
      expect(retrieved.databaseName, testConfig.databaseName);
      expect(retrieved.username, testConfig.username);
      expect(retrieved.password, testConfig.password);
    });

    test('saveConfig updates cached config', () async {
      final config1 = DatabaseConfig(
        useRemoteDatabase: false,
        host: 'localhost',
        port: 5432,
        databaseName: 'db1',
        username: 'user1',
        password: 'pass1',
      );

      await service.saveConfig(config1);
      final retrieved1 = await service.getConfig();
      expect(retrieved1.databaseName, 'db1');

      final config2 = config1.copyWith(databaseName: 'db2');
      await service.saveConfig(config2);
      final retrieved2 = await service.getConfig();
      expect(retrieved2.databaseName, 'db2');
    });

    test('clearConfig removes saved configuration', () async {
      final testConfig = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'example.com',
        port: 5432,
        databaseName: 'mydb',
        username: 'user',
        password: 'pass',
      );

      await service.saveConfig(testConfig);
      await service.clearConfig();
      final retrieved = await service.getConfig();

      // Should return default config after clearing
      expect(retrieved.useRemoteDatabase, false);
    });

    test('testPostgresConnection returns false for SQLite mode', () async {
      final sqliteConfig = DatabaseConfig(
        useRemoteDatabase: false,
        host: 'localhost',
        port: 5432,
        databaseName: 'test',
        username: 'user',
        password: 'pass',
      );

      final result = await service.testPostgresConnection(sqliteConfig);
      expect(result, false);
    });

    test('testPostgresConnection validates required fields', () async {
      // Missing host
      final config1 = DatabaseConfig(
        useRemoteDatabase: true,
        host: '',
        port: 5432,
        databaseName: 'test',
        username: 'user',
        password: 'pass',
      );
      expect(await service.testPostgresConnection(config1), false);

      // Missing database name
      final config2 = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'localhost',
        port: 5432,
        databaseName: '',
        username: 'user',
        password: 'pass',
      );
      expect(await service.testPostgresConnection(config2), false);

      // Missing username
      final config3 = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'localhost',
        port: 5432,
        databaseName: 'test',
        username: '',
        password: 'pass',
      );
      expect(await service.testPostgresConnection(config3), false);
    });

    test(
      'testPostgresConnection handles connection errors gracefully',
      () async {
        // Invalid host should return false, not throw
        final invalidConfig = DatabaseConfig(
          useRemoteDatabase: true,
          host: 'invalid.host.that.does.not.exist.12345',
          port: 5432,
          databaseName: 'test',
          username: 'user',
          password: 'pass',
        );

        final result = await service.testPostgresConnection(invalidConfig);
        expect(result, false);
      },
    );

    test('initLocalDatabase creates database', () async {
      final db = await service.initLocalDatabase();
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('initLocalDatabase returns same instance on multiple calls', () async {
      final db1 = await service.initLocalDatabase();
      final db2 = await service.initLocalDatabase();
      expect(identical(db1, db2), true);
    });

    test('closeLocalDatabase closes the database', () async {
      await service.initLocalDatabase();
      await service.closeLocalDatabase();
      // After closing, next call should create new instance
      final db = await service.initLocalDatabase();
      expect(db.isOpen, true);
    });

    test('singleton pattern returns same instance', () {
      final service1 = DatabaseService();
      final service2 = DatabaseService();
      expect(identical(service1, service2), true);
    });

    test('config persistence survives service recreation', () async {
      final testConfig = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'persistent.example.com',
        port: 5433,
        databaseName: 'persistdb',
        username: 'persistuser',
        password: 'persistpass',
      );

      await service.saveConfig(testConfig);

      // Create new service instance (simulating app restart)
      final newService = DatabaseService();
      final retrieved = await newService.getConfig();

      expect(retrieved.host, 'persistent.example.com');
      expect(retrieved.port, 5433);
      expect(retrieved.databaseName, 'persistdb');
    });
  });
}
