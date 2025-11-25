/// Tests para la pantalla de exportar datos
///
/// Verifica que la pantalla se renderiza correctamente y que
/// los botones funcionan como se espera
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c21app/screens/exportar_datos_screen.dart';

void main() {
  group('ExportarDatosScreen Tests', () {
    testWidgets('Pantalla se renderiza correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Verificar título
      expect(find.text('Exportar Datos'), findsOneWidget);

      // Verificar texto descriptivo
      expect(
        find.text('Seleccione el formato de exportación:'),
        findsOneWidget,
      );
    });

    testWidgets('Muestra los tres botones de exportación', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Verificar que los tres botones están presentes
      expect(find.text('Exportar a CSV'), findsOneWidget);
      expect(find.text('Exportar a Excel'), findsOneWidget);
      expect(find.text('Exportar a JSON'), findsOneWidget);
    });

    testWidgets('Botones tienen los iconos correctos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Verificar iconos
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
      expect(find.byIcon(Icons.file_present), findsOneWidget);
      expect(find.byIcon(Icons.data_object), findsOneWidget);
    });

    testWidgets('Botón "Exportar a CSV" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Tap en el botón
      await tester.tap(find.text('Exportar a CSV'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Exportando datos a CSV...'), findsOneWidget);
    });

    testWidgets('Botón "Exportar a Excel" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Tap en el botón
      await tester.tap(find.text('Exportar a Excel'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Exportando datos a Excel...'), findsOneWidget);
    });

    testWidgets('Botón "Exportar a JSON" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ExportarDatosScreen()));

      // Tap en el botón
      await tester.tap(find.text('Exportar a JSON'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Exportando datos a JSON...'), findsOneWidget);
    });

    testWidgets('Tiene botón de retroceso en AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExportarDatosScreen(),
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      // Navegar a la pantalla
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Verificar que hay botón de retroceso
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
