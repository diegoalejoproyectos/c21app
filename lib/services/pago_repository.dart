import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/matriz.dart';
import '../models/movimiento_bancario.dart';
import '../models/reporte_models.dart';
import '../models/database_config.dart';

class PagoRepository {
  /// Obtiene el reporte completo para un código
  static Future<ReporteIndividual> obtenerReporteCompleto(int codigo) async {
    final connection = await _getConnection();

    try {
      // 1. Obtener Resumen
      final resumen = await _obtenerResumenPagosInternal(connection, codigo);

      // 2. Obtener Detalle
      final detalle = await _obtenerDetallePagosInternal(connection, codigo);

      // 3. Obtener Extracto
      final extracto = await _obtenerDatosExtractoInternal(connection, codigo);

      return ReporteIndividual(
        codigo: codigo,
        resumenPagos: resumen,
        detallePagos: detalle,
        datosExtracto: extracto,
      );
    } finally {
      await connection.close();
    }
  }

  /// Obtiene el resumen de pagos (método interno que reusa la conexión)
  static Future<List<ResumenPago>> _obtenerResumenPagosInternal(
    Connection connection,
    int codigo,
  ) async {
    final sql = '''
      SELECT pagos_matriz.cod_pago::text,
             SUM(pagos_matriz.monto_total) AS total_monto
      FROM pagos_matriz
      INNER JOIN movimientos_bancarios 
             ON pagos_matriz.ref_bancaria = movimientos_bancarios.ref_bancaria
      WHERE movimientos_bancarios.codigo = @codigo
      GROUP BY pagos_matriz.cod_pago

      UNION ALL

      SELECT 'TOTAL' AS cod_pago,
             SUM(pagos_matriz.monto_total) AS total_monto
      FROM pagos_matriz
      INNER JOIN movimientos_bancarios 
             ON pagos_matriz.ref_bancaria = movimientos_bancarios.ref_bancaria
      WHERE movimientos_bancarios.codigo = @codigo

      ORDER BY cod_pago
    ''';

    final result = await connection.execute(
      Sql.named(sql),
      parameters: {'codigo': codigo},
    );

    return result.map((row) {
      return ResumenPago(
        codPago: row[0].toString(),
        totalMonto: (row[1] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Obtiene el detalle de pagos (método interno que reusa la conexión)
  static Future<List<PagoMatriz>> _obtenerDetallePagosInternal(
    Connection connection,
    int codigo,
  ) async {
    final sql = '''
      SELECT 
          pagos_matriz.id,
          pagos_matriz.nro, 
          pagos_matriz.usuario, 
          pagos_matriz.nro_factura, 
          pagos_matriz.fecha_factura,
          pagos_matriz.ref_bancaria, 
          pagos_matriz.carnet, 
          pagos_matriz.nombres, 
          pagos_matriz.cod_pago,
          pagos_matriz.detalle, 
          pagos_matriz.monto_total, 
          pagos_matriz.objeto, 
          pagos_matriz.volteos,
          pagos_matriz.monto_siscoin,
          pagos_matriz.monto_extracto,
          pagos_matriz.diferencia_monto,
          pagos_matriz.observacion
      FROM pagos_matriz
      INNER JOIN movimientos_bancarios 
             ON pagos_matriz.ref_bancaria = movimientos_bancarios.ref_bancaria
      WHERE movimientos_bancarios.codigo = @codigo
      ORDER BY pagos_matriz.nro_factura
    ''';

    final result = await connection.execute(
      Sql.named(sql),
      parameters: {'codigo': codigo},
    );

    return result.map((row) {
      return PagoMatriz(
        id: row[0] as int?,
        nro: row[1] as int,
        usuario: row[2] as String,
        nroFactura: row[3] as int,
        fechaFactura: row[4] as DateTime,
        refBancaria: row[5] as String,
        carnet: row[6] as String,
        nombres: row[7] as String,
        codPago: row[8] as int,
        detalle: row[9] as String,
        montoTotal: (row[10] as num).toDouble(),
        objeto: row[11] as String,
        volteos: row[12] as String,
        montoSiscoin: (row[13] as num).toDouble(),
        montoExtracto: (row[14] as num).toDouble(),
        diferenciaMonto: (row[15] as num).toDouble(),
        observacion: row[16] as String?,
      );
    }).toList();
  }

  /// Obtiene datos del extracto (método interno que reusa la conexión)
  static Future<List<MovimientoBancario>> _obtenerDatosExtractoInternal(
    Connection connection,
    int codigo,
  ) async {
    final sql = '''
      SELECT id, codigo, fecha, depto, detalle, ref_bancaria, monto  
      FROM movimientos_bancarios
      WHERE codigo = @codigo
      ORDER BY monto DESC
    ''';

    final result = await connection.execute(
      Sql.named(sql),
      parameters: {'codigo': codigo},
    );

    return result.map((row) {
      return MovimientoBancario(
        id: row[0] as int?,
        codigo: row[1] as int,
        fecha: row[2] as DateTime,
        depto: row[3] as String,
        detalle: row[4] as String,
        refBancaria: row[5] as String,
        monto: (row[6] as num).toDouble(),
      );
    }).toList();
  }

  /// Obtiene todos los códigos únicos disponibles
  static Future<List<int>> obtenerCodigosDisponibles() async {
    final connection = await _getConnection();

    try {
      final sql = '''
        SELECT DISTINCT codigo
        FROM movimientos_bancarios
        ORDER BY codigo
      ''';

      final result = await connection.execute(sql);

      return result.map((row) => row[0] as int).toList();
    } finally {
      await connection.close();
    }
  }

  /// Crea una conexión a PostgreSQL usando la configuración guardada
  static Future<Connection> _getConnection() async {
    // Cargar configuración desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('database_config');

    final DatabaseConfig config;
    if (configJson != null) {
      final map = json.decode(configJson) as Map<String, dynamic>;
      config = DatabaseConfig.fromMap(map);
    } else {
      config = DatabaseConfig.defaultConfig();
    }

    if (!config.useRemoteDatabase) {
      throw Exception(
        'PostgreSQL no está configurado. Active la base de datos remota en Configuración.',
      );
    }

    return await Connection.open(
      Endpoint(
        host: config.host,
        database: config.databaseName,
        port: config.port,
        username: config.username,
        password: config.password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
}
