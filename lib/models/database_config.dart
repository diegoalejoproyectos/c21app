/// Modelo de configuración de base de datos
///
/// Almacena la configuración para conectarse a PostgreSQL
/// o usar SQLite en modo sin conexión
class DatabaseConfig {
  /// Tipo de conexión: true = PostgreSQL, false = SQLite
  final bool useRemoteDatabase;

  /// Host del servidor PostgreSQL
  final String host;

  /// Puerto del servidor PostgreSQL
  final int port;

  /// Nombre de la base de datos
  final String databaseName;

  /// Usuario para la conexión
  final String username;

  /// Contraseña para la conexión
  final String password;

  /// Constructor
  const DatabaseConfig({
    required this.useRemoteDatabase,
    this.host = 'localhost',
    this.port = 5432,
    this.databaseName = 'postgres',
    this.username = 'postgres',
    this.password = 'diegoalejo726',
  });

  /// Constructor para configuración por defecto (SQLite)
  factory DatabaseConfig.defaultConfig() {
    return const DatabaseConfig(useRemoteDatabase: false);
  }

  /// Crear desde Map (para deserialización)
  factory DatabaseConfig.fromMap(Map<String, dynamic> map) {
    return DatabaseConfig(
      useRemoteDatabase: map['useRemoteDatabase'] ?? false,
      host: map['host'] ?? 'localhost',
      port: map['port'] ?? 5432,
      databaseName: map['databaseName'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }

  /// Convertir a Map (para serialización)
  Map<String, dynamic> toMap() {
    return {
      'useRemoteDatabase': useRemoteDatabase,
      'host': host,
      'port': port,
      'databaseName': databaseName,
      'username': username,
      'password': password,
    };
  }

  /// Crear copia con modificaciones
  DatabaseConfig copyWith({
    bool? useRemoteDatabase,
    String? host,
    int? port,
    String? databaseName,
    String? username,
    String? password,
  }) {
    return DatabaseConfig(
      useRemoteDatabase: useRemoteDatabase ?? this.useRemoteDatabase,
      host: host ?? this.host,
      port: port ?? this.port,
      databaseName: databaseName ?? this.databaseName,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'DatabaseConfig(useRemote: $useRemoteDatabase, host: $host, port: $port, db: $databaseName)';
  }
}
