# ✅ Agent Tasks — Roadmap Eli's Art Supplies

## Convenciones del Roadmap

- `[ ]` Pendiente · `[x]` Completado · `[~]` En progreso
- Cada fase debe completarse antes de iniciar la siguiente.
- Al completar una tarea, actualizar este archivo y `memory/initial_notes.md`.
- Criterios de aceptación deben verificarse en dispositivo físico.

---

## Fase 1 — Configuración Base y Firebase

**Objetivo**: Proyecto Flutter funcional conectado a Firebase, sin telemetría, con tema artístico base.

- [ ] Crear proyecto Flutter: `flutter create elis_art_supplies`
- [ ] Configurar `pubspec.yaml` con todas las dependencias listadas en `project_context.md`
- [ ] Descargar y colocar fuentes: `PlayfairDisplay-Regular.ttf`, `PlayfairDisplay-Bold.ttf`, `Inter-Regular.ttf`, `Inter-SemiBold.ttf` en `assets/fonts/`
- [ ] Crear estructura completa de carpetas `lib/` según árbol en `project_context.md`
- [ ] Implementar `AppColors` en `lib/core/constants/app_colors.dart`
- [ ] Implementar `AppTypography` en `lib/core/constants/app_typography.dart`
- [ ] Implementar `AppDimensions` en `lib/core/constants/app_dimensions.dart`
- [ ] Implementar `AppTheme` completo en `lib/core/theme/app_theme.dart`
- [ ] Inicializar Firebase en `main.dart` (solo `firebase_core` — sin analytics)
- [ ] Verificar ausencia total de imports de `firebase_analytics` o `firebase_crashlytics`
- [ ] Configurar `go_router` en `lib/core/router.dart` con las 22 rutas definidas
- [ ] Implementar guardas de ruta (`redirect`) por autenticación y rol
- [ ] Crear `main.dart` con `MultiProvider` base (todos los providers registrados)
- [ ] Ejecutar `flutter analyze` sin errores ni warnings

**Criterio de aceptación**: App lanza en dispositivo físico sin errores, muestra `SplashScreen` con paleta de colores correcta (`backgroundPrimary #FDFBF7`).

---

## Fase 2 — Modelos y Servicios Firebase

**Objetivo**: Capa de datos completa con serialización Firestore y servicios base.

### Modelos (`lib/models/`)
- [ ] `UserModel` — `fromFirestore()`, `toFirestore()`, campo `role`, `loyaltyPoints`, `loyaltyLevel`, `wishlist`
- [ ] `ProductModel` — campos completos con `categoryName`/`brandName` denormalizados
- [ ] `CategoryModel`
- [ ] `BrandModel`
- [ ] `CartModel` + `CartItemModel` — con `nameSnapshot`, `priceSnapshot`, `brandSnapshot`
- [ ] `OrderModel` + `OrderItemModel` — snapshots inmutables de precio/nombre/marca
- [ ] `CouponModel` — con `expiresAt`, `usedCount`, `maxUses`, `applicableCategories`
- [ ] `LoyaltyRulesModel` + `LoyaltyTransactionModel`
- [ ] `ReviewModel`
- [ ] `BannerModel`
- [ ] `AddressModel`
- [ ] `AdminPermissionModel`

### Servicios (`lib/services/`)
- [ ] `AuthService` — `signIn()`, `register()`, `signOut()`, `authStateStream()`, leer `role` post-login
- [ ] `ProductService` — `getProducts()` con filtros, `getById()`, `search()`, paginación con cursor
- [ ] `CartService` — `addItem()`, `updateQuantity()`, `removeItem()`, `getCart()`, `clearCart()`
- [ ] `OrderService` — `createOrder()` con transacción atómica completa (stock + puntos + cupón)
- [ ] `CouponService` — `validateCoupon()`, `applyCoupon()`, incremento atómico de `usedCount`
- [ ] `LoyaltyService` — `calculatePoints()`, `updateLevel()`, `redeemReward()` con transacción
- [ ] `ReviewService` — `addReview()`, `getReviews()` paginado por `prodId`
- [ ] `StorageService` — `uploadProfilePhoto()`, `uploadReviewImage()`, validación tipo/tamaño
- [ ] `AdminService` — CRUD productos/categorías/marcas, gestión de pedidos, permisos

