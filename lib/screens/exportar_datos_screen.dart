/// Pantalla de exportación de datos
///
/// Esta pantalla permite al usuario exportar datos a diferentes formatos:
/// - CSV: Exporta los datos en formato CSV (valores separados por comas)
/// - Excel: Exporta los datos en formato Excel (.xlsx)
/// - JSON: Exporta los datos en formato JSON
/// - PDF: Exporta los datos en formato PDF con agrupación por código
library;

import 'package:flutter/material.dart';
import '../services/pdf_reporte_service.dart';
import '../services/pago_repository.dart';

/// Widget de la pantalla de exportación de datos
class ExportarDatosScreen extends StatefulWidget {
  const ExportarDatosScreen({super.key});

  @override
  State<ExportarDatosScreen> createState() => _ExportarDatosScreenState();
}

class _ExportarDatosScreenState extends State<ExportarDatosScreen> {
  final TextEditingController _codigoDesdeController = TextEditingController();
  final TextEditingController _codigoHastaController = TextEditingController();
  final TextEditingController _numeroReporteController = TextEditingController(
    text: '1385',
  );

  bool _generandoPdf = false;

  @override
  void dispose() {
    _codigoDesdeController.dispose();
    _codigoHastaController.dispose();
    _numeroReporteController.dispose();
    super.dispose();
  }

  /// Exporta los datos a formato CSV
  void _exportarCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a CSV...'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  /// Exporta los datos a formato Excel
  void _exportarExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a Excel...'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  /// Exporta los datos a formato JSON
  void _exportarJSON(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a JSON...'),
        backgroundColor: Color(0xFF42A5F5),
      ),
    );
  }

  /// Exporta los datos a formato PDF con agrupación por código
  Future<void> _exportarPDF(BuildContext context) async {
    setState(() {
      _generandoPdf = true;
    });

    try {
      // Validar número de reporte
      final numeroReporte = int.tryParse(_numeroReporteController.text) ?? 1385;

      // Parsear códigos desde/hasta
      final codigoDesde = _codigoDesdeController.text.isEmpty
          ? null
          : int.tryParse(_codigoDesdeController.text);
      final codigoHasta = _codigoHastaController.text.isEmpty
          ? null
          : int.tryParse(_codigoHastaController.text);

      final pdfService = PdfReporteService();
      List<int> codigosAProcesar = [];

      // Obtener códigos disponibles
      final codigosDisponibles =
          await PagoRepository.obtenerCodigosDisponibles();

      if (codigoDesde != null && codigoHasta != null) {
        // Filtrar códigos en el rango
        codigosAProcesar = codigosDisponibles
            .where((c) => c >= codigoDesde && c <= codigoHasta)
            .toList();

        if (codigosAProcesar.isEmpty) {
          throw Exception(
            'No hay códigos con datos en el rango seleccionado ($codigoDesde - $codigoHasta)',
          );
        }
      } else {
        // Usar todos los códigos disponibles
        codigosAProcesar = codigosDisponibles;

        if (codigosAProcesar.isEmpty) {
          throw Exception('No hay datos disponibles para generar el reporte');
        }
      }

      // Procesar cada código (limitado a 50 para evitar "Too many pages")
      const maxCodigosPorPdf = 50;
      if (codigosAProcesar.length > maxCodigosPorPdf) {
        if (mounted) {
          final continuar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Muchos códigos'),
              content: Text(
                'Se encontraron ${codigosAProcesar.length} códigos. '
                'Solo se procesarán los primeros $maxCodigosPorPdf para evitar errores. '
                '¿Desea continuar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          );

          if (continuar != true) {
            throw Exception('Operación cancelada por el usuario');
          }
        }
        codigosAProcesar = codigosAProcesar.take(maxCodigosPorPdf).toList();
      }

      // Mostrar progreso
      if (mounted) {
        _mostrarMensaje(
          context,
          'Procesando ${codigosAProcesar.length} códigos...',
          Colors.blue,
        );
      }

      for (final codigo in codigosAProcesar) {
        await pdfService.agregarReporte(codigo);
      }

      // Generar PDF
      final filePath = await pdfService.generarPdf(
        numeroReporte: numeroReporte,
      );

      if (mounted) {
        _mostrarMensaje(context, 'PDF generado correctamente', Colors.green);

        // Abrir vista previa
        await PdfReporteService.previsualizarPdf(filePath);
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(context, 'Error al generar PDF: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _generandoPdf = false;
        });
      }
    }
  }

  void _mostrarMensaje(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exportar Datos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Seleccione el formato de exportación:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Sección de PDF con configuración
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Exportar a PDF',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Número de reporte
                      TextField(
                        controller: _numeroReporteController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Reporte',
                          hintText: 'Ej: 1385',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Rango de códigos
                      const Text(
                        'Rango de códigos (opcional):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codigoDesdeController,
                              decoration: const InputDecoration(
                                labelText: 'Desde',
                                hintText: 'Código inicial',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _codigoHastaController,
                              decoration: const InputDecoration(
                                labelText: 'Hasta',
                                hintText: 'Código final',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Botón generar PDF
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generandoPdf
                              ? null
                              : () => _exportarPDF(context),
                          icon: _generandoPdf
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf, size: 28),
                          label: Text(
                            _generandoPdf ? 'Generando PDF...' : 'Generar PDF',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Otros formatos
              const Text(
                'Otros formatos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Botón Exportar CSV
              ElevatedButton.icon(
                onPressed: () => _exportarCSV(context),
                icon: const Icon(Icons.table_chart, size: 28),
                label: const Text(
                  'Exportar a CSV',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Botón Exportar Excel
              ElevatedButton.icon(
                onPressed: () => _exportarExcel(context),
                icon: const Icon(Icons.file_present, size: 28),
                label: const Text(
                  'Exportar a Excel',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Botón Exportar JSON
              ElevatedButton.icon(
                onPressed: () => _exportarJSON(context),
                icon: const Icon(Icons.data_object, size: 28),
                label: const Text(
                  'Exportar a JSON',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF42A5F5),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
