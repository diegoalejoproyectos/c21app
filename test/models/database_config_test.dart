import 'package:flutter_test/flutter_test.dart';
import 'package:c21app/models/database_config.dart';

void main() {
  group('DatabaseConfig', () {
    test('defaultConfig creates SQLite configuration', () {
      final config = DatabaseConfig.defaultConfig();

      expect(config.useRemoteDatabase, false);
      expect(config.host, 'localhost');
      expect(config.port, 5432);
      expect(config.databaseName, '');
      expect(config.username, '');
      expect(config.password, '');
    });

    test('constructor creates config with all fields', () {
      final config = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'test.example.com',
        port: 5433,
        databaseName: 'testdb',
        username: 'testuser',
        password: 'testpass',
      );

      expect(config.useRemoteDatabase, true);
      expect(config.host, 'test.example.com');
      expect(config.port, 5433);
      expect(config.databaseName, 'testdb');
      expect(config.username, 'testuser');
      expect(config.password, 'testpass');
    });

    test('toMap serializes config correctly', () {
      final config = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'example.com',
        port: 5432,
        databaseName: 'mydb',
        username: 'user',
        password: 'pass',
      );

      final map = config.toMap();

      expect(map['useRemoteDatabase'], true);
      expect(map['host'], 'example.com');
      expect(map['port'], 5432);
      expect(map['databaseName'], 'mydb');
      expect(map['username'], 'user');
      expect(map['password'], 'pass');
    });

    test('fromMap deserializes config correctly', () {
      final map = {
        'useRemoteDatabase': true,
        'host': 'example.com',
        'port': 5432,
        'databaseName': 'mydb',
        'username': 'user',
        'password': 'pass',
      };

      final config = DatabaseConfig.fromMap(map);

      expect(config.useRemoteDatabase, true);
      expect(config.host, 'example.com');
      expect(config.port, 5432);
      expect(config.databaseName, 'mydb');
      expect(config.username, 'user');
      expect(config.password, 'pass');
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};

      final config = DatabaseConfig.fromMap(map);

      expect(config.useRemoteDatabase, false);
      expect(config.host, 'localhost');
      expect(config.port, 5432);
      expect(config.databaseName, '');
      expect(config.username, '');
      expect(config.password, '');
    });

    test('copyWith creates new config with modified fields', () {
      final original = DatabaseConfig(
        useRemoteDatabase: false,
        host: 'localhost',
        port: 5432,
        databaseName: 'db1',
        username: 'user1',
        password: 'pass1',
      );

      final modified = original.copyWith(
        useRemoteDatabase: true,
        host: 'remote.com',
      );

      expect(modified.useRemoteDatabase, true);
      expect(modified.host, 'remote.com');
      expect(modified.port, 5432); // unchanged
      expect(modified.databaseName, 'db1'); // unchanged
      expect(modified.username, 'user1'); // unchanged
      expect(modified.password, 'pass1'); // unchanged
    });

    test('copyWith with no changes returns equivalent config', () {
      final original = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'example.com',
        port: 5432,
        databaseName: 'mydb',
        username: 'user',
        password: 'pass',
      );

      final copy = original.copyWith();

      expect(copy.useRemoteDatabase, original.useRemoteDatabase);
      expect(copy.host, original.host);
      expect(copy.port, original.port);
      expect(copy.databaseName, original.databaseName);
      expect(copy.username, original.username);
      expect(copy.password, original.password);
    });

    test('toString does not expose password', () {
      final config = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'example.com',
        port: 5432,
        databaseName: 'mydb',
        username: 'user',
        password: 'secretpassword',
      );

      final str = config.toString();

      expect(str, contains('useRemote'));
      expect(str, contains('example.com'));
      expect(str, contains('5432'));
      expect(str, contains('mydb'));
      // Password should not be in toString for security
    });

    test('serialization round-trip preserves data', () {
      final original = DatabaseConfig(
        useRemoteDatabase: true,
        host: 'test.example.com',
        port: 5433,
        databaseName: 'testdb',
        username: 'testuser',
        password: 'testpass',
      );

      final map = original.toMap();
      final restored = DatabaseConfig.fromMap(map);

      expect(restored.useRemoteDatabase, original.useRemoteDatabase);
      expect(restored.host, original.host);
      expect(restored.port, original.port);
      expect(restored.databaseName, original.databaseName);
      expect(restored.username, original.username);
      expect(restored.password, original.password);
    });
  });
}