### Firebase
- [ ] Publicar Security Rules de `database_mapping.md` en Firestore console
- [ ] Crear todos los índices compuestos en Firestore console
- [ ] Configurar Firebase Storage Rules (solo imágenes `.jpg`, `.png`, `.webp`, máx 5MB)
- [ ] Habilitar Email/Password en Firebase Auth console
- [ ] Verificar que otros providers de Auth están deshabilitados

**Criterio de aceptación**: Tests unitarios de modelos pasan; `AuthService` completa ciclo completo de login/logout; `ProductService` retorna productos desde Firestore.

---

## Fase 3 — Autenticación y Roles

**Objetivo**: Flujo completo de auth con roles funcional y guardas de ruta operativas.

- [ ] Implementar `AuthProvider` con `ChangeNotifier`, stream de `authStateChanges()`, lectura de `role`
- [ ] **Pantalla 1 — `SplashScreen`**: Logo animado de Eli's Art Supplies (pincel + gota), detección de sesión activa, redirección automática
- [ ] **Pantalla 1b — `OnboardingScreen`**: 3 slides de valor (calidad profesional, envíos cuidadosos, comunidad artística), botón "Comenzar", mostrar solo en primer launch
- [ ] **Pantalla 2 — `LandingScreen`**: Logo centrado, botón "Iniciar sesión como cliente", botón "Iniciar sesión como administrador", acentos tierra
- [ ] **Pantalla 3a — `CustomerLoginScreen`**: TextField correo, TextField contraseña, validación en tiempo real con feedback visual, botón marrón "Iniciar sesión"
- [ ] **Pantalla 3b — `CustomerRegisterScreen`**: Mismo diseño + campo confirmar contraseña, validación de coincidencia
- [ ] **Pantalla 18 — `AdminLoginScreen`**: Email + contraseña, validación de rol `admin`/`superadmin` post-login
- [ ] Implementar `ConfirmLogoutDialog` widget
- [ ] Persistir flag de onboarding completado en preferencias locales (sin telemetría)
- [ ] Verificar redirección correcta: `customer` → `/home`; `admin`/`superadmin` → `/admin/dashboard`
- [ ] Verificar que acceso a rutas incorrectas redirige al login apropiado

**Criterio de aceptación**: Usuario `customer` accede a `/home`; `admin` accede a `/admin/dashboard`; intento de acceso sin auth redirige a login; intento de customer en ruta admin es bloqueado.

---

## Fase 4 — Catálogo, Productos y Carrito

**Objetivo**: Navegación de productos y carrito completamente funcional con UI artística.

### Providers
- [ ] Implementar `ProductProvider` — filtros por categoría/técnica/nivel/precio, búsqueda, paginación
- [ ] Implementar `WishlistProvider` — sincronizado con `users/{uid}.wishlist` en Firestore

### Pantallas
- [ ] **Pantalla 4 — `HomeScreen`**: AppBar con logo + acciones, carrusel de banners desde Firestore, secciones "Destacados" / "Nuevos Lanzamientos" / "Ofertas por Tiempo Limitado" / "Categorías Populares", grid de productos
- [ ] **Pantalla 5 — `CatalogScreen`**: TabBar de categorías, filtros laterales (marca, precio, técnica, nivel), grid responsive, shimmer loaders
- [ ] **Pantalla 6 — `CategoriesScreen`**: Grid 2 columnas de `CategoryTile`, contador de productos, click → catálogo filtrado
- [ ] **Pantalla 7 — `ProductDetailScreen`**: Galería con zoom, nombre/marca/descripción/precio/stock, selector de cantidad con validación de stock, botones "Añadir al carrito" y "Añadir a wishlist", sección de reseñas paginadas, productos relacionados
- [ ] **Pantalla 11 — `WishlistScreen`**: Grid de favoritos, toggle de corazón, botón "Mover al carrito"
- [ ] **Pantalla 12 — `FlashOffersScreen`**: Productos con `discountPrice`, badge "OFERTA", contador regresivo, filtros por categoría

