// models/matriz.dart
class PagoMatriz {
  final int? id;
  final int nro;
  final String usuario;
  final int nroFactura;
  final DateTime fechaFactura;
  final String refBancaria;
  final String carnet;
  final String nombres;
  final int codPago;
  final String detalle;
  final double montoTotal;
  final String objeto;
  final String volteos;
  final double montoSiscoin;
  final double montoExtracto;
  final double diferenciaMonto;
  final String? observacion;

  PagoMatriz({
    this.id,
    required this.nro,
    required this.usuario,
    required this.nroFactura,
    required this.fechaFactura,
    required this.refBancaria,
    required this.carnet,
    required this.nombres,
    required this.codPago,
    required this.detalle,
    required this.montoTotal,
    required this.objeto,
    required this.volteos,
    required this.montoSiscoin,
    required this.montoExtracto,
    required this.diferenciaMonto,
    this.observacion,
  });

  factory PagoMatriz.fromMap(Map<String, dynamic> map) {
    // Función para buscar valores con múltiples nombres posibles
    dynamic findValue(Map<String, dynamic> map, List<String> possibleKeys) {
      for (final key in possibleKeys) {
        if (map.containsKey(key)) {
          final value = map[key]?.toString().trim();
          if (value != null && value.isNotEmpty && value != 'null') {
            print('✅ Encontrado $key: $value');
            return value;
          }
        }
      }

      // Buscar por similitud (para errores de tipeo)
      for (final mapKey in map.keys) {
        final normalizedMapKey = mapKey.toString().toLowerCase().replaceAll(
          ' ',
          '',
        );
        for (final possibleKey in possibleKeys) {
          final normalizedPossibleKey = possibleKey.toLowerCase().replaceAll(
            ' ',
            '',
          );
          if (_isSimilar(normalizedMapKey, normalizedPossibleKey)) {
            final value = map[mapKey]?.toString().trim();
            if (value != null && value.isNotEmpty && value != 'null') {
              print(
                '✅ Encontrado por similitud: "$mapKey" -> $possibleKey: $value',
              );
              return value;
            }
          }
        }
      }

      return '';
    }

    // Función mejorada para parsear montos
    double parseMonto(dynamic value) {
      if (value == null) return 0.0;

      final String stringValue = value.toString().trim();

      print('🔄 Parseando monto: "$stringValue"');

      if (stringValue.isEmpty) return 0.0;

      try {
        // Limpiar el string: quitar símbolos de moneda, espacios, etc.
        String cleaned = stringValue
            .replaceAll('\$', '') // Quitar signo de dólar
            .replaceAll(' ', '') // Quitar espacios
            .replaceAll(',', '') // Quitar comas (1,000 -> 1000)
            .replaceAll('"', '') // Quitar comillas
            .replaceAll("'", '') // Quitar apóstrofes
            .replaceAll('USD', '') // Quitar USD
            .replaceAll('usd', ''); // Quitar usd

        // Manejar formato europeo (1.000,50 -> 1000.50)
        if (cleaned.contains('.') && cleaned.contains(',')) {
          final lastDot = cleaned.lastIndexOf('.');
          final lastComma = cleaned.lastIndexOf(',');
          if (lastDot < lastComma) {
            // El punto es para miles y la coma para decimales
            cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
          }
        }

        // Si todavía tiene coma pero no punto, convertir coma a punto
        if (cleaned.contains(',') && !cleaned.contains('.')) {
          cleaned = cleaned.replaceAll(',', '.');
        }

        // Parsear a double
        final result = double.tryParse(cleaned) ?? 0.0;
        print('✅ Monto parseado: $result');
        return result;
      } catch (e) {
        print('❌ Error parseando monto "$stringValue": $e');
        return 0.0;
      }
    }

    // Buscar valores con nombres alternativos basados en el CSV de ejemplo
    final nroRaw = findValue(map, [
      'nro',
      'Nro',
      'NRO',
      'numero',
      'Número',
      'NUMERO',
    ]);

    final usuarioRaw = findValue(map, [
      'usuario',
      'Usuario',
      'USUARIO',
      'user',
      'User',
      'USER',
    ]);

    final nroFacturaRaw = findValue(map, [
      'nro_factura',
      'nro factura',
      'Nro Factura',
      'NRO_FACTURA',
      'factura',
      'Factura',
      'FACTURA',
    ]);

    final fechaFacturaRaw = findValue(map, [
      'fecha_factura',
      'fecha factura',
      'Fecha Factura',
      'FECHA_FACTURA',
      'fecha',
      'Fecha',
      'FECHA',
    ]);

    final refBancariaRaw = findValue(map, [
      'ref_bancaria',
      'ref bancaria',
      'Ref Bancaria',
      'REF_BANCARIA',
      'referencia',
      'Referencia',
      'REFERENCIA',
    ]);

    final carnetRaw = findValue(map, [
      'carnet',
      'Carnet',
      'CARNET',
      'ci',
      'CI',
      'cedula',
      'Cédula',
    ]);

    final nombresRaw = findValue(map, [
      'nombres',
      'Nombres',
      'NOMBRES',
      'nombre',
      'Nombre',
      'NOMBRE',
      'name',
      'Name',
    ]);

    final codPagoRaw = findValue(map, [
      'cod_pago',
      'cod pago',
      'Cod Pago',
      'COD_PAGO',
      'codigo_pago',
      'Código Pago',
    ]);

    final detalleRaw = findValue(map, [
      'detalle',
      'Detalle',
      'DETALLE',
      'descripcion',
      'Descripción',
      'DESCRIPCION',
    ]);

    final montoTotalRaw = findValue(map, [
      'monto_total',
      'monto total',
      'Monto Total',
      'MONTO_TOTAL',
      'MONTO TOTAL',
      'total',
      'Total',
      'TOTAL',
    ]);

    final objetoRaw = findValue(map, [
      'objeto',
      'Objeto',
      'OBJETO',
      'object',
      'Object',
    ]);

    final volteosRaw = findValue(map, ['volteos', 'Volteos', 'VOLTEOS']);

    final montoSiscoinRaw = findValue(map, [
      'monto_siscoin',
      'monto siscoin',
      'Monto Siscoin',
      'MONTO_SISCOIN',
      'MONTO SISCOIN',
      'siscoin',
      'Siscoin',
      'SISCOIN',
    ]);

    final montoExtractoRaw = findValue(map, [
      'monto_extracto',
      'monto extracto',
      'Monto Extracto',
      'MONTO_EXTRACTO',
      'MONTO EXTRACTO',
      'extracto',
      'Extracto',
      'EXTRACTO',
    ]);

    final diferenciaMontoRaw = findValue(map, [
      'diferencia_monto',
      'diferencia monto',
      'Diferencia Monto',
      'DIFERENCIA_MONTO',
      'DIFERENCIA MONTO',
      'diferencia',
      'Diferencia',
      'DIFERENCIA',
    ]);

    final observacionRaw = findValue(map, [
      'observacion',
      'Observacion',
      'Observación',
      'OBSERVACION',
      'obs',
      'Obs',
      'OBS',
    ]);

    return PagoMatriz(
      id: map['id'] as int?,
      nro: int.tryParse(nroRaw.toString()) ?? 0,
      usuario: usuarioRaw.toString(),
      nroFactura: int.tryParse(nroFacturaRaw.toString()) ?? 0,
      fechaFactura: _parseDate(fechaFacturaRaw.toString()),
      refBancaria: refBancariaRaw.toString(),
      carnet: carnetRaw.toString(),
      nombres: nombresRaw.toString(),
      codPago: int.tryParse(codPagoRaw.toString()) ?? 0,
      detalle: detalleRaw.toString(),
      montoTotal: parseMonto(montoTotalRaw),
      objeto: objetoRaw.toString(),
      volteos: volteosRaw.toString(),
      montoSiscoin: parseMonto(montoSiscoinRaw),
      montoExtracto: parseMonto(montoExtractoRaw),
      diferenciaMonto: parseMonto(diferenciaMontoRaw),
      observacion: observacionRaw.toString().isEmpty
          ? null
          : observacionRaw.toString(),
    );
  }

