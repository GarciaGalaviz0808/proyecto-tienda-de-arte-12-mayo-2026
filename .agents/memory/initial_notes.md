# 🧠 Memory — Notas Iniciales de Arquitectura

## Estado del Proyecto

- **Fase actual**: Fase 1 — Configuración Base (pendiente de inicio)
- **Última actualización**: Inicialización del entorno agéntico
- **Tareas completadas**: 0 / ~80+

---

## Decisiones Clave de Arquitectura

### 1. Embedding en `orders` (Historial Inmutable)
**Decisión**: Los items del pedido se almacenan con snapshots de precio, nombre y marca en el momento de la compra.

**Razón**: Los precios de los productos cambian con el tiempo (ofertas, aumentos de precio). El historial de pedidos debe reflejar exactamente los valores pagados, no los actuales. Esto garantiza facturación correcta y auditable.

**Implementación**: `OrderItemModel` tiene `nameSnapshot`, `priceSnapshot`, `brandSnapshot` en lugar de referencias a `products`.

**⚠️ NUNCA**: Guardar solo el `prodId` en `orders.items` y resolver nombre/precio en runtime desde el documento de producto actual.

---

### 2. Transacciones Atómicas para Stock y Puntos
**Decisión**: Toda operación de checkout usa `FirebaseFirestore.instance.runTransaction()`.

**Razón**: Sin transacciones, dos usuarios comprando el último item simultáneamente causaría stock negativo (`race condition`). Firestore garantiza lecturas y escrituras atómicas dentro de una transacción.

**Secuencia obligatoria dentro de la transacción**:
1. Leer stock de cada `products/{prodId}`
2. Verificar `stock >= quantitySolicitada` → abortar con error si falla
3. Decrementar `products/{prodId}.stock`
4. Crear documento `orders/{auto-id}` con todos los campos
5. Crear registros en `inventory_movements` por cada item (`type: 'sale'`, `quantity: negativo`)
6. Vaciar `carts/{userId}.items` y resetear totales
7. Calcular puntos: `floor(total / amountDivisor) * pointsPerAmount`
8. Incrementar `users/{uid}.loyaltyPoints`
9. Recalcular y actualizar `users/{uid}.loyaltyLevel`
10. Crear `users/{uid}/loyalty_transactions/{auto-id}` con `type: 'earned'`
11. Si cupón aplicado: incrementar `coupons/{code}.usedCount`

**⚠️ NUNCA**: Modificar stock o puntos fuera de una transacción. Nunca dividir estas operaciones en múltiples writes independientes.

---

### 3. Cálculo de Puntos Post-Pago
**Decisión**: Los puntos de fidelidad se calculan y asignan **única y exclusivamente** después de que el pedido se crea exitosamente, dentro de la misma transacción.

**Razón**: Un pedido que falla (por stock insuficiente, error de red, etc.) no debe generar puntos. La atomicidad garantiza que puntos y pedido son indivisibles.

**Fórmula**:
```dart
final int pointsEarned = (total / amountDivisor).floor() * pointsPerAmount;
```
Donde `amountDivisor` y `pointsPerAmount` se leen de `loyalty_rules/global` en Firestore.

**Actualización de nivel**: Después de incrementar `loyaltyPoints`, comparar el nuevo total contra todos los `levelThresholds` y asignar el nivel correspondiente al umbral más alto alcanzado.

---

### 4. Validación Completa de Cupones
**Decisión**: La validación de cupones verifica múltiples condiciones en Firestore. No se acepta ningún cupón sin pasar todos los checks.

**Checks requeridos** (en orden):
1. `isActive == true`
2. `expiresAt.toDate().isAfter(DateTime.now())`
3. `usedCount < maxUses`
4. `cartSubtotal >= minPurchase`
5. Si `applicableCategories` no está vacío: al menos un item del carrito debe pertenecer a esas categorías
6. Si `applicableBrands` no está vacío: al menos un item del carrito debe ser de esas marcas

