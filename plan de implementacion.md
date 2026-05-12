# 📋 Plan de Implementación: **ArtStore** (Tienda de Suministros para Arte)

> **Nota previa:** "Antigravity" no es un IDE reconocido para desarrollo Flutter. Se utilizará **VS Code** como entorno principal, que es ampliamente soportado, ligero y cuenta con extensiones oficiales para Flutter y Firebase.

---

## 🧭 Visión General
Desarrollo de una aplicación multiplataforma (Android, iOS, Web) con Flutter/Dart, backend en Firebase, autenticación por email/contraseña, base de datos Firestore, gestión de estado con `Provider` y arquitectura escalable orientada a UX/UI profesional.

---

## 🛠️ FASE 1: Configuración del Entorno de Desarrollo
1. **Instalar SDKs y herramientas base**
   - Flutter SDK + Dart SDK (versión estable más reciente)
   - Git para control de versiones
   - VS Code (última versión estable)
2. **Configurar VS Code**
   - Extensiones recomendadas: `Flutter`, `Dart`, `Firebase`, `Pubspec Assist`, `Error Lens`, `Flutter Riverpod/Provider Snippets`
   - Configurar formateador y linter (`dart format`, `dart analyze`)
3. **Validar entorno**
   - Ejecutar `flutter doctor` y resolver advertencias (Android SDK, Xcode si aplica, emuladores/dispositivos físicos)
4. **Preparar Firebase Console**
   - Crear proyecto `ArtStore`
   - Registrar apps (Android, iOS, Web) y descargar archivos de configuración (`google-services.json`, `GoogleService-Info.plist`, `firebase.js`)
   - Habilitar **Authentication** (método Email/Password)
   - Habilitar **Firestore Database** (modo de prueba inicialmente)

---

## 🎨 FASE 2: Diseño UI/UX y Arquitectura
1. **Definir flujos de usuario**
   - Onboarding → Login/Registro → Catálogo → Detalle de Producto → Carrito → Checkout → Perfil
2. **Crear wireframes y prototipos**
   - Herramientas: Figma o Penpot
   - Definir paleta cromática inspirada en arte (ej. tonos neutros + acentos vibrantes)
   - Tipografía legible y jerarquía visual clara para precios, categorías y descripciones
3. **Establecer arquitectura del proyecto**
   - Patrón recomendado: **Feature-First + Clean Architecture simplificada**
   - Capas: `presentation/`, `domain/`, `data/`, `core/`
   - Estructura de carpetas base:
     ```
     lib/
     ├── core/
     ├── features/
     │   ├── auth/
     │   ├── catalog/
     │   ├── cart/
     │   └── profile/
     ├── shared/
     └── main.dart
     ```
4. **Validar accesibilidad y responsividad**
   - Soporte para modo claro/oscuro
   - Layouts adaptables a móvil, tablet y web

---

## 📦 FASE 3: Configuración del Proyecto y Dependencias
1. **Crear proyecto Flutter**
   - `flutter create artstore --platforms android,ios,web`
