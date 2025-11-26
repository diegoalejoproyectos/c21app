import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/matriz.dart';
import '../models/movimiento_bancario.dart';

/// Servicio para generar reportes PDF agrupados por código
class PdfExportService {
  /// Genera un PDF de extracto bancario con datos agrupados por código
  ///
  /// [extractos] - Lista de movimientos bancarios
  /// [codigoDesde] - Código inicial del rango (opcional)
  /// [codigoHasta] - Código final del rango (opcional)
  /// [numeroReporte] - Número del reporte (ej: 1385)
  /// Returns ruta del archivo PDF generado
  static Future<String> generarPdfExtracto({
    required List<MovimientoBancario> extractos,
    int? codigoDesde,
    int? codigoHasta,
    int numeroReporte = 1385,
  }) async {
    // Filtrar por rango de códigos si se especifica
    List<MovimientoBancario> extractosFiltrados = extractos;
    if (codigoDesde != null || codigoHasta != null) {
      extractosFiltrados = extractos.where((e) {
        if (codigoDesde != null && e.codigo < codigoDesde) return false;
        if (codigoHasta != null && e.codigo > codigoHasta) return false;
        return true;
      }).toList();
    }

    // Agrupar por código
    final Map<int, List<MovimientoBancario>> extractosPorCodigo = {};
    for (final extracto in extractosFiltrados) {
      if (!extractosPorCodigo.containsKey(extracto.codigo)) {
        extractosPorCodigo[extracto.codigo] = [];
      }
      extractosPorCodigo[extracto.codigo]!.add(extracto);
    }

    // Ordenar códigos
    final codigosOrdenados = extractosPorCodigo.keys.toList()..sort();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Título del reporte
          pw.Center(
            child: pw.Text(
              'Reporte C-21 Nº: $numeroReporte',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // Tabla de extracto
          _buildExtractoTable(extractosPorCodigo, codigosOrdenados),

          pw.SizedBox(height: 30),

          // Resumen de rubros (si hay datos)
          if (extractosPorCodigo.isNotEmpty)
            _buildRubrosTable(extractosPorCodigo, codigosOrdenados),
        ],
      ),
    );

