/// Tests para la aplicación principal y el menú
///
/// Verifica que la aplicación se inicializa correctamente y que
/// el menú principal funciona como se espera
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c21app/main.dart';

void main() {
  group('MyApp Tests', () {
    testWidgets('App se inicializa correctamente', (WidgetTester tester) async {
      // Construir la app
      await tester.pumpWidget(const MyApp());

      // Verificar que el título "C21 App" está presente
      expect(find.text('C21 App'), findsOneWidget);
    });

    testWidgets('App usa Material Design 3', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verificar que MaterialApp está configurado
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, true);
    });
  });

  group('MenuPrincipal Tests', () {
    testWidgets('Muestra el título "C21 App"', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      expect(find.text('C21 App'), findsOneWidget);
    });

    testWidgets('Muestra los tres botones principales', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      // Verificar que los tres botones están presentes
      expect(find.text('Generar Documento'), findsOneWidget);
      expect(find.text('Importar Datos'), findsOneWidget);
      expect(find.text('Exportar Datos'), findsOneWidget);
    });

    testWidgets('Botón "Generar Documento" navega a la pantalla correcta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      // Tap en el botón "Generar Documento"
      await tester.tap(find.text('Generar Documento'));
      await tester.pumpAndSettle();

      // Verificar que navegó a la pantalla de generar documentos
      expect(find.text('Generar Documento'), findsWidgets);
      expect(find.text('Seleccione el formato de salida:'), findsOneWidget);
    });

    testWidgets('Botón "Importar Datos" navega a la pantalla correcta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      // Tap en el botón "Importar Datos"
      await tester.tap(find.text('Importar Datos'));
      await tester.pumpAndSettle();

      // Verificar que navegó a la pantalla de importar datos
      expect(find.text('Importar Datos'), findsWidgets);
      expect(find.text('Seleccione el tipo de importación:'), findsOneWidget);
    });

    testWidgets('Botón "Exportar Datos" navega a la pantalla correcta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      // Tap en el botón "Exportar Datos"
      await tester.tap(find.text('Exportar Datos'));
      await tester.pumpAndSettle();

      // Verificar que navegó a la pantalla de exportar datos
      expect(find.text('Exportar Datos'), findsWidgets);
      expect(
        find.text('Seleccione el formato de exportación:'),
        findsOneWidget,
      );
    });

    testWidgets('Los botones tienen iconos correctos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MenuPrincipal()));

      // Verificar iconos
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsOneWidget);
      expect(find.byIcon(Icons.file_upload), findsOneWidget);
    });
  });
}
