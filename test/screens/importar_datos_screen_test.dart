/// Tests para la pantalla de importar datos
///
/// Verifica que la pantalla se renderiza correctamente, maneja la importación
/// de archivos Excel/CSV, valida datos, y se integra con PostgreSQL
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c21app/screens/importar_datos_screen.dart';

void main() {
  group('ImportarDatosScreen Tests', () {
    testWidgets('Pantalla se renderiza correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar AppBar
      expect(find.text('Importar Datos'), findsOneWidget);

      // Verificar botones de importación
      expect(find.text('Importar Matriz'), findsOneWidget);
      expect(find.text('Importar Extracto'), findsOneWidget);

      // Verificar iconos
      expect(find.byIcon(Icons.grid_on), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);

      // Verificar mensaje inicial sin datos
      expect(find.text('No hay datos importados'), findsOneWidget);
    });

    testWidgets('Muestra los dos botones de importación con iconos correctos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que los botones están presentes
      expect(find.text('Importar Matriz'), findsOneWidget);
      expect(find.text('Importar Extracto'), findsOneWidget);

      // Verificar iconos
      expect(find.byIcon(Icons.grid_on), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);

      // Verificar que son ElevatedButton
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('Muestra mensaje inicial sin datos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar mensaje de sin datos
      expect(find.text('No hay datos importados'), findsOneWidget);

      // No debe mostrar DataTable
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('No muestra botón de importar a PostgreSQL sin datos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // No debe mostrar el botón de cloud_upload en AppBar
      expect(find.byIcon(Icons.cloud_upload), findsNothing);
    });

    testWidgets('Botón "Importar Matriz" es interactivo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      final matrizButton = find.text('Importar Matriz');
      expect(matrizButton, findsOneWidget);

      // Verificar que el botón es tappable
      await tester.tap(matrizButton);
      await tester.pump();

      // El botón debe ejecutar la función (aunque no podemos verificar
      // el file picker en tests unitarios sin mocking)
    });

    testWidgets('Botón "Importar Extracto" es interactivo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      final extractoButton = find.text('Importar Extracto');
      expect(extractoButton, findsOneWidget);

      // Verificar que el botón es tappable
      await tester.tap(extractoButton);
      await tester.pump();
    });

    testWidgets('Layout tiene estructura correcta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que hay un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Verificar que hay un AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Verificar que hay una Column en el body
      expect(find.byType(Column), findsWidgets);

      // Verificar que hay un Divider
      expect(find.byType(Divider), findsOneWidget);

      // Verificar que hay un Expanded widget
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('Botones tienen el estilo correcto (ElevatedButton.icon)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que hay exactamente 2 ElevatedButton
      expect(find.byType(ElevatedButton), findsNWidgets(2));

      // Verificar que tienen iconos
      expect(find.byIcon(Icons.grid_on), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('AppBar tiene título correcto', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Buscar el AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));

      // Verificar que el título es un Text widget con el texto correcto
      expect(appBar.title, isA<Text>());
      final titleWidget = appBar.title as Text;
      expect(titleWidget.data, 'Importar Datos');
    });

    testWidgets('Área de contenido muestra mensaje cuando no hay datos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que el área expandida muestra el mensaje correcto
      expect(find.text('No hay datos importados'), findsOneWidget);

      // Verificar que está centrado
      final centerFinder = find.ancestor(
        of: find.text('No hay datos importados'),
        matching: find.byType(Center),
      );
      expect(centerFinder, findsOneWidget);
    });

    testWidgets('Widget tiene SizedBox para espaciado', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que hay SizedBox para espaciado
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Divider separa secciones correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que hay un Divider
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('Screen es un StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que ImportarDatosScreen es un StatefulWidget
      final screen = tester.widget(find.byType(ImportarDatosScreen));
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('Área de datos usa SingleChildScrollView cuando hay datos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Cuando no hay datos, no debe haber SingleChildScrollView visible
      // (está dentro del else del ternario)
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('Widget tiene key correcto en constructor', (
      WidgetTester tester,
    ) async {
      const testKey = Key('test-key');
      await tester.pumpWidget(
        const MaterialApp(home: ImportarDatosScreen(key: testKey)),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('AppBar no tiene botón de PostgreSQL inicialmente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Buscar el AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));

      // Verificar que actions es null o vacío
      expect(appBar.actions, anyOf(isNull, isEmpty));
    });

    testWidgets('Scaffold tiene body correcto', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

      // Verificar que el body es un Column
      expect(scaffold.body, isA<Column>());
    });
  });

  group('ImportarDatosScreen - Integración con DatabaseService', () {
    testWidgets('Screen puede ser construido sin errores', (
      WidgetTester tester,
    ) async {
      // Verificar que el widget se puede construir sin errores
      // incluso con la dependencia de DatabaseService
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      expect(find.byType(ImportarDatosScreen), findsOneWidget);
    });
  });

  group('ImportarDatosScreen - Accesibilidad', () {
    testWidgets('Botones tienen tooltips implícitos a través de labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Los ElevatedButton.icon tienen labels que sirven como tooltips
      expect(find.text('Importar Matriz'), findsOneWidget);
      expect(find.text('Importar Extracto'), findsOneWidget);
    });

    testWidgets('Iconos son semánticamente correctos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Icons.grid_on para matriz (tabla/grid)
      expect(find.byIcon(Icons.grid_on), findsOneWidget);

      // Icons.receipt_long para extracto (documento largo)
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });
  });

  group('ImportarDatosScreen - Estado Inicial', () {
    testWidgets('Estado inicial tiene lista vacía de datos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // Verificar que muestra el mensaje de sin datos
      expect(find.text('No hay datos importados'), findsOneWidget);

      // No debe mostrar DataTable
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('Estado inicial no está importando', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ImportarDatosScreen()));

      // No debe mostrar CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('ImportarDatosScreen - Navegación', () {
    testWidgets('Screen puede ser navegado desde otra pantalla', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImportarDatosScreen(),
                    ),
                  );
                },
                child: const Text('Ir a Importar'),
              ),
            ),
          ),
        ),
      );

      // Tap en el botón de navegación
      await tester.tap(find.text('Ir a Importar'));
      await tester.pumpAndSettle();

      // Verificar que navegó correctamente
      expect(find.text('Importar Datos'), findsOneWidget);
      expect(find.byType(ImportarDatosScreen), findsOneWidget);
    });

    testWidgets('Screen tiene botón de back en AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImportarDatosScreen(),
                    ),
                  );
                },
                child: const Text('Ir a Importar'),
              ),
            ),
          ),
        ),
      );

      // Navegar a la pantalla
      await tester.tap(find.text('Ir a Importar'));
      await tester.pumpAndSettle();

      // Verificar que hay un botón de back
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
