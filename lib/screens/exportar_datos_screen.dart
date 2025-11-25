/// Pantalla de exportación de datos
///
/// Esta pantalla permite al usuario exportar datos a diferentes formatos:
/// - CSV: Exporta los datos en formato CSV (valores separados por comas)
/// - Excel: Exporta los datos en formato Excel (.xlsx)
/// - JSON: Exporta los datos en formato JSON
library;
import 'package:flutter/material.dart';

/// Widget de la pantalla de exportación de datos
///
/// Proporciona tres botones para diferentes formatos de exportación
class ExportarDatosScreen extends StatelessWidget {
  const ExportarDatosScreen({super.key});

  /// Exporta los datos a formato CSV
  ///
  /// Muestra un mensaje de confirmación al usuario
  void _exportarCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a CSV...'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  /// Exporta los datos a formato Excel
  ///
  /// Muestra un mensaje de confirmación al usuario
  void _exportarExcel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a Excel...'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  /// Exporta los datos a formato JSON
  ///
  /// Muestra un mensaje de confirmación al usuario
  void _exportarJSON(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos a JSON...'),
        backgroundColor: Color(0xFF42A5F5),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Seleccione el formato de exportación:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

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
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

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