**⚠️ NUNCA**: Validar solo el código sin verificar todos estos campos. Nunca asumir que un cupón válido en el cliente lo es también en Firestore.

---

### 5. Denormalización Ligera en `products`
**Decisión**: Incluir `categoryName` y `brandName` directamente en documentos de `products`.

**Razón**: Evita 2 lecturas adicionales por producto al mostrar catálogos y filtros. En un catálogo de 20 productos, esto ahorra 40 lecturas Firestore por carga de pantalla.

**Trade-off aceptado**: Si cambia el nombre de una categoría o marca, se debe propagar el cambio a todos los productos relacionados con un batch update.

**Implementación en `AdminService`**:
```dart
// Al actualizar nombre de categoría
Future<void> updateCategory(String catId, String newName) async {
  // 1. Actualizar categories/{catId}.name
  // 2. Batch update: products WHERE categoryId == catId → categoryName = newName
}
```

---

### 6. Cero Telemetría — Verificación Continua
**Decisión**: El proyecto no puede contener ninguna dependencia ni llamada a servicios de telemetría.

**Verificación obligatoria** antes de cada commit y en la Fase 8:
```bash
grep -r "firebase_analytics\|firebase_crashlytics\|firebase_performance\|sentry\|datadog\|amplitude\|mixpanel\|segment\|heap\|posthog" lib/
```
Si retorna cualquier resultado → **bloquear el commit y eliminar el import antes de continuar**.

**También verificar `pubspec.yaml`** que no contenga ninguna de estas dependencias.

---

### 7. Gestión de Roles — Defensa en Profundidad
**Decisión**: El rol del usuario se valida en tres capas independientes, no solo en una.

**Capas de validación**:
1. **Client-side** (`AuthProvider`): Lee `role` de `users/{uid}` en Firestore al hacer login. Controla qué UI se muestra.
2. **Router** (`GoRouter.redirect`): Verifica el rol del `AuthProvider` antes de permitir navegación a rutas admin.
3. **Firestore Security Rules**: Última línea de defensa. Valida el rol con `get()` directo en las reglas antes de cualquier operación de escritura.

**⚠️ NUNCA**: Confiar solo en el rol almacenado en estado local (Provider) sin verificar contra Firestore. Un actor malicioso con acceso a la memoria del dispositivo podría modificar el estado local.

---

### 8. Estrategia de Imágenes v1
**Decisión**: En v1, los admins pueden registrar productos con URLs de imágenes externas directas o subidas a Firebase Storage.

**Razón**: Simplifica el formulario CRUD admin en v1 sin requerir upload obligatorio.

**Para reseñas de usuarios**: Las imágenes DEBEN pasar por Firebase Storage con `StorageService`, que valida tipo (`.jpg`, `.png`, `.webp`) y tamaño máximo (5MB).

**⚠️ NO usar**: URLs de servicios con parámetros de rastreo embebidos en la URL.

---

### 9. Estructura de ShellRoutes en go_router
**Decisión**: Dos `ShellRoute` completamente separados para cliente y admin.

**Shell Cliente** — con `BottomNavigationBar`:
- Tabs: Home (`/home`), Catálogo (`/catalog`), Carrito (`/cart`), Perfil (`/profile`)
- Rutas adicionales dentro del shell: `/categories`, `/product/:prodId`, `/checkout`, `/wishlist`, `/flash-offers`, `/loyalty`, `/orders`, `/coupons`, `/profile/edit`, `/order/confirmation`

**Shell Admin** — con `NavigationDrawer` colapsable:
- Items: `/admin/dashboard`, `/admin/products`, `/admin/orders`, `/admin/loyalty`, `/admin/permissions`

**⚠️ NO** mezclar rutas de cliente y admin en el mismo `ShellRoute`.

---

### 10. Provider — Dependencias y `ProxyProvider`
**Decisión**: Los providers que necesitan el `uid` del usuario autenticado usan `ProxyProvider<AuthProvider, XProvider>`.