  // Función para comparación flexible de strings (manejar errores de tipeo)
  static bool _isSimilar(String a, String b) {
    if (a == b) return true;

    // Si uno contiene al otro
    if (a.contains(b) || b.contains(a)) return true;

    // Permitir pequeñas diferencias de longitud
    if ((a.length - b.length).abs() <= 2) {
      int differences = 0;
      final minLength = a.length < b.length ? a.length : b.length;

      for (int i = 0; i < minLength; i++) {
        if (a[i] != b[i]) {
          differences++;
          if (differences > 2) return false;
        }
      }
      return true;
    }

    return false;
  }

  static DateTime _parseDate(String dateString) {
    try {
      if (dateString.isEmpty) return DateTime.now();

      // Debug
      print('📅 Parseando fecha: "$dateString"');

      // Intentar diferentes formatos de fecha
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          // Formato DD/MM/YYYY basado en el ejemplo: 30/10/2025
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;

          return DateTime(year, month, day);
        }
      }

      // Intentar parseo directo
      return DateTime.tryParse(dateString) ?? DateTime.now();
    } catch (e) {
      print('❌ Error parseando fecha "$dateString": $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nro': nro,
      'usuario': usuario,
      'nro_factura': nroFactura,
      'fecha_factura': fechaFactura.toIso8601String().split(
        'T',
      )[0], // Formato YYYY-MM-DD
      'ref_bancaria': refBancaria,
      'carnet': carnet,
      'nombres': nombres,
      'cod_pago': codPago,
      'detalle': detalle,
      'monto_total': montoTotal,
      'objeto': objeto,
      'volteos': volteos,
      'monto_siscoin': montoSiscoin,
      'monto_extracto': montoExtracto,
      'diferencia_monto': diferenciaMonto,
      if (observacion != null) 'observacion': observacion,
    };
  }

  @override
  String toString() {
    return 'PagoMatriz(id: $id, nro: $nro, usuario: $usuario, nroFactura: $nroFactura, fechaFactura: $fechaFactura, refBancaria: $refBancaria, carnet: $carnet, nombres: $nombres, codPago: $codPago, detalle: $detalle, montoTotal: $montoTotal, objeto: $objeto, volteos: $volteos, montoSiscoin: $montoSiscoin, montoExtracto: $montoExtracto, diferenciaMonto: $diferenciaMonto, observacion: $observacion)';
  }
}
