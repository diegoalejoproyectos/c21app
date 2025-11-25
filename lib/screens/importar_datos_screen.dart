// *****************************************************************************
// IMPORTAR DATOS (EXCEL + CSV) + IMPORTAR A POSTGRESQL
// *****************************************************************************

import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

// Tus servicios (deben existir)
import 'package:c21app/services/database_service.dart';
import 'package:c21app/services/postgres_import_service.dart';

class ImportarDatosScreen extends StatefulWidget {
  const ImportarDatosScreen({super.key});

  @override
  State<ImportarDatosScreen> createState() => _ImportarDatosScreenState();
}

class _ImportarDatosScreenState extends State<ImportarDatosScreen> {
  List<Map<String, dynamic>> _datosImportados = [];
  bool _importando = false;

  // Servicio de configuración DB
  final DatabaseService _dbService = DatabaseService();

  // ===========================================================================
  //                            IMPORTAR A POSTGRESQL
  // ===========================================================================
  Future<void> _importarAPostgres() async {
    if (_datosImportados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No hay datos para importar"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('=== INICIANDO IMPORTACIÓN ===');
    print('Datos importados crudos: ${_datosImportados.length} registros');

    // Mostrar estructura del primer registro
    if (_datosImportados.isNotEmpty) {
      print('=== PRIMER REGISTRO CRUDO ===');
      _datosImportados[0].forEach((key, value) {
        print('$key: "$value" (tipo: ${value.runtimeType})');
      });
    }

    // Obtener configuración de base de datos
    final config = await _dbService.getConfig();

    if (!config.useRemoteDatabase) {
      _mostrarDialogoConfiguracion();
      return;
    }

    setState(() {
      _importando = true;
    });

    try {
      // Convertir datos a objetos MovimientoBancario
      print('=== PARSEANDO MOVIMIENTOS ===');
      final movimientos = PostgresImportService.parseMovimientosBancarios(
        _datosImportados,
      );

      print('Movimientos parseados: ${movimientos.length}');

      if (movimientos.isNotEmpty) {
        print('=== PRIMER MOVIMIENTO PARSEADO ===');
        print(movimientos[0].toString());
      }

      // TEMPORAL: Usar validación relajada para debugging
      print('=== VALIDANDO DATOS (MODO RELAJADO) ===');
      final errores = PostgresImportService.validarMovimientosRelajada(
        movimientos,
      );

      print('Errores de validación: ${errores.length}');
      if (errores.isNotEmpty) {
        for (int i = 0; i < min(5, errores.length); i++) {
          print('Error ${i + 1}: ${errores[i]}');
        }

        // Preguntar si quiere continuar a pesar de los errores
        final continuar = await _mostrarDialogoContinuarConErrores(
          errores.length,
        );
        if (!continuar) {
          return;
        }
      }

      // Importar a PostgreSQL
      print('=== IMPORTANDO A POSTGRESQL ===');
      final resultado =
          await PostgresImportService.importarMovimientosConUpsert(
            movimientos: movimientos,
            config: config,
          );

      print('Resultado importación: ${resultado.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.message),
          backgroundColor: resultado.success ? Colors.green : Colors.red,
        ),
      );

      if (resultado.success) {
        setState(() {
          _datosImportados = [];
        });
      }
    } catch (e) {
      print('❌ ERROR EN IMPORTACIÓN: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error durante la importación: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _importando = false;
      });
    }
  }

  Future<bool> _mostrarDialogoContinuarConErrores(int errorCount) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Errores de Validación'),
              content: Text(
                'Se encontraron $errorCount errores de validación. '
                '¿Desea continuar con la importación?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // ===========================================================================
  //                        DIÁLOGOS DE CONFIGURACIÓN
  // ===========================================================================
  void _mostrarDialogoConfiguracion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configuración Requerida'),
          content: const Text(
            'Debe configurar la conexión a PostgreSQL antes de importar. '
            '¿Desea ir a la configuración?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigator.push(context, MaterialPageRoute(builder: (_) => ConfigScreen()));
              },
              child: const Text('Configurar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarErroresValidacion(List<ValidationError> errores) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Errores de Validación"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: errores.length,
              itemBuilder: (context, index) {
                final e = errores[index];
                return ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text("Fila ${e.row}"),
                  subtitle: Text("${e.field}: ${e.message}"),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Entendido"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  //                        IMPORTAR EXCEL / CSV
  // ===========================================================================
  Future<void> _cargarDatosDesdeArchivo(String tipo) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No seleccionaste ningún archivo"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      File file = File(result.files.single.path!);
      String path = file.path.toLowerCase();

      List<Map<String, dynamic>> datos = [];

      // ---------------- EXCEL ----------------
      if (path.endsWith(".xlsx")) {
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);

        final sheet = excel.tables[excel.tables.keys.first]!;
        List<String> headers = [];

        for (int r = 0; r < sheet.maxRows; r++) {
          final row = sheet.row(r);

          if (r == 0) {
            headers = row.map((c) => c?.value.toString() ?? "").toList();
          } else {
            Map<String, dynamic> fila = {};
            for (int i = 0; i < headers.length; i++) {
              fila[headers[i]] = row[i]?.value.toString() ?? "";
            }
            datos.add(fila);
          }
        }
      }
      // ---------------- CSV ----------------
      else if (path.endsWith(".csv")) {
        String content;
        try {
          content = await file.readAsString(encoding: utf8);
        } catch (_) {
          content = await file.readAsString(encoding: latin1);
        }

        List<String> lineas = content
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList();

        String delimiter = lineas.first.contains(';') ? ';' : ',';

        List<String> headers = lineas.first
            .split(delimiter)
            .map((e) => e.trim())
            .toList();

        for (int i = 1; i < lineas.length; i++) {
          final cols = lineas[i].split(delimiter).map((e) => e.trim()).toList();
          Map<String, dynamic> fila = {};

          for (int x = 0; x < headers.length; x++) {
            fila[headers[x]] = x < cols.length ? cols[x] : "";
          }

          datos.add(fila);
        }
      }

      setState(() => _datosImportados = datos);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Datos de $tipo importados correctamente"),
          backgroundColor: const Color(0xFF1976D2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al importar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===========================================================================
  //                            UI COMPLETA
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Importar Datos"),
        actions: [
          if (_datosImportados.isNotEmpty)
            IconButton(
              tooltip: "Importar a PostgreSQL",
              icon: _importando
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.cloud_upload),
              onPressed: _importando ? null : _importarAPostgres,
            ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          ElevatedButton.icon(
            icon: const Icon(Icons.grid_on),
            label: const Text("Importar Matriz"),
            onPressed: () => _cargarDatosDesdeArchivo("Matriz"),
          ),

          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text("Importar Extracto"),
            onPressed: () => _cargarDatosDesdeArchivo("Extracto"),
          ),

          const Divider(),

          Expanded(
            child: _datosImportados.isEmpty
                ? const Center(child: Text("No hay datos importados"))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: _datosImportados[0].keys
                          .map((k) => DataColumn(label: Text(k)))
                          .toList(),
                      rows: _datosImportados.map((fila) {
                        return DataRow(
                          cells: fila.values
                              .map((v) => DataCell(Text(v.toString())))
                              .toList(),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
