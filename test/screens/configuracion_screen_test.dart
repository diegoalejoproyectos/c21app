import 'package:c21app/models/database_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c21app/screens/configuracion_screen.dart';
import 'package:c21app/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfiguracionScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      final service = DatabaseService();
      await service.clearConfig();
    });

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays configuration form after loading', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      expect(find.text('Tipo de Base de Datos'), findsOneWidget);
      expect(find.byType(RadioListTile<bool>), findsNWidgets(2));
      expect(find.text('Guardar Configuración'), findsOneWidget);
    });

    testWidgets('shows SQLite mode by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      expect(find.text('SQLite (Local)'), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });

    testWidgets('toggle switch changes to PostgreSQL mode', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Find and tap the PostgreSQL option using predicate
      final postgresOption = find.byWidgetPredicate(
        (widget) => widget is RadioListTile<bool> && widget.value == true,
      );
      await tester.tap(postgresOption);
      await tester.pumpAndSettle();

      expect(find.text('PostgreSQL (Remoto)'), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('shows PostgreSQL form fields when enabled', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Toggle to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      expect(find.text('Conexión PostgreSQL'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      expect(find.text('Puerto'), findsOneWidget);
      expect(find.text('Nombre de Base de Datos'), findsOneWidget);
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });

    testWidgets('hides PostgreSQL fields in SQLite mode', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Conexión PostgreSQL'), findsNothing);
      expect(find.text('Host'), findsNothing);
    });

    testWidgets('password field has visibility toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      expect(passwordField, findsOneWidget);

      // Check for visibility toggle button
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('can toggle password visibility', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('validates required fields in PostgreSQL mode', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      // Try to save without filling fields
      await tester.tap(find.text('Guardar Configuración'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('El host es requerido'), findsOneWidget);
      expect(find.text('El puerto es requerido'), findsOneWidget);
      expect(
        find.text('El nombre de la base de datos es requerido'),
        findsOneWidget,
      );
      expect(find.text('El usuario es requerido'), findsOneWidget);
      expect(find.text('La contraseña es requerida'), findsOneWidget);
    });

    testWidgets('validates port number range', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      // Enter invalid port
      final portField = find.widgetWithText(TextFormField, 'Puerto');
      await tester.enterText(portField, '99999');
      await tester.pumpAndSettle();

      // Try to save
      await tester.tap(find.text('Guardar Configuración'));
      await tester.pumpAndSettle();

      expect(find.text('Puerto inválido (1-65535)'), findsOneWidget);
    });

    testWidgets('can enter and save SQLite configuration', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Tap save button (SQLite mode doesn't require fields)
      await tester.tap(find.text('Guardar Configuración'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Configuración guardada exitosamente'), findsOneWidget);
    });

    testWidgets('can enter PostgreSQL configuration', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      // Fill in all fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Host'),
        'localhost',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Puerto'),
        '5432',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de Base de Datos'),
        'testdb',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'testuser',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'testpass',
      );

      await tester.pumpAndSettle();

      // All fields should be filled
      expect(find.text('localhost'), findsOneWidget);
      expect(find.text('5432'), findsOneWidget);
      expect(find.text('testdb'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('save button shows loading state', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Guardar Configuración'));
      await tester.pump(); // Don't settle, check intermediate state

      // Button should show loading text
      expect(find.text('Guardando...'), findsOneWidget);
    });

    testWidgets('loads saved configuration on init', (tester) async {
      // Save a configuration first
      final service = DatabaseService();
      await service.saveConfig(
        const DatabaseConfig(
          useRemoteDatabase: true,
          host: 'saved.example.com',
          port: 5433,
          databaseName: 'saveddb',
          username: 'saveduser',
          password: 'savedpass',
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Should load PostgreSQL mode
      expect(find.text('PostgreSQL (Remoto)'), findsOneWidget);

      // Should load saved values
      expect(find.text('saved.example.com'), findsOneWidget);
      expect(find.text('5433'), findsOneWidget);
      expect(find.text('saveddb'), findsOneWidget);
      expect(find.text('saveduser'), findsOneWidget);
    });

    testWidgets('has proper icons for each field', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfiguracionScreen()));

      await tester.pumpAndSettle();

      // Switch to PostgreSQL mode
      await tester.tap(find.text('PostgreSQL (Remoto)'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dns), findsOneWidget); // Host
      expect(find.byIcon(Icons.settings_ethernet), findsOneWidget); // Port
      expect(find.byIcon(Icons.storage), findsAtLeastNWidgets(1)); // Database
      expect(find.byIcon(Icons.person), findsOneWidget); // Username
      expect(find.byIcon(Icons.lock), findsOneWidget); // Password
    });
  });
}