### Widgets
- [ ] `ProductCardArt` completo con todos los estados (nuevo, best seller, edición limitada, agotado)
- [ ] `CategoryTile` con overlay de gradiente e icono SVG
- [ ] `ShimmerProductCard` con animación de pincelada
- [ ] `PriceTag` con y sin descuento
- [ ] `FlashOfferBadge` con `CountdownTimer`

### Carrito
- [ ] Implementar `CartProvider`
- [ ] **Pantalla 8 — `CartScreen`**: ListView de items con imagen/nombre/marca/precio/cantidad, validación de stock en selector `+/-`, icono eliminar, resumen del pedido (subtotal + descuento + envío + total), TextField de cupón funcional

**Criterio de aceptación**: Navegación Home → Catálogo → Detalle → Carrito funcional; shimmer visible durante carga; cupón se valida contra Firestore con mensaje de error/éxito; wishlist persiste entre sesiones.

---

## Fase 5 — Checkout, Pedidos y Confirmación

**Objetivo**: Flujo de compra completo con transacciones atómicas correctas.

- [ ] Implementar `OrderProvider`
- [ ] **Pantalla 9 — `CheckoutScreen`**: Formulario de dirección de envío, selector de direcciones guardadas, opciones de pago (efectivo/tarjeta simulada/PayPal simulado), resumen final, checkbox de términos y condiciones, botón "Confirmar Pedido"
- [ ] Implementar `OrderService.createOrder()` con transacción atómica completa:
  - [ ] Leer y verificar stock de cada producto
  - [ ] Decrementar stock
  - [ ] Crear documento `orders/{auto-id}`
  - [ ] Crear registros `inventory_movements` por cada item
  - [ ] Vaciar `carts/{userId}`
  - [ ] Calcular y asignar puntos de fidelidad
  - [ ] Incrementar `usedCount` del cupón si fue aplicado
  - [ ] Crear `loyalty_transactions/{auto-id}` con `type: 'earned'`
- [ ] **Pantalla 10 — `OrderConfirmationScreen`**: Animación de pincelada SVG, número de pedido, puntos ganados prominentes, resumen breve, botones "Seguir comprando" / "Ver mi pedido"
- [ ] **Pantalla 16 — `OrderHistoryScreen`**: Lista de pedidos con ID/fecha/total/estado/puntos, `OrderStatusBadge` con colores correctos, botón "Ver detalles"
- [ ] Implementar `OrderStatusBadge` widget

**Criterio de aceptación**: Pedido creado en Firestore con snapshots de precio/nombre/marca; stock decrementado; puntos asignados; carrito vaciado; todo en una única transacción atómica sin estado inconsistente.

---

## Fase 6 — Perfil, Fidelidad y Cupones

**Objetivo**: Pantallas de usuario completas con sistema de fidelidad y cupones operativos.

- [ ] Implementar `LoyaltyProvider`
- [ ] **Pantalla 13 — `LoyaltyScreen`**: Nivel actual (Bronce/Plata/Oro/Platino), barra de progreso hacia siguiente nivel, puntos acumulados, recompensas disponibles para canjear, historial de transacciones paginado
- [ ] Modal de canje de recompensas con transacción atómica (`redeemReward()`)
- [ ] **Pantalla 14 — `ProfileScreen`**: Avatar circular con `LoyaltyBadge`, nombre/email/puntos/nivel, secciones: Mis Pedidos / Direcciones / Métodos de Pago / Wishlist / Puntos / Reseñas / Configuración, botones Editar Perfil y Cerrar Sesión
- [ ] **Pantalla 15 — `EditProfileScreen`**: Formulario nombre/teléfono/foto de perfil/técnica favorita, upload de foto via `StorageService`, validación de campos, botón "Guardar cambios" actualiza Firestore
- [ ] **Pantalla 17 — `CouponsScreen`**: Cupones activos disponibles para el usuario, `CouponCard` con código/descripción/expiración/mínimo, botón "Copiar código"
- [ ] Implementar `LoyaltyBadge` widget con colores por nivel
- [ ] Implementar lógica de actualización automática de `loyaltyLevel` al cambiar puntos

