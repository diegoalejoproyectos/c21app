/// Aplicación principal C21 App
///
/// Esta aplicación proporciona funcionalidades para:
/// - Generar documentos en diferentes formatos (PDF, XML)
/// - Importar datos desde archivos CSV
/// - Exportar datos a diferentes formatos
/// - Configurar conexión a base de datos (PostgreSQL o SQLite)
library;
import 'package:flutter/material.dart';
import 'screens/generar_documento_screen.dart';
import 'screens/importar_datos_screen.dart';
import 'screens/exportar_datos_screen.dart';
import 'screens/configuracion_screen.dart';
import 'services/platform/db_platform.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await DbPlatformHelper.init();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error en inicialización: $e');
    print(stackTrace);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C21 App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A29B6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0A29B6),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: const Color(0xFF0A29B6),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MenuPrincipal(),
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  void _navegar(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'C21 App',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A29B6), Color(0xFF1976D2)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.apps,
                    size: 50,
                    color: Colors.white.withAlpha(51), // 0.2 * 255
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Configuración',
                onPressed: () => _navegar(context, const ConfiguracionScreen()),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1,
              ),
              delegate: SliverChildListDelegate([
                _MenuCard(
                  title: 'Generar Documento',
                  icon: Icons.description,
                  color: const Color(0xFF1565C0),
                  onTap: () =>
                      _navegar(context, const GenerarDocumentoScreen()),
                ),
                _MenuCard(
                  title: 'Importar Datos',
                  icon: Icons.file_download,
                  color: const Color(0xFF1976D2),
                  onTap: () => _navegar(context, const ImportarDatosScreen()),
                ),
                _MenuCard(
                  title: 'Exportar Datos',
                  icon: Icons.file_upload,
                  color: const Color(0xFF42A5F5),
                  onTap: () => _navegar(context, const ExportarDatosScreen()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shadowColor: color.withAlpha(77), // 0.3 * 255
      child: InkWell(
        onTap: onTap,
        splashColor: color.withAlpha(51), // 0.2 * 255
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withAlpha(38), // 0.15 * 255
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
