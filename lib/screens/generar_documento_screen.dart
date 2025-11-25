/// Pantalla de generación de documentos
///
/// Esta pantalla permite al usuario generar documentos en diferentes formatos:
/// - PDF: Genera un documento en formato PDF
/// - XML: Genera un documento en formato XML
/// - Mostrar en Pantalla: Visualiza el documento directamente en la aplicación
library;
import 'package:flutter/material.dart';

/// Widget de la pantalla de generación de documentos
///
/// Proporciona tres botones para diferentes formatos de salida
class GenerarDocumentoScreen extends StatelessWidget {
  const GenerarDocumentoScreen({super.key});

  /// Genera un documento en formato PDF
  ///
  /// Muestra un mensaje de confirmación al usuario
  void _generarPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando documento en PDF...'),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
  }

  /// Genera un documento en formato XML
  ///
  /// Muestra un mensaje de confirmación al usuario
  void _generarXML(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando documento en XML...'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  /// Muestra el documento directamente en pantalla
  ///
  /// Visualiza el documento sin necesidad de exportarlo
  void _mostrarEnPantalla(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mostrando documento en pantalla...'),
        backgroundColor: Color(0xFF42A5F5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generar Documento',
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
                'Seleccione el formato de salida:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botón Generar PDF
              ElevatedButton.icon(
                onPressed: () => _generarPDF(context),
                icon: const Icon(Icons.picture_as_pdf, size: 28),
                label: const Text(
                  'Generar PDF',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Botón Generar XML
              ElevatedButton.icon(
                onPressed: () => _generarXML(context),
                icon: const Icon(Icons.code, size: 28),
                label: const Text(
                  'Generar XML',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Botón Mostrar en Pantalla
              ElevatedButton.icon(
                onPressed: () => _mostrarEnPantalla(context),
                icon: const Icon(Icons.visibility, size: 28),
                label: const Text(
                  'Mostrar en Pantalla',
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
