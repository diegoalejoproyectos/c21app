// models/movimiento_bancario.dart
class MovimientoBancario {
  final int? id;
  final int codigo;
  final DateTime fecha;
  final String depto;
  final String detalle;
  final String refBancaria;
  final double monto;

  MovimientoBancario({
    this.id,
    required this.codigo,
    required this.fecha,
    required this.depto,
    required this.detalle,
    required this.refBancaria,
    required this.monto,
  });

  factory MovimientoBancario.fromMap(Map<String, dynamic> map) {
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

      // Buscar por similitud (para errores de tipeo como "detallle")
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

    // Buscar valores con nombres alternativos
    final codigoRaw = findValue(map, [
      'codigo',
      'Código',
      'CODIGO',
      'numero',
      'Número',
    ]);
    final fechaRaw = findValue(map, [
      'fecha',
      'Fecha',
      'FECHA',
      'date',
      'Date',
    ]);
    final deptoRaw = findValue(map, [
      'depto',
      'Depto',
      'DEPTO',
      'departamento',
      'Departamento',
    ]);

    // BUSCAR DETALLE - manejar error "detallle" con triple L
    final detalleRaw = findValue(map, [
      'detalle', 'detallle', 'Detalle', 'DETALLE', 'Detallle', // Error de tipeo
      'descripcion', 'Descripción', 'Descripcion', 'DESCRIPCION',
      'concepto', 'Concepto', 'CONCEPTO',
      'observacion', 'Observación', 'Observacion', 'OBSERVACION',
    ]);

    final refBancariaRaw = findValue(map, [
      'ref_bancaria',
      'Ref Bancaria',
      'REF_BANCARIA',
      'referencia',
      'Referencia',
      'REFERENCIA',
      'ref',
      'Ref',
      'REF',
    ]);

    final montoRaw = findValue(map, [
      'monto',
      'Monto',
      'MONTO',
      'importe',
      'Importe',
      'IMPORTE',
      'valor',
      'Valor',
      'VALOR',
      'cantidad',
      'Cantidad',
      'CANTIDAD',
      'amount',
      'Amount',
      'AMOUNT',
    ]);

    return MovimientoBancario(
      id: map['id'] as int?,
      codigo: int.tryParse(codigoRaw.toString()) ?? 0,
      fecha: _parseDate(fechaRaw.toString()),
      depto: deptoRaw.toString(),
      detalle: detalleRaw.toString(),
      refBancaria: refBancariaRaw.toString(),
      monto: parseMonto(montoRaw),
    );
  }

  // Función para comparación flexible de strings (manejar errores de tipeo)
  static bool _isSimilar(String a, String b) {
    if (a == b) return true;

    // Si uno contiene al otro (como "detallle" contiene "detalle")
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
          // Formato DD/MM/YYYY o MM/DD/YYYY
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;

          // Determinar si es formato DD/MM/YYYY o MM/DD/YYYY
          if (day > 12) {
            // Si el día es > 12, probablemente es DD/MM/YYYY
            return DateTime(year, month, day);
          } else {
            // Si no, asumir MM/DD/YYYY
            return DateTime(year, day, month);
          }
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
      'codigo': codigo,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'depto': depto,
      'detalle': detalle,
      'ref_bancaria': refBancaria,
      'monto': monto,
    };
  }

  @override
  String toString() {
    return 'MovimientoBancario(id: $id, codigo: $codigo, fecha: $fecha, depto: $depto, detalle: $detalle, refBancaria: $refBancaria, monto: $monto)';
  }
}