**Criterio de aceptación**: Usuario ve su nivel correcto; canje decrementa puntos atómicamente y crea `loyalty_transaction`; edición de perfil refleja cambios en tiempo real; cupones muestran fecha de expiración formateada.

---

## Fase 7 — Panel Admin y Gestión

**Objetivo**: Panel admin funcional con CRUD de productos y gestión completa.

- [ ] Implementar `AdminProvider`
- [ ] **Pantalla 19 — `AdminDashboardScreen`**: `NavigationDrawer` colapsable con menú: Productos / Categorías / Marcas / Clientes / Pedidos / Cupones / Reseñas / Banners / Sistema de Fidelidad / Gestión de Admins (solo superadmin) / Configuración

### CRUD Productos (Pantalla 20 — `AdminProductsScreen`)
- [ ] Vista de tabla con búsqueda, filtros por categoría/marca/estado, paginación con cursor
- [ ] Formulario **Crear producto**: nombre, descripción, categoría, marca, técnica, nivel, precio, `discountPrice`, stock, SKU, imágenes (URLs múltiples), dimensiones, peso, materiales, estado
- [ ] Formulario **Editar producto**: todos los campos editables + actualización manual de stock + cambio de estado (active/inactive/offer/limited/new/sold_out)
- [ ] **Eliminar producto**: soft delete (`isActive: false`) con modal de confirmación, registro en `inventory_movements` con `type: 'adjustment'`
- [ ] Al actualizar `categoryName` o `brandName`: batch update en todos los productos afectados

### Gestión Admin adicional
- [ ] Gestión de pedidos: tabla con filtros de estado, actualización de estado, ver detalles
- [ ] Gestión de cupones: crear/editar/activar/desactivar, ver `usedCount` vs `maxUses`
- [ ] Gestión de banners: crear, definir fechas `startDate`/`endDate`, orden de visualización
- [ ] **Pantalla 21 — `AdminLoyaltyScreen`**: Configurar `pointsPerAmount`/`amountDivisor`, definir `levelThresholds`, crear/editar `redeemableRewards`, ver ranking de usuarios por puntos
- [ ] Verificar que permisos granulares de `admin_permissions` restringen acceso por colección

**Criterio de aceptación**: Admin crea producto y aparece en catálogo cliente en tiempo real; soft delete lo oculta del catálogo; stock se actualiza correctamente; permisos granulares bloquean acciones no autorizadas.

---

## Fase 8 — Superadmin, Pruebas y APK

**Objetivo**: Gestión de permisos superadmin operativa, QA completo y build final.

### Pantalla 22 — `AdminPermissionsScreen` (solo superadmin)
- [ ] Listado de todos los admins con su nivel de acceso actual
- [ ] Asignar/revocar permisos por colección (`products`, `orders`, `coupons`, `reviews`, `banners`, `loyalty_rules`) y por acción (`read`, `write`, `delete`)
- [ ] Auditoría de acciones de admins (log de cambios en `admin_permissions`)
- [ ] Promoción/degradación de roles: `customer → admin`, `admin → superadmin` (solo superadmin puede promover a superadmin)
- [ ] Verificar que la pantalla NO es accesible para rol `admin` (guarda de ruta activa)

### Control de Calidad
- [ ] Revisar y publicar Security Rules finales de Firestore
- [ ] Verificar modo alto contraste en toda la app
- [ ] Verificar contraste WCAG AA en todos los pares color/texto
- [ ] Verificar tamaño mínimo de 48×48px en todos los elementos táctiles
- [ ] Verificar `Semantics` labels en widgets interactivos principales
- [ ] Probar flujo E2E completo de cliente en dispositivo físico:
  - [ ] Registro → Login → Home → Catálogo → Producto → Carrito → Checkout → Confirmación
  - [ ] Aplicar cupón válido y verificar descuento
  - [ ] Verificar puntos asignados post-pedido
  - [ ] Canjear recompensa de fidelidad
