/// Tests para la pantalla de generar documentos
///
/// Verifica que la pantalla se renderiza correctamente y que
/// los botones funcionan como se espera
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c21app/screens/generar_documento_screen.dart';

void main() {
  group('GenerarDocumentoScreen Tests', () {
    testWidgets('Pantalla se renderiza correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Verificar título
      expect(find.text('Generar Documento'), findsOneWidget);

      // Verificar texto descriptivo
      expect(find.text('Seleccione el formato de salida:'), findsOneWidget);
    });

    testWidgets('Muestra los tres botones de formato', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Verificar que los tres botones están presentes
      expect(find.text('Generar PDF'), findsOneWidget);
      expect(find.text('Generar XML'), findsOneWidget);
      expect(find.text('Mostrar en Pantalla'), findsOneWidget);
    });

    testWidgets('Botones tienen los iconos correctos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Verificar iconos
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Botón "Generar PDF" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Tap en el botón
      await tester.tap(find.text('Generar PDF'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Generando documento en PDF...'), findsOneWidget);
    });

    testWidgets('Botón "Generar XML" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Tap en el botón
      await tester.tap(find.text('Generar XML'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Generando documento en XML...'), findsOneWidget);
    });

    testWidgets('Botón "Mostrar en Pantalla" muestra SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenerarDocumentoScreen()),
      );

      // Tap en el botón
      await tester.tap(find.text('Mostrar en Pantalla'));
      await tester.pump();

      // Verificar que aparece el SnackBar
      expect(find.text('Mostrando documento en pantalla...'), findsOneWidget);
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
                    builder: (_) => const GenerarDocumentoScreen(),
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