    // Guardar PDF
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/reporte_c21_$numeroReporte.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Genera un PDF de matriz de pagos con datos agrupados por código
  static Future<String> generarPdfMatriz({
    required List<PagoMatriz> pagos,
    int? codigoDesde,
    int? codigoHasta,
    int numeroReporte = 1385,
  }) async {
    // Filtrar por rango de códigos
    List<PagoMatriz> pagosFiltrados = pagos;
    if (codigoDesde != null || codigoHasta != null) {
      pagosFiltrados = pagos.where((p) {
        if (codigoDesde != null && p.codPago < codigoDesde) return false;
        if (codigoHasta != null && p.codPago > codigoHasta) return false;
        return true;
      }).toList();
    }

    // Agrupar por código de pago
    final Map<int, List<PagoMatriz>> pagosPorCodigo = {};
    for (final pago in pagosFiltrados) {
      if (!pagosPorCodigo.containsKey(pago.codPago)) {
        pagosPorCodigo[pago.codPago] = [];
      }
      pagosPorCodigo[pago.codPago]!.add(pago);
    }

    final codigosOrdenados = pagosPorCodigo.keys.toList()..sort();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Reporte C-21 Nº: $numeroReporte - Matriz de Pagos',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          _buildMatrizTable(pagosPorCodigo, codigosOrdenados),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/reporte_matriz_$numeroReporte.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Construye la tabla de extracto bancario
  static pw.Widget _buildExtractoTable(
    Map<int, List<MovimientoBancario>> extractosPorCodigo,
    List<int> codigosOrdenados,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Datos De Extracto',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),

        // Tabla de extracto
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5), // Fecha
            1: const pw.FlexColumnWidth(1), // Sede
            2: const pw.FlexColumnWidth(3), // Detalle
            3: const pw.FlexColumnWidth(2), // Transacción
            4: const pw.FlexColumnWidth(1.5), // Monto
          },
          children: [
            // Encabezado
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableCell('Fecha', isHeader: true),
                _buildTableCell('Sede', isHeader: true),
                _buildTableCell('Detalle', isHeader: true),
                _buildTableCell('Transacción', isHeader: true),
                _buildTableCell('Monto', isHeader: true),
              ],
            ),

            // Datos agrupados por código
            ...codigosOrdenados.expand((codigo) {
              final extractos = extractosPorCodigo[codigo]!;
              return extractos.map(
                (e) => pw.TableRow(
                  children: [
                    _buildTableCell(_formatDate(e.fecha)),
                    _buildTableCell(e.depto),
                    _buildTableCell(e.detalle),
                    _buildTableCell(e.refBancaria),
                    _buildTableCell(
                      _formatMonto(e.monto),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Construye la tabla de rubros (resumen por código)
  static pw.Widget _buildRubrosTable(
    Map<int, List<MovimientoBancario>> extractosPorCodigo,
    List<int> codigosOrdenados,
  ) {
    // Calcular totales por código
    final Map<int, double> totalesPorCodigo = {};
    for (final codigo in codigosOrdenados) {
      final extractos = extractosPorCodigo[codigo]!;
      totalesPorCodigo[codigo] = extractos.fold(0.0, (sum, e) => sum + e.monto);
    }

    final totalGeneral = totalesPorCodigo.values.fold(
      0.0,
      (sum, monto) => sum + monto,
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: pw.Container()),
        pw.Container(
          width: 250,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'RUBROS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell(
                        'Código Pago',
                        isHeader: true,
                        fontSize: 9,
                      ),
                      _buildTableCell(
                        'Monto Total',
                        isHeader: true,
                        fontSize: 9,
                      ),
                    ],
                  ),
                  ...codigosOrdenados.map(
                    (codigo) => pw.TableRow(
                      children: [
                        _buildTableCell(codigo.toString(), fontSize: 9),
                        _buildTableCell(
                          _formatMonto(totalesPorCodigo[codigo]!),
                          align: pw.TextAlign.right,
                          fontSize: 9,
                        ),
                      ],
                    ),
                  ),
                  // Total
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _buildTableCell('TOTAL', isHeader: true, fontSize: 9),
                      _buildTableCell(
                        _formatMonto(totalGeneral),
                        isHeader: true,
                        align: pw.TextAlign.right,
                        fontSize: 9,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye la tabla de matriz de pagos
  static pw.Widget _buildMatrizTable(
    Map<int, List<PagoMatriz>> pagosPorCodigo,
    List<int> codigosOrdenados,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1), // Usuario
        1: const pw.FlexColumnWidth(1), // Nro
        2: const pw.FlexColumnWidth(1), // Nro Factura
        3: const pw.FlexColumnWidth(1.5), // Fecha
        4: const pw.FlexColumnWidth(1.5), // Ref Bancaria
        5: const pw.FlexColumnWidth(1.5), // Carnet
        6: const pw.FlexColumnWidth(2.5), // Nombres
        7: const pw.FlexColumnWidth(1), // Cod Pago
        8: const pw.FlexColumnWidth(2), // Detalle
        9: const pw.FlexColumnWidth(2), // Objeto
        10: const pw.FlexColumnWidth(1), // Volteos
        11: const pw.FlexColumnWidth(1.5), // Monto Total
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Usuario', isHeader: true, fontSize: 8),
            _buildTableCell('Nro', isHeader: true, fontSize: 8),
            _buildTableCell('Nro Factura', isHeader: true, fontSize: 8),
            _buildTableCell('Fecha', isHeader: true, fontSize: 8),
            _buildTableCell('Ref Bancaria', isHeader: true, fontSize: 8),
            _buildTableCell('Carnet', isHeader: true, fontSize: 8),
            _buildTableCell('Nombres', isHeader: true, fontSize: 8),
            _buildTableCell('Cod Pago', isHeader: true, fontSize: 8),
            _buildTableCell('Detalle', isHeader: true, fontSize: 8),
            _buildTableCell('Objeto', isHeader: true, fontSize: 8),
            _buildTableCell('Volteos', isHeader: true, fontSize: 8),
            _buildTableCell('Monto Total', isHeader: true, fontSize: 8),
          ],
        ),

        // Datos agrupados por código
        ...codigosOrdenados.expand((codigo) {
          final pagos = pagosPorCodigo[codigo]!;
          return pagos.map(
            (p) => pw.TableRow(
              children: [
                _buildTableCell(p.usuario, fontSize: 7),
                _buildTableCell(p.nro.toString(), fontSize: 7),
                _buildTableCell(p.nroFactura.toString(), fontSize: 7),
                _buildTableCell(_formatDate(p.fechaFactura), fontSize: 7),
                _buildTableCell(p.refBancaria, fontSize: 7),
                _buildTableCell(p.carnet, fontSize: 7),
                _buildTableCell(p.nombres, fontSize: 7),
                _buildTableCell(p.codPago.toString(), fontSize: 7),
                _buildTableCell(p.detalle, fontSize: 7),
                _buildTableCell(p.objeto, fontSize: 7),
                _buildTableCell(p.volteos, fontSize: 7),
                _buildTableCell(
                  _formatMonto(p.montoTotal),
                  align: pw.TextAlign.right,
                  fontSize: 7,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Construye una celda de tabla
  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  /// Formatea una fecha a DD/MM/YYYY
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatea un monto con separador de miles y 2 decimales
  static String _formatMonto(double monto) {
    final parts = monto.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Agregar separador de miles
    String formatted = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        formatted += ',';
      }
      formatted += intPart[i];
    }

    return '$formatted.$decPart';
  }

  /// Abre el PDF para vista previa e impresión
  static Future<void> previsualizarPdf(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
