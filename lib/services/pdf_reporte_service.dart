import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/matriz.dart';
import '../models/movimiento_bancario.dart';
import '../models/reporte_models.dart';
import 'pago_repository.dart';

/// Servicio para generar reportes PDF múltiples agrupados por código
/// Similar a ReportePagosMultiple en C# con QuestPDF
class PdfReporteService {
  final List<ReporteIndividual> _reportes = [];

  /// Agrega un reporte individual ya procesado al documento
  void agregarReporteExistente(ReporteIndividual reporte) {
    _reportes.add(reporte);
  }

  /// Agrega un reporte individual al documento buscando los datos (Legacy)
  Future<void> agregarReporte(int codigo) async {
    print('📊 Obteniendo datos para código: $codigo');

    // Usamos el nuevo método optimizado del repositorio
    final reporte = await PagoRepository.obtenerReporteCompleto(codigo);
    _reportes.add(reporte);

    print('✅ Datos obtenidos para código $codigo');
  }

  /// Genera el PDF con todos los reportes agregados
  Future<String> generarPdf({int numeroReporte = 1385}) async {
    if (_reportes.isEmpty) {
      throw Exception('No hay reportes para generar');
    }

    final pdf = pw.Document();

    // Generar una página por cada reporte
    for (final reporte in _reportes) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [_buildReporte(reporte)],
          footer: (context) => _buildFooter(context),
        ),
      );
    }

    // Guardar PDF
    final output = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${output.path}/reporte_c21_$numeroReporte\_$timestamp.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    print('📄 PDF generado: ${file.path}');
    return file.path;
  }

  /// Construye un reporte individual
  pw.Widget _buildReporte(ReporteIndividual reporte) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título del reporte
        pw.Center(
          child: pw.Text(
            'Reporte C-21 N°: ${reporte.codigo}',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#444444'),
            ),
          ),
        ),
        pw.SizedBox(height: 10),

        // Sección: Extracto y Resumen (lado a lado)
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Datos de Extracto (izquierda)
            pw.Expanded(
              flex: 3,
              child: _buildExtractoSection(reporte.datosExtracto),
            ),
            pw.SizedBox(width: 20),
            // Rubros (derecha)
            pw.Expanded(
              flex: 2,
              child: _buildRubrosSection(reporte.resumenPagos),
            ),
          ],
        ),

        pw.SizedBox(height: 15),

        // Detalle de Emisión de Facturas
        pw.Center(
          child: pw.Text(
            'Detalle de Emisión de Facturas',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#444444'),
            ),
          ),
        ),
        pw.SizedBox(height: 5),

        _buildDetalleSection(reporte.detallePagos),
      ],
    );
  }

  /// Construye la sección de extracto bancario
  pw.Widget _buildExtractoSection(List<MovimientoBancario> extractos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'Datos De Extracto',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#444444'),
            ),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5), // Fecha
            1: const pw.FlexColumnWidth(1), // Sede
            2: const pw.FlexColumnWidth(2.5), // Detalle
            3: const pw.FlexColumnWidth(1.5), // Transacción
            4: const pw.FlexColumnWidth(1.5), // Monto
          },
          children: [
            // Encabezado
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildHeaderCell('Fecha', fontSize: 7),
                _buildHeaderCell('Sede', fontSize: 7),
                _buildHeaderCell('Detalle', fontSize: 7),
                _buildHeaderCell('Transacción', fontSize: 7),
                _buildHeaderCell('Monto', fontSize: 7),
              ],
            ),
            // Datos
            ...extractos.map(
              (e) => pw.TableRow(
                children: [
                  _buildDataCell(_formatDate(e.fecha), fontSize: 6),
                  _buildDataCell(e.depto, fontSize: 6),
                  _buildDataCell(e.detalle, fontSize: 5),
                  _buildDataCell(e.refBancaria, fontSize: 6),
                  _buildDataCell(
                    _formatMonto(e.monto),
                    fontSize: 7,
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la sección de rubros (resumen)
  pw.Widget _buildRubrosSection(List<ResumenPago> resumen) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'RUBROS',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#444444'),
            ),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            // Encabezado
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildHeaderCell('Código Pago', fontSize: 7),
                _buildHeaderCell('Monto Total', fontSize: 7),
              ],
            ),
            // Datos
            ...resumen.map((r) {
              final isTotal = r.codPago == 'TOTAL';
              return pw.TableRow(
                decoration: isTotal
                    ? pw.BoxDecoration(color: PdfColors.grey200)
                    : null,
                children: [
                  _buildDataCell(r.codPago, fontSize: 7, isBold: isTotal),
                  _buildDataCell(
                    _formatMonto(r.totalMonto),
                    fontSize: 7,
                    align: pw.TextAlign.right,
                    isBold: isTotal,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Construye la sección de detalle de pagos
  pw.Widget _buildDetalleSection(List<PagoMatriz> pagos) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8), // Usuario
        1: const pw.FlexColumnWidth(0.5), // Nro
        2: const pw.FlexColumnWidth(0.8), // Nro Factura
        3: const pw.FlexColumnWidth(0.8), // Fecha
        4: const pw.FlexColumnWidth(0.8), // Ref Bancaria
        5: const pw.FlexColumnWidth(0.8), // Carnet
        6: const pw.FlexColumnWidth(1.5), // Nombres
        7: const pw.FlexColumnWidth(0.6), // Cod Pago
        8: const pw.FlexColumnWidth(1.2), // Detalle
        9: const pw.FlexColumnWidth(0.8), // Monto Total
        10: const pw.FlexColumnWidth(1.2), // Objeto
        11: const pw.FlexColumnWidth(0.6), // Volteos
        12: const pw.FlexColumnWidth(0.8), // Monto Siscoin
        13: const pw.FlexColumnWidth(0.8), // Monto Extracto
        14: const pw.FlexColumnWidth(0.8), // Diferencia
        15: const pw.FlexColumnWidth(0.8), // Observación
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildHeaderCell('Usuario', fontSize: 6),
            _buildHeaderCell('Nro', fontSize: 6),
            _buildHeaderCell('Nro Factura', fontSize: 6),
            _buildHeaderCell('Fecha Factura', fontSize: 6),
            _buildHeaderCell('Ref Bancaria', fontSize: 6),
            _buildHeaderCell('Carnet', fontSize: 6),
            _buildHeaderCell('Nombres', fontSize: 6),
            _buildHeaderCell('Cod Pago', fontSize: 6),
            _buildHeaderCell('Detalle', fontSize: 6),
            _buildHeaderCell('Monto Total', fontSize: 6),
            _buildHeaderCell('Objeto', fontSize: 6),
            _buildHeaderCell('Volteos', fontSize: 6),
            _buildHeaderCell('Monto Siscoin', fontSize: 6),
            _buildHeaderCell('Monto Extracto', fontSize: 6),
            _buildHeaderCell('Diferencia Monto', fontSize: 6),
            _buildHeaderCell('Observación', fontSize: 6),
          ],
        ),
        // Datos
        ...pagos.map(
          (p) => pw.TableRow(
            children: [
              _buildDataCell(p.usuario, fontSize: 5),
              _buildDataCell(p.nro.toString(), fontSize: 5),
              _buildDataCell(p.nroFactura.toString(), fontSize: 5),
              _buildDataCell(_formatDate(p.fechaFactura), fontSize: 5),
              _buildDataCell(p.refBancaria, fontSize: 5),
              _buildDataCell(p.carnet, fontSize: 5),
              _buildDataCell(p.nombres, fontSize: 4),
              _buildDataCell(p.codPago.toString(), fontSize: 5),
              _buildDataCell(p.detalle, fontSize: 4),
              _buildDataCell(_formatMonto(p.montoTotal), fontSize: 5),
              _buildDataCell(p.objeto, fontSize: 4),
              _buildDataCell(p.volteos, fontSize: 5),
              _buildDataCell(_formatMonto(p.montoSiscoin), fontSize: 5),
              _buildDataCell(_formatMonto(p.montoExtracto), fontSize: 5),
              _buildDataCell(_formatMonto(p.diferenciaMonto), fontSize: 5),
              _buildDataCell(p.observacion ?? '', fontSize: 5),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye una celda de encabezado
  pw.Widget _buildHeaderCell(String text, {double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#333333'),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Construye una celda de datos
  pw.Widget _buildDataCell(
    String text, {
    double fontSize = 7,
    pw.TextAlign align = pw.TextAlign.left,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(1),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromHex('#555555'),
        ),
        textAlign: align,
      ),
    );
  }

  /// Construye el pie de página
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Center(
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#555555')),
      ),
    );
  }

  /// Formatea una fecha a DD/MM/YYYY
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatea un monto con separador de miles y 2 decimales
  String _formatMonto(double monto) {
    final parts = monto.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

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

  /// Limpia los reportes agregados
  void limpiar() {
    _reportes.clear();
  }
}
