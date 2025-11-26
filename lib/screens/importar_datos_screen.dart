// *****************************************************************************
// IMPORTAR DATOS (EXCEL + CSV) CON STRATEGY PATTERN
// *****************************************************************************
// Este archivo permite:
// 1. Seleccionar el tipo de importación (Matriz o Extracto)
// 2. Importar archivos Excel o CSV usando ArchivoImportService
// 3. Parsear y validar datos usando la estrategia correspondiente
// 4. Enviar datos a PostgreSQL y SQLite

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Modelos
import 'package:c21app/models/tipo_importacion.dart';
import 'package:c21app/models/validation_error.dart';

// Servicios
import 'package:c21app/services/database_service.dart';
import 'package:c21app/services/archivo_import_service.dart';
import 'package:c21app/services/postgres_import_service.dart';
import 'package:c21app/services/sqlite_import_service.dart';
import 'package:c21app/services/strategies/import_strategy.dart';
import 'package:c21app/services/strategies/matriz_strategy.dart';
import 'package:c21app/services/strategies/extracto_strategy.dart';

/// Pantalla principal para importar datos usando Strategy Pattern
class ImportarDatosScreen extends StatefulWidget {
  const ImportarDatosScreen({super.key});

  @override
  State<ImportarDatosScreen> createState() => _ImportarDatosScreenState();
}

class _ImportarDatosScreenState extends State<ImportarDatosScreen> {
  // Tipo de importación seleccionado
  TipoImportacion? _tipoSeleccionado;

  // Estrategia actual basada en el tipo seleccionado
  ImportStrategy? _estrategiaActual;

  // Datos crudos importados desde el archivo
  List<Map<String, dynamic>> _datosImportados = [];

  // Datos parseados por la estrategia
  List<dynamic> _datosParsed = [];

  // Errores de validación
  List<ValidationError> _erroresValidacion = [];

  // Indica si se está importando a BD
  bool _importando = false;

  // Servicio de base de datos
  final DatabaseService _dbService = DatabaseService();

  // ===========================================================================
  //                    SELECCIONAR TIPO DE IMPORTACIÓN
  // ===========================================================================
  void _seleccionarTipo(TipoImportacion tipo) {
    setState(() {
      _tipoSeleccionado = tipo;

      // Crear la estrategia correspondiente
      switch (tipo) {
        case TipoImportacion.matriz:
          _estrategiaActual = MatrizStrategy();
          break;
        case TipoImportacion.extractoBancario:
          _estrategiaActual = ExtractoStrategy();
          break;
      }

      // Limpiar datos anteriores
      _datosImportados = [];
      _datosParsed = [];
      _erroresValidacion = [];
    });

    print('📌 [Screen] Tipo seleccionado: ${tipo.displayName}');
    print('📌 [Screen] Estrategia: ${_estrategiaActual.runtimeType}');
  }

