# C21 App

Aplicación Flutter para gestión de documentos y datos con funcionalidades de generación, importación y exportación.

## 📋 Descripción

C21 App es una aplicación desarrollada en Flutter que proporciona tres funcionalidades principales:

1. **Generar Documentos**: Permite crear documentos en diferentes formatos (PDF, XML) o visualizarlos directamente en pantalla
2. **Importar Datos**: Facilita la importación de datos desde archivos CSV en formato de matriz o extracto
3. **Exportar Datos**: Permite exportar datos a diferentes formatos (CSV, Excel, JSON)

## 🏗️ Estructura del Proyecto

```
c21app/
├── lib/
│   ├── main.dart                          # Punto de entrada y menú principal
│   ├── screens/                           # Pantallas de la aplicación
│   │   ├── generar_documento_screen.dart  # Pantalla de generación de documentos
│   │   ├── importar_datos_screen.dart     # Pantalla de importación de datos
│   │   └── exportar_datos_screen.dart     # Pantalla de exportación de datos
│   ├── widgets/                           # Widgets reutilizables (futuro)
│   └── models/                            # Modelos de datos (futuro)
├── test/
│   ├── screens/                           # Tests de pantallas
│   │   ├── main_test.dart
│   │   ├── generar_documento_screen_test.dart
│   │   ├── importar_datos_screen_test.dart
│   │   └── exportar_datos_screen_test.dart
│   └── widgets/                           # Tests de widgets (futuro)
└── README.md
```

## 🚀 Cómo Ejecutar la Aplicación

### Requisitos Previos

- Flutter SDK instalado (versión 3.0 o superior)
- Un editor de código (VS Code, Android Studio, etc.)
- Un navegador web o emulador/dispositivo móvil

### Pasos para Ejecutar

1. **Clonar o navegar al directorio del proyecto**
   ```bash
   cd e:\flutter\c21app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar en Chrome** (recomendado para desarrollo web)
   ```bash
   flutter run -d chrome
   ```

4. **Ejecutar en Windows** (aplicación de escritorio)
   ```bash
   flutter run -d windows
   ```

5. **Ejecutar en un dispositivo específico**
   ```bash
   # Ver dispositivos disponibles
   flutter devices
   
   # Ejecutar en un dispositivo específico
   flutter run -d <device-id>
   ```

### Hot Reload

Durante el desarrollo, puedes usar hot reload para ver cambios instantáneamente:
- Presiona `r` en la terminal para hot reload
- Presiona `R` para hot restart (reinicio completo)

## 🧪 Cómo Ejecutar los Tests

### Ejecutar Todos los Tests

```bash
flutter test
```

### Ejecutar Tests Específicos

```bash
# Test del menú principal
flutter test test/screens/main_test.dart

# Test de generar documentos
flutter test test/screens/generar_documento_screen_test.dart

# Test de importar datos
flutter test test/screens/importar_datos_screen_test.dart

# Test de exportar datos
flutter test test/screens/exportar_datos_screen_test.dart
```

### Ejecutar Tests con Cobertura

```bash
flutter test --coverage
```

## 📱 Funcionalidades Detalladas

### 1. Generar Documentos

La pantalla de generación de documentos ofrece tres opciones:

- **Generar PDF**: Crea un documento en formato PDF
- **Generar XML**: Crea un documento en formato XML
- **Mostrar en Pantalla**: Visualiza el documento directamente en la aplicación

### 2. Importar Datos

La pantalla de importación permite cargar datos desde archivos CSV:

- **Importar Matriz**: Importa datos en formato de matriz (productos, inventario, etc.)
- **Importar Extracto**: Importa datos de extractos (transacciones, pagos, etc.)

Los datos importados se visualizan en un DataTable interactivo en la parte inferior de la pantalla.

### 3. Exportar Datos

La pantalla de exportación ofrece tres formatos de salida:

- **CSV**: Exporta a formato de valores separados por comas
- **Excel**: Exporta a formato Excel (.xlsx)
- **JSON**: Exporta a formato JSON

## 🎨 Diseño

La aplicación utiliza Material Design 3 con los siguientes elementos:

- **Tema**: Colores basados en deepPurple con variaciones personalizadas
- **Navegación**: Sistema de navegación push/pop estándar de Flutter
- **Feedback Visual**: SnackBars para confirmaciones y AlertDialogs para acciones importantes
- **Responsive**: Diseño adaptable a diferentes tamaños de pantalla

## 📚 Documentación del Código

Todos los archivos del proyecto están completamente documentados con comentarios de estilo Dart:

- Documentación de clases con `///`
- Documentación de métodos y funciones
- Comentarios inline para lógica compleja

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **Material Design 3**: Sistema de diseño
- **Flutter Test**: Framework de testing

## 📝 Próximas Mejoras

- [ ] Implementación real de generación de PDF
- [ ] Implementación real de generación de XML
- [ ] Integración con file_picker para selección de archivos CSV
- [ ] Implementación real de exportación a Excel
- [ ] Implementación real de exportación a JSON
- [ ] Persistencia de datos local
- [ ] Validación de datos importados
- [ ] Manejo de errores mejorado

## 👨‍💻 Desarrollo

### Estructura de Código

El proyecto sigue las mejores prácticas de Flutter:

- Separación de concerns (pantallas, widgets, modelos)
- Widgets stateless cuando es posible
- Uso de StatefulWidget solo cuando se necesita estado mutable
- Código limpio y bien documentado

### Convenciones de Nombres

- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables y funciones: `camelCase`
- Constantes: `camelCase` con `const`
- Privados: prefijo `_`

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📧 Contacto

Para preguntas o sugerencias, por favor abre un issue en el repositorio del proyecto.

---

**Nota**: Esta aplicación está en desarrollo activo. Algunas funcionalidades son simuladas con datos de ejemplo y mensajes de confirmación.
