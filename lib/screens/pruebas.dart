import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

class TestPostgresButton extends StatefulWidget {
  const TestPostgresButton({super.key});

  @override
  State<TestPostgresButton> createState() => _TestPostgresButtonState();
}

class _TestPostgresButtonState extends State<TestPostgresButton> {
  bool _loading = false;

  Future<void> _testConnection() async {
    setState(() => _loading = true);

    try {
      final conn = PostgreSQLConnection(
        "TU_HOST",       // Ej: 127.0.0.1
        5432,            // Puerto PostgreSQL
        "TU_DATABASE",   // Nombre base de datos
        username: "TU_USUARIO",
        password: "TU_PASSWORD",
      );

      await conn.open();

      if (conn.isClosed == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Conexión exitosa a PostgreSQL")),
        );
      }

      await conn.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al conectar: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading ? null : _testConnection,
      child: _loading
          ? const CircularProgressIndicator()
          : const Text("Probar conexión PostgreSQL"),
    );
  }
}
