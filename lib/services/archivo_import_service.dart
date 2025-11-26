import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';

/// Servicio centralizado para importar archivos Excel y CSV
///
/// Maneja la lectura de archivos y conversión a estructura de datos uniforme
class ArchivoImportService {
  /// Importa un archivo Excel (.xlsx) o CSV (.csv)
  ///
  /// [filePath] - Ruta completa del archivo a importar
  /// Returns lista de mapas con los datos del archivo
  /// Throws [FileSystemException] si el archivo no existe
  /// Throws [FormatException] si el formato del archivo es inválido
  static Future<List<Map<String, dynamic>>> importarArchivo(
    String filePath,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('El archivo no existe', filePath);
    }

    final path = filePath.toLowerCase();

    if (path.endsWith('.xlsx')) {
      return await _importarExcel(file);
    } else if (path.endsWith('.csv')) {
      return await _importarCSV(file);
    } else {
      throw FormatException(
        'Formato de archivo no soportado. Use .xlsx o .csv',
      );
    }
  }

  /// Importa un archivo Excel
  static Future<List<Map<String, dynamic>>> _importarExcel(File file) async {
    print('📊 [ArchivoImport] Leyendo archivo Excel: ${file.path}');

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Obtener la primera hoja
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    print('📄 [ArchivoImport] Hoja: $sheetName, Filas: ${sheet.maxRows}');

    final datos = <Map<String, dynamic>>[];
    List<String> headers = [];

    // Recorrer filas del Excel
    for (int r = 0; r < sheet.maxRows; r++) {
      final row = sheet.row(r);

      if (r == 0) {
        // Primera fila = encabezados
        headers = row.map((c) => c?.value.toString().trim() ?? '').toList();
        print('📋 [ArchivoImport] Encabezados: $headers');
      } else {
        // Resto de filas = datos
        Map<String, dynamic> fila = {};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          final value = row[i]?.value;
          fila[headers[i]] = value?.toString() ?? '';
        }

        // Solo agregar filas que no estén completamente vacías
        if (fila.values.any((v) => v.toString().trim().isNotEmpty)) {
          datos.add(fila);
        }
      }
    }

    print('✅ [ArchivoImport] Excel importado: ${datos.length} filas');
    return datos;
  }

  /// Importa un archivo CSV
  static Future<List<Map<String, dynamic>>> _importarCSV(File file) async {
    print('📊 [ArchivoImport] Leyendo archivo CSV: ${file.path}');

    String content;

    // Intentar leer como UTF-8, si falla usar Latin-1
    try {
      content = await file.readAsString(encoding: utf8);
      print('📝 [ArchivoImport] Codificación: UTF-8');
    } catch (_) {
      content = await file.readAsString(encoding: latin1);
      print('📝 [ArchivoImport] Codificación: Latin-1');
    }

    // Separar por líneas y eliminar líneas vacías
    List<String> lineas = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lineas.isEmpty) {
      throw FormatException('El archivo CSV está vacío');
    }

    // Detectar delimitador: ";" o ","
    final primeraLinea = lineas.first;
    final delimiter = primeraLinea.contains(';') ? ';' : ',';
    print('🔍 [ArchivoImport] Delimitador detectado: "$delimiter"');

    // Primera línea = encabezados
    List<String> headers = primeraLinea
        .split(delimiter)
        .map((e) => e.trim())
        .toList();

    print('📋 [ArchivoImport] Encabezados: $headers');

    final datos = <Map<String, dynamic>>[];

    // Leer datos (desde la segunda línea)
    for (int i = 1; i < lineas.length; i++) {
      final cols = lineas[i].split(delimiter).map((e) => e.trim()).toList();

      Map<String, dynamic> fila = {};

      for (int x = 0; x < headers.length; x++) {
        fila[headers[x]] = x < cols.length ? cols[x] : '';
      }

      // Solo agregar filas que no estén completamente vacías
      if (fila.values.any((v) => v.toString().trim().isNotEmpty)) {
        datos.add(fila);
      }
    }

    print('✅ [ArchivoImport] CSV importado: ${datos.length} filas');
    return datos;
  }
}
