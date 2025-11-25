/// Pantalla de configuración de base de datos
/// Permite al usuario configurar la conexión a PostgreSQL
/// o usar SQLite en modo sin conexión
library;

import 'package:flutter/material.dart';
import '../models/database_config.dart';
import '../services/database_service.dart';

/// Widget de la pantalla de configuración
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

/// Estado de la pantalla de configuración
class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  // Controladores de texto
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _databaseNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estado
  bool _useRemoteDatabase = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _databaseNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Cargar configuración guardada
  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);

    try {
      final config = await _databaseService.getConfig();

      setState(() {
        _useRemoteDatabase = config.useRemoteDatabase;
        _hostController.text = config.host;
        _portController.text = config.port.toString();
        _databaseNameController.text = config.databaseName;
        _usernameController.text = config.username;
        _passwordController.text = config.password;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar configuración: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Guardar configuración
  Future<void> _saveConfig() async {
    if (_useRemoteDatabase && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final config = DatabaseConfig(
        useRemoteDatabase: _useRemoteDatabase,
        host: _hostController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 5432,
        databaseName: _databaseNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Si es conexión remota, probar la conexión
      if (_useRemoteDatabase) {
        final isValid = await _databaseService.testPostgresConnection(config);
        if (!isValid && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('No se pudo conectar. Verifica los datos.'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      await _databaseService.saveConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Configuración guardada exitosamente'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Tipo de Base de Datos'),
                    const SizedBox(height: 16),
                    _buildDatabaseTypeCard(),
                    const SizedBox(height: 32),
                    AnimatedCrossFade(
                      firstChild: Container(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle('Conexión PostgreSQL'),
                          const SizedBox(height: 16),
                          _buildPostgresForm(),
                        ],
                      ),
                      crossFadeState: _useRemoteDatabase
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveConfig,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? "Guardando..." : "Guardar Configuración",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDatabaseTypeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            RadioListTile<bool>(
              title: const Text(
                'SQLite (Local)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Base de datos interna sin conexión'),
              value: false,
              groupValue: _useRemoteDatabase,
              onChanged: (value) => setState(() => _useRemoteDatabase = value!),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.storage, color: Colors.blue.shade700),
              ),
              activeColor: Theme.of(context).primaryColor,
            ),
            const Divider(height: 1),
            RadioListTile<bool>(
              title: const Text(
                'PostgreSQL (Remoto)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Conectar a servidor externo'),
              value: true,
              groupValue: _useRemoteDatabase,
              onChanged: (value) => setState(() => _useRemoteDatabase = value!),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.cloud, color: Colors.indigo.shade700),
              ),
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostgresForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _hostController,
                    label: 'Host',
                    hint: '192.168.1.10',
                    icon: Icons.dns,
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _portController,
                    label: 'Puerto',
                    hint: '5432',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Req.';
                      final p = int.tryParse(v!);
                      if (p == null || p < 1 || p > 65535) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _databaseNameController,
              label: 'Base de Datos',
              hint: 'nombre_db',
              icon: Icons.dataset,
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _usernameController,
              label: 'Usuario',
              hint: 'postgres',
              icon: Icons.person,
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock,
              isPassword: true,
              validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
      validator: validator,
    );
  }
}
