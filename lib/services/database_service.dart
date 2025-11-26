/// Servicio para gestionar la configuración y conexión de base de datos
///
/// Maneja la persistencia de configuración usando SharedPreferences
/// y proporciona métodos para trabajar con PostgreSQL o SQLite
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'platform/db_platform.dart';
import '../models/database_config.dart';

/// Servicio singleton para gestión de base de datos
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Clave para guardar configuración en SharedPreferences
  static const String _configKey = 'database_config';

  /// Base de datos SQLite local
  Database? _localDatabase;

  /// Configuración actual
  DatabaseConfig? _currentConfig;

  /// Obtener la configuración actual
  Future<DatabaseConfig> getConfig() async {
    if (_currentConfig != null) {
      return _currentConfig!;
    }

    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);

    if (configJson != null) {
      final map = json.decode(configJson) as Map<String, dynamic>;
      _currentConfig = DatabaseConfig.fromMap(map);
    } else {
      _currentConfig = DatabaseConfig.defaultConfig();
    }

    return _currentConfig!;
  }

  /// Guardar configuración
  Future<void> saveConfig(DatabaseConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = json.encode(config.toMap());
    await prefs.setString(_configKey, configJson);
    _currentConfig = config;
  }

  /// Inicializar base de datos SQLite local
  Future<Database> initLocalDatabase() async {
    if (_localDatabase != null) {
      return _localDatabase!;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'c21app.db');

    _localDatabase = await openDatabase(
      path,
      version: 2, // Incrementado para incluir nuevas tablas
      onCreate: (Database db, int version) async {
        print('🔧 [DatabaseService] Creando base de datos versión $version');

        // Tabla de configuración
        await db.execute('''
          CREATE TABLE IF NOT EXISTS configuracion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            clave TEXT NOT NULL UNIQUE,
            valor TEXT
          )
        ''');

        // Tabla de datos importados (genérica)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS datos_importados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT NOT NULL,
            datos TEXT NOT NULL,
            fecha_importacion TEXT NOT NULL
          )
        ''');

        // Tabla de movimientos bancarios (extracto)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS movimientos_bancarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            depto TEXT NOT NULL,
            detalle TEXT NOT NULL,
            ref_bancaria TEXT NOT NULL,
            monto REAL NOT NULL,
            UNIQUE(codigo, fecha, ref_bancaria)
          )
        ''');

        // Tabla de pagos matriz
        await db.execute('''
          CREATE TABLE IF NOT EXISTS pagos_matriz (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nro INTEGER NOT NULL,
            usuario TEXT NOT NULL,
            nro_factura INTEGER NOT NULL,
            fecha_factura TEXT NOT NULL,
            ref_bancaria TEXT NOT NULL,
            carnet TEXT NOT NULL,
            nombres TEXT NOT NULL,
            cod_pago INTEGER NOT NULL,
            detalle TEXT NOT NULL,
            monto_total REAL NOT NULL,
            objeto TEXT NOT NULL,
            volteos TEXT NOT NULL,
            monto_siscoin REAL NOT NULL,
            monto_extracto REAL NOT NULL,
            diferencia_monto REAL NOT NULL,
            observacion TEXT,
            UNIQUE(nro, carnet, nro_factura)
          )
        ''');

        print('✅ [DatabaseService] Tablas creadas exitosamente');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        print(
          '🔄 [DatabaseService] Migrando de versión $oldVersion a $newVersion',
        );

        if (oldVersion < 2) {
          // Migración de versión 1 a 2: agregar nuevas tablas
          await db.execute('''
            CREATE TABLE IF NOT EXISTS movimientos_bancarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              codigo INTEGER NOT NULL,
              fecha TEXT NOT NULL,
              depto TEXT NOT NULL,
              detalle TEXT NOT NULL,
              ref_bancaria TEXT NOT NULL,
              monto REAL NOT NULL,
              UNIQUE(codigo, fecha, ref_bancaria)
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS pagos_matriz (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nro INTEGER NOT NULL,
              usuario TEXT NOT NULL,
              nro_factura INTEGER NOT NULL,
              fecha_factura TEXT NOT NULL,
              ref_bancaria TEXT NOT NULL,
              carnet TEXT NOT NULL,
              nombres TEXT NOT NULL,
              cod_pago INTEGER NOT NULL,
              detalle TEXT NOT NULL,
              monto_total REAL NOT NULL,
              objeto TEXT NOT NULL,
              volteos TEXT NOT NULL,
              monto_siscoin REAL NOT NULL,
              monto_extracto REAL NOT NULL,
              diferencia_monto REAL NOT NULL,
              observacion TEXT,
              UNIQUE(nro, carnet, nro_factura)
            )
          ''');

          print('✅ [DatabaseService] Migración completada');
        }
      },
    );

    return _localDatabase!;
  }

  /// Verificar conexión a PostgreSQL
  Future<bool> testPostgresConnection(DatabaseConfig config) async {
    if (!config.useRemoteDatabase) {
      return false;
    }

    // Validar que los campos necesarios estén llenos
    if (config.host.isEmpty ||
        config.databaseName.isEmpty ||
        config.username.isEmpty) {
      return false;
    }

    try {
      // Intentar conexión real a PostgreSQL usando el helper de plataforma
      // Esto maneja la lógica específica de IO vs Web
      final connection = await DbPlatformHelper.connectPostgres(
        host: config.host,
        port: config.port,
        database: config.databaseName,
        username: config.username,
        password: config.password,
      );

      // Probar con una consulta simple (usando dynamic para evitar dependencia directa)
      // En IO esto es un PostgreSQLConnection, en Web lanzará error antes de llegar aquí
      await connection.execute('SELECT 1');

      // Cerrar conexión
      await connection.close();

      return true;
    } catch (e) {
      // Error de conexión (o no soportado en web)
      print('Error de conexión PostgreSQL: $e');
      return false;
    }
  }

  /// Cerrar base de datos local
  Future<void> closeLocalDatabase() async {
    await _localDatabase?.close();
    _localDatabase = null;
  }

  /// Limpiar configuración (para testing)
  Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
    _currentConfig = null;
  }
}