**Providers que dependen de `AuthProvider`**:
- `CartProvider` — necesita `uid` para leer/escribir `carts/{uid}`
- `LoyaltyProvider` — necesita `uid` para `users/{uid}.loyaltyPoints` y subcolecciones
- `WishlistProvider` — necesita `uid` para `users/{uid}.wishlist`
- `OrderProvider` — necesita `uid` para filtrar `orders` por usuario

**Implementación**:
```dart
ProxyProvider<AuthProvider, CartProvider>(
  update: (_, auth, previous) => CartProvider(
    uid: auth.currentUser?.uid,
    cartService: CartService(),
  ),
)
```

**⚠️ NUNCA**: Acceder al `uid` directamente desde `FirebaseAuth.instance.currentUser` dentro de un widget. Siempre pasar por el Provider.

---

## Recordatorios Críticos de Implementación

| # | Recordatorio | Impacto si se ignora |
|---|---|---|
| 1 | Validar stock **dentro** de la transacción atómica (no solo en la UI) | Stock negativo / overselling |
| 2 | **No hardcodear** Project ID, API Keys ni credenciales Firebase | Vulnerabilidad de seguridad |
| 3 | Cupones validan `expiresAt`, `usedCount < maxUses`, `minPurchase` y `isActive` | Cupones expirados o agotados aceptados |
| 4 | Puntos de fidelidad se asignan **post-confirmación** dentro de la misma transacción | Puntos sin pedido real / pedidos sin puntos |
| 5 | `/admin/permissions` solo renderiza si `role == 'superadmin'` — guarda en router Y en UI | Escalada de privilegios |
| 6 | Todo widget interactivo tiene `Semantics` label y toque mínimo de 48×48px | Fallo de accesibilidad |
| 7 | `inventory_movements` se registra en **toda** operación de stock (sale/restock/adjustment) | Historial de inventario incompleto |
| 8 | `usedCount` del cupón se incrementa atómicamente al confirmar pedido | Cupones usados más veces que `maxUses` |
| 9 | `loyaltyLevel` se recalcula cada vez que cambian `loyaltyPoints` | Nivel incorrecto para el usuario |
| 10 | Soft delete en productos (`isActive: false`) — nunca eliminar físicamente | Pérdida de historial de pedidos (prodId referenciado en orders) |
| 11 | Al actualizar nombre de categoría/marca → batch update en productos relacionados | `categoryName`/`brandName` desincronizados en catálogo |
| 12 | Imágenes de reseñas pasan por Firebase Storage con validación de tipo y tamaño | Archivos maliciosos o demasiado grandes en Storage |

---

## Checklist de Seguridad Firebase

- [ ] `google-services.json` añadido a `.gitignore` antes del primer commit
- [ ] Security Rules publicadas y verificadas antes de cualquier prueba en dispositivo
- [ ] Índices compuestos creados en Firestore console (ver `database_mapping.md`)
- [ ] Firebase Storage Rules configuradas: solo imágenes `.jpg`/`.png`/`.webp`, máx 5MB
- [ ] Email/Password habilitado como único provider en Firebase Auth console
- [ ] Google Sign-In y otros providers de Auth **deshabilitados**
- [ ] Sin dominios autorizados adicionales innecesarios en Firebase Auth
- [ ] Modo de depuración de Firestore deshabilitado en build release

---

## Dependencias Aprobadas (pubspec.yaml)

```
firebase_core: ^2.30.0
firebase_auth: ^4.17.0
cloud_firestore: ^4.15.0
firebase_storage: ^11.7.0
provider: ^6.1.1
google_fonts: ^6.2.1
cached_network_image: ^3.3.0
carousel_slider: ^4.2.1
shimmer: ^3.0.0
intl: ^0.19.0
flutter_svg: ^2.0.9
go_router: ^13.2.0
flutter_lints: ^4.0.0
```

Cualquier dependencia adicional requiere revisión y aprobación explícita antes de añadirse.