2. **Definir dependencias en `pubspec.yaml`** (lista conceptual, sin código de implementación)
   - **Núcleo:** `flutter`, `dart`
   - **Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` (para imágenes), `firebase_analytics`, `firebase_crashlytics`
   - **Estado:** `provider`, `flutter_hooks` (opcional)
   - **UI/UX:** `go_router` (navegación), `cached_network_image`, `flutter_svg`, `lottie`, `intl` (formatos), `google_fonts`
   - **Utilidades:** `uuid`, `collection`, `equatable`, `flutter_secure_storage` (tokens/sesiones), `envied` o `flutter_dotenv` (variables de entorno)
   - **Desarrollo:** `mockito`, `build_runner`, `flutter_test`
3. **Integrar Firebase en el proyecto**
   - Instalar Firebase CLI
   - Ejecutar `flutterfire configure` para generar `firebase_options.dart`
   - Verificar inicialización en `main.dart` (conceptual, sin código)
4. **Configurar reglas de seguridad iniciales**
   - Firestore: permitir lectura/escritura solo a usuarios autenticados
   - Storage: restringir acceso por UID de usuario

---

## 🔐 FASE 4: Autenticación (Email / Contraseña)
1. **Diseñar modelos de usuario**
   - Campos: `uid`, `email`, `displayName`, `createdAt`, `role` (cliente/admin)
2. **Implementar capa de servicio de Auth**
   - Métodos: `signIn`, `signUp`, `signOut`, `resetPassword`, `listenToAuthState`
   - Manejo de excepciones de Firebase (contraseña débil, email duplicado, etc.)
3. **Construir pantallas de Auth**
   - Login: campos, validación, botón de acceso, enlace a registro
   - Registro: campos adicionales, términos, confirmación
   - Recuperación: flujo de email de restablecimiento
4. **Gestión de sesión persistente**
   - Escuchar `authStateChanges()` para redirigir automáticamente
   - Mostrar estado de carga y mensajes de error amigables

---

## 🗄️ FASE 5: Integración con Cloud Firestore
1. **Diseñar esquema de base de datos**
   - `users/{uid}` → perfil, direcciones, historial
   - `products/{id}` → nombre, categoría, precio, stock, imágenes, descripción
   - `categories/{id}` → nombre, icono, orden
   - `carts/{uid}` → items, cantidades, total
   - `orders/{id}` → usuario, items, estado, fecha, total
2. **Implementar repositorios de datos**
   - Abstracción de operaciones CRUD
   - Manejo de streams y `Future` para UI reactiva
   - Paginación para catálogos grandes (`limit`, `startAfterDocument`)
3. **Optimizar consultas**
   - Índices compuestos para filtros (categoría + precio + stock)
   - Desnormalización controlada para lecturas frecuentes
4. **Validar reglas de seguridad en producción**
   - Restringir escritura de productos a roles `admin`
   - Permitir lectura pública de catálogo, escritura de carrito/pedidos solo a propietarios

---

## 🔄 FASE 6: Gestión de Estado con Provider
1. **Definir `ChangeNotifier` principales**
   - `AuthProvider`: estado de sesión, usuario actual, permisos
   - `CatalogProvider`: lista de productos, filtros, búsqueda, estado de carga
   - `CartProvider`: items, cantidades, cálculo de totales, persistencia local opcional
   - `UIProvider`: tema, navegación, snackbars/diálogos globales
2. **Inyectar Providers en la app**
   - Estructura jerárquica en `main.dart` o por feature
   - Evitar reconstrucciones innecesarias con `Consumer` y `Selector`
3. **Conectar capa de datos con estado**
   - Streams de Firestore escuchados por Providers
   - Actualización optimista en carrito y perfil
   - Manejo centralizado de errores y estados de carga

---

## 🛒 FASE 7: Desarrollo de Funcionalidades Core
1. **Navegación y enrutamiento**
   - Configuración de rutas con `go_router` o `Navigator 2.0`
   - Rutas protegidas (solo autenticados)
   - Transiciones y deep links básicos
2. **Catálogo y búsqueda**
   - Grid/List adaptativo
   - Filtros por categoría, precio, disponibilidad
   - Barra de búsqueda con debounce
3. **Detalle de producto**
   - Galería de imágenes, zoom, variantes
   - Selector de cantidad, botón "Agregar al carrito"
   - Indicadores de stock y reseñas (futuro)
4. **Carrito y Checkout**
   - Edición de cantidades, eliminación, resumen
   - Cálculo de impuestos/envío (simulado inicialmente)
   - Generación de orden en Firestore
5. **Perfil y configuración**
   - Editar datos, cambiar contraseña, cerrar sesión
   - Historial de pedidos con estado
   - Preferencias de tema y notificaciones

---

## 🧪 FASE 8: Pruebas y Optimización
1. **Pruebas técnicas**
   - Unit tests: lógica de negocio, validaciones, cálculos de carrito
   - Widget tests: pantallas de login, catálogo, carrito
   - Integration tests: flujo completo autenticado
2. **Optimización de rendimiento**
   - Lazy loading de imágenes y listas
   - Uso de `const` y `RepaintBoundary` donde aplique
   - Minimizar rebuilds con `Provider` selectivos
3. **Revisión UX/UI**
   - Feedback táctil y visual (ripples, loading states)
   - Mensajes de error claros y acciones recuperables
   - Cumplimiento de guidelines de Material/Cupertino

---

## 🚀 FASE 9: Despliegue y Mantenimiento
1. **Preparar builds**
   - `flutter build apk --release`, `flutter build ipa`, `flutter build web`
   - Optimización de assets y tree shaking
2. **CI/CD básico**
   - GitHub Actions para lint, test y build automático
   - Verificación de compatibilidad multiplataforma
3. **Monitoreo en producción**
   - Firebase Analytics: eventos clave (login, add_to_cart, purchase)
   - Crashlytics: reporte de errores en tiempo real
   - Performance Monitoring: tiempos de carga de Firestore y red
4. **Documentación y entregables**
   - README con pasos de instalación y variables de entorno
   - Guía de arquitectura y decisiones técnicas
   - Plan de iteraciones futuras (pagos, reseñas, push notifications, modo offline)

---

## ✅ Checklist de Validación antes de codificar
- [ ] Entorno Flutter + VS Code + Firebase CLI funcionando
- [ ] Proyecto Firebase creado con Auth y Firestore habilitados
- [ ] Wireframes y guía de estilo aprobados
- [ ] Estructura de carpetas y dependencias definidas
- [ ] Esquema de Firestore y reglas de seguridad revisadas
- [ ] Flujo de estado con `Provider` mapeado
- [ ] Criterios de aceptación por feature documentados

---

📌 **Próximo paso:** Cuando este plan esté aprobado, puedo generar el **código base estructurado**, incluyendo `pubspec.yaml` completo, inicialización de Firebase, arquitectura de carpetas, y los primeros `ChangeNotifier` y pantallas de autenticación. ¿Deseas ajustar alguna fase o proceder con la implementación técnica?