  // ===========================================================================
  //                        CARGAR ARCHIVO
  // ===========================================================================
  Future<void> _cargarArchivo() async {
    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero seleccione el tipo de importación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Abrir explorador de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No seleccionaste ningún archivo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final filePath = result.files.single.path!;
      print('📂 [Screen] Archivo seleccionado: $filePath');

      // Importar archivo usando el servicio centralizado
      final datos = await ArchivoImportService.importarArchivo(filePath);

      print('📊 [Screen] Datos importados: ${datos.length} filas');

      // Parsear datos usando la estrategia
      final parsed = _estrategiaActual!.parsear(datos);
      print('✅ [Screen] Datos parseados: ${parsed.length} items');

      // Validar datos
      final errores = _estrategiaActual!.validar(parsed);
      print('🔍 [Screen] Errores de validación: ${errores.length}');

      setState(() {
        _datosImportados = datos;
        _datosParsed = parsed;
        _erroresValidacion = errores;
      });

      // Notificar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Datos de ${_tipoSeleccionado!.displayName} importados: ${parsed.length} registros',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Si hay errores, mostrar advertencia
      if (errores.isNotEmpty) {
        _mostrarDialogoErrores(errores);
      }
    } catch (e) {
      print('❌ [Screen] Error al cargar archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===========================================================================
  //                    ENVIAR DATOS A BASE DE DATOS
  // ===========================================================================
  Future<void> _enviarABaseDatos() async {
    if (_datosParsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay datos para enviar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Obtener configuración
    final config = await _dbService.getConfig();

    // Verificar si PostgreSQL está habilitado
    if (!config.useRemoteDatabase) {
      _mostrarDialogoConfiguracion();
      return;
    }

    // Si hay errores de validación, preguntar si continuar
    if (_erroresValidacion.isNotEmpty) {
      final continuar = await _mostrarDialogoContinuarConErrores(
        _erroresValidacion.length,
      );
      if (!continuar) {
        return;
      }
    }

    setState(() {
      _importando = true;
    });

    try {
      print('🚀 [Screen] Iniciando envío a base de datos...');
      print('📊 [Screen] Items a enviar: ${_datosParsed.length}');
      print('📋 [Screen] Tabla destino: ${_estrategiaActual!.tableName}');

      // 1. Enviar a PostgreSQL usando INSERT simple
      final resultadoPostgres = await PostgresImportService.importarConInsert(
        items: _datosParsed,
        config: config,
        tableName: _estrategiaActual!.tableName,
        toMapFunction: _estrategiaActual!.toMap,
      );

      print('✅ [Screen] PostgreSQL: ${resultadoPostgres.message}');

      // 2. Enviar a SQLite local
      final resultadoSqlite = await SqliteImportService.importar(
        items: _datosParsed,
        tableName: _estrategiaActual!.tableName,
        toMapFunction: _estrategiaActual!.toMap,
      );

      print('✅ [Screen] SQLite: ${resultadoSqlite.message}');

      // Mostrar resultado combinado
      final mensaje =
          '''
PostgreSQL: ${resultadoPostgres.message}
SQLite: ${resultadoSqlite.message}
      ''';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: resultadoPostgres.success && resultadoSqlite.success
              ? Colors.green
              : Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );

      // Si todo fue exitoso, limpiar datos
      if (resultadoPostgres.success && resultadoSqlite.success) {
        setState(() {
          _datosImportados = [];
          _datosParsed = [];
          _erroresValidacion = [];
        });
      }
    } catch (e) {
      print('❌ [Screen] Error durante envío: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error durante el envío: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _importando = false;
      });
    }
  }

  // ===========================================================================
  //                              DIÁLOGOS
  // ===========================================================================

  void _mostrarDialogoErrores(List<ValidationError> errores) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Advertencias de Validación (${errores.length})'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: min(errores.length, 20), // Mostrar máximo 20
              itemBuilder: (context, index) {
                final e = errores[index];
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text('Fila ${e.row}'),
                  subtitle: Text('${e.field}: ${e.message}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Entendido'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
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
                // TODO: Navegar a pantalla de configuración
              },
              child: const Text('Configurar'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  //                                  UI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Datos'),
        actions: [
          // Botón para enviar a BD (solo visible si hay datos)
          if (_datosParsed.isNotEmpty)
            IconButton(
              tooltip: 'Enviar a Base de Datos',
              icon: _importando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              onPressed: _importando ? null : _enviarABaseDatos,
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          // Indicador del tipo seleccionado
          if (_tipoSeleccionado != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Tipo: ${_tipoSeleccionado!.displayName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      if (_datosParsed.isNotEmpty)
                        Text(
                          '${_datosParsed.length} registros',
                          style: const TextStyle(color: Colors.blue),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Botones de selección de tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.grid_on),
                    label: const Text('Importar Matriz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _tipoSeleccionado == TipoImportacion.matriz
                          ? Colors.blue
                          : null,
                      foregroundColor:
                          _tipoSeleccionado == TipoImportacion.matriz
                          ? Colors.white
                          : null,
                    ),
                    onPressed: () => _seleccionarTipo(TipoImportacion.matriz),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Importar Extracto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _tipoSeleccionado == TipoImportacion.extractoBancario
                          ? Colors.blue
                          : null,
                      foregroundColor:
                          _tipoSeleccionado == TipoImportacion.extractoBancario
                          ? Colors.white
                          : null,
                    ),
                    onPressed: () =>
                        _seleccionarTipo(TipoImportacion.extractoBancario),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Botón para cargar archivo
          if (_tipoSeleccionado != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Seleccionar Archivo (Excel/CSV)'),
                  onPressed: _cargarArchivo,
                ),
              ),
            ),

          const Divider(),

          // Tabla con los datos importados
          Expanded(
            child: _datosImportados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay datos importados',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seleccione un tipo y cargue un archivo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }
}