- [ ] Probar flujo E2E completo de admin en dispositivo físico:
  - [ ] Login admin → Dashboard → Crear producto → Editar → Soft delete
  - [ ] Actualizar estado de pedido
  - [ ] Crear cupón → verificar desde cuenta cliente
- [ ] Probar flujo superadmin: asignar permisos → verificar restricciones

### Verificación de Telemetría
- [ ] Ejecutar: `grep -r "firebase_analytics\|firebase_crashlytics\|firebase_performance\|sentry\|datadog\|amplitude\|mixpanel" lib/`
- [ ] Confirmar que el comando anterior **no retorna ningún resultado**
- [ ] Revisar `pubspec.yaml` — ninguna dependencia de telemetría

### Build y Distribución
- [ ] `flutter analyze` — cero errores, cero warnings
- [ ] `flutter test` — todos los tests de modelos y servicios pasan
- [ ] `flutter build apk --debug`
- [ ] Instalar APK en dispositivo físico: `flutter install`
- [ ] Verificar instalación y funcionamiento completo sin conexión a depurador
- [ ] Documentar instrucciones de instalación en `README.md` del proyecto raíz

**Criterio de aceptación**: APK instala y funciona correctamente en dispositivo físico Android; superadmin puede asignar y revocar permisos; ninguna dependencia o llamada de telemetría presente; `flutter analyze` limpio; flujo E2E completo sin errores.

---

## Criterios de Aceptación por Pantalla

| # | Pantalla | Criterio Clave |
|---|---|---|
| 1 | Splash/Onboarding | Animación fluida; onboarding solo en primer launch; detección de sesión activa redirige sin parpadeo |
| 2 | Landing | Dos botones visibles con diseño limpio; redirección correcta a auth cliente o admin |
| 3a | Auth Cliente Login | Validación en tiempo real; errores en `error (#A65E5E)`; login funcional |
| 3b | Auth Cliente Register | Validación de contraseñas coincidentes; usuario creado en Firestore con `role: customer` |
| 4 | Home | Banners cargan desde Firestore; shimmer visible; grid de destacados con `ProductCardArt` |
| 5 | Catálogo | Filtros funcionan correctamente; paginación con cursor; stock visible en cada card |
| 6 | Categorías | Grid 2 columnas con imágenes/iconos; contador de productos por categoría; click filtra catálogo |
| 7 | Detalle Producto | Galería funcional; reseñas paginadas; "Añadir al carrito" valida stock antes de agregar |
| 8 | Carrito | Cantidades respetan stock disponible; cupón se valida contra Firestore; totales calculados correctamente |
| 9 | Checkout | Formulario completo; pago simulado; botón "Confirmar" dispara transacción atómica |
| 10 | Confirmación | Puntos ganados visibles; animación de pincelada; botones de navegación funcionan |
| 11 | Wishlist | Persiste entre sesiones; toggle correcto; "Mover al carrito" funciona |
| 12 | Ofertas Flash | Solo productos con `discountPrice`; contador regresivo en tiempo real |
| 13 | Fidelidad | Nivel correcto según puntos; progreso visual a siguiente nivel; canje atómico de recompensas |
| 14 | Perfil | Todas las secciones visibles; `LoyaltyBadge` muestra nivel; logout abre `ConfirmLogoutDialog` |
| 15 | Editar Perfil | Upload de foto funciona; cambios se reflejan en Firestore y UI inmediatamente |
| 16 | Historial Pedidos | `OrderStatusBadge` con colores correctos; todos los pedidos del usuario visibles |
| 17 | Cupones | Cupones activos y no expirados visibles; botón copiar funciona |
| 18 | Admin Login | Solo permite acceso con `role: admin` o `role: superadmin`; error claro para customers |
| 19 | Admin Dashboard | Drawer colapsable funcional; solo items permitidos visibles según permisos del admin |
| 20 | Admin Productos | CRUD completo; soft delete registra en `inventory_movements`; búsqueda y filtros operativos |
| 21 | Admin Fidelidad | Reglas de puntos editables; recompensas canjeables configurables; ranking de usuarios |
| 22 | Admin Permisos | Solo visible para `superadmin`; asignación y revocación de permisos efectiva en tiempo real |
