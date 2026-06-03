# 📐 Project Context — Eli's Art Supplies

## Resumen del Proyecto

| Campo | Valor |
|---|---|
| **Nombre** | Eli's Art Supplies |
| **Tipo** | E-commerce móvil de suministros de arte |
| **Plataforma** | Android (APK developer mode) |
| **Lenguaje** | Dart 3.x |
| **Framework** | Flutter ≥ 3.16.0 |
| **Backend** | Firebase (Firestore + Auth) |
| **Estado** | Provider 6.x |
| **Routing** | go_router 13.x |
| **Telemetría** | ❌ PROHIBIDA |
| **Build objetivo** | APK modo desarrollador (dispositivo físico) |

---

## Stack Técnico

### Frontend
- **Flutter**: UI declarativa, Material 3 base con tema artístico personalizado.
- **google_fonts**: `Playfair Display` (títulos) + `Inter` (cuerpo).
- **cached_network_image**: Imágenes de productos con placeholder shimmer.
- **carousel_slider**: Banners y galería de producto.
- **shimmer**: Skeleton loaders con patrón de pincelada.
- **flutter_svg**: Iconografía minimalista de categorías.
- **intl**: Formateo de precios, fechas y pluralización.

### Backend
- **firebase_core**: Inicialización de Firebase.
- **firebase_auth**: Autenticación email/contraseña.
- **cloud_firestore**: Base de datos NoSQL en tiempo real.
- **firebase_storage**: Almacenamiento de imágenes de productos y reseñas.

### Sin incluir (prohibido)
- `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`
- Cualquier SDK de rastreo de usuario o sesión

---

## Estructura de Carpetas del Proyecto

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Tokens de color HEX
│   │   ├── app_typography.dart      # TextStyles Playfair + Inter
│   │   └── app_dimensions.dart      # Bordes, paddings, sombras
│   ├── theme/
│   │   └── app_theme.dart           # ThemeData completo
│   └── router.dart                  # go_router config
├── models/
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── category_model.dart
│   ├── brand_model.dart
│   ├── cart_model.dart
│   ├── order_model.dart
│   ├── coupon_model.dart
│   ├── loyalty_model.dart
│   ├── review_model.dart
│   ├── banner_model.dart
│   ├── address_model.dart
│   └── admin_permission_model.dart
├── services/
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── coupon_service.dart
│   ├── loyalty_service.dart
│   ├── review_service.dart
│   ├── storage_service.dart
│   └── admin_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   ├── coupon_provider.dart
│   ├── loyalty_provider.dart
│   ├── wishlist_provider.dart
│   └── admin_provider.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── landing_screen.dart
│   │   ├── customer_login_screen.dart
│   │   ├── customer_register_screen.dart
│   │   └── admin_login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── catalog/
│   │   ├── catalog_screen.dart
│   │   └── categories_screen.dart
│   ├── product/
│   │   └── product_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── checkout/
│   │   ├── checkout_screen.dart
│   │   └── order_confirmation_screen.dart
│   ├── wishlist/
│   │   └── wishlist_screen.dart
│   ├── flash_offers/
│   │   └── flash_offers_screen.dart
│   ├── loyalty/
│   │   └── loyalty_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   ├── orders/
│   │   └── order_history_screen.dart
│   ├── coupons/
│   │   └── coupons_screen.dart
│   └── admin/
│       ├── admin_dashboard_screen.dart
│       ├── products/
│       │   └── admin_products_screen.dart
│       ├── orders/
│       │   └── admin_orders_screen.dart
│       ├── loyalty/
│       │   └── admin_loyalty_screen.dart
│       └── permissions/
│           └── admin_permissions_screen.dart
└── widgets/
    ├── product_card_art.dart
    ├── category_tile.dart
    ├── loyalty_badge.dart
    ├── price_tag.dart
    ├── flash_offer_badge.dart
    ├── shimmer_product_card.dart
    ├── coupon_card.dart
    ├── order_status_badge.dart
    └── confirm_logout_dialog.dart
```

---

## Flujo de Pantallas (22+)

| # | Pantalla | Ruta (go_router) | Acceso |
|---|---|---|---|
| 1 | Splash + Onboarding | `/splash` | Público |
| 2 | Landing Login | `/login` | Público |
| 3 | Auth Cliente (Login/Register) | `/auth/customer` | Público |
| 4 | Home | `/home` | `customer` |
| 5 | Catálogo | `/catalog` | `customer` |
| 6 | Categorías | `/categories` | `customer` |
| 7 | Detalle de Producto | `/product/:prodId` | `customer` |
| 8 | Carrito | `/cart` | `customer` |
| 9 | Checkout | `/checkout` | `customer` |
| 10 | Confirmación de Pedido | `/order/confirmation` | `customer` |
| 11 | Wishlist | `/wishlist` | `customer` |
| 12 | Ofertas Flash | `/flash-offers` | `customer` |
| 13 | Fidelidad | `/loyalty` | `customer` |
| 14 | Mi Perfil | `/profile` | `customer` |
| 15 | Editar Perfil | `/profile/edit` | `customer` |
| 16 | Historial de Pedidos | `/orders` | `customer` |
| 17 | Cupones | `/coupons` | `customer` |
| 18 | Admin Login | `/admin/login` | Público |
| 19 | Dashboard Admin | `/admin/dashboard` | `admin`/`superadmin` |
| 20 | CRUD Productos Admin | `/admin/products` | `admin`/`superadmin` |
| 21 | Gestión Fidelidad Admin | `/admin/loyalty` | `admin`/`superadmin` |
| 22 | Gestión Permisos | `/admin/permissions` | `superadmin` |

### Guardas de Ruta
- **`/home` y rutas `customer`**: Redirigir a `/login` si no autenticado.
- **`/admin/*`**: Redirigir a `/admin/login` si no autenticado o rol insuficiente.
- **`/admin/permissions`**: Solo accesible si `role == 'superadmin'`.

---

## Gestión de Estado con Provider

| Provider | Estado que Gestiona |
|---|---|
| `AuthProvider` | Usuario autenticado, rol, stream de auth |
| `ProductProvider` | Listado de productos, filtros, búsqueda |
| `CartProvider` | Items del carrito, totales, aplicación de cupón |
| `OrderProvider` | Historial de pedidos, pedido activo |
| `CouponProvider` | Validación y aplicación de cupones |
| `LoyaltyProvider` | Puntos, nivel, historial de transacciones |
| `WishlistProvider` | IDs de productos en wishlist |
| `AdminProvider` | Estado del panel admin, permisos del admin activo |

Todos los Providers consumen sus respectivos Services. Los Services son la única capa que interactúa con Firestore.

---

## Routing con go_router

- Archivo: `lib/core/router.dart`
- Usar `redirect` para guardas de autenticación y rol.
- Usar `ShellRoute` para la navegación con `BottomNavigationBar` en la zona cliente.
- Usar `ShellRoute` separado para el panel admin con `NavigationDrawer` colapsable.
- `GoRouter` instanciado con `refreshListenable: authProvider` para reactuar al cambio de sesión.

---

## Build APK — Modo Desarrollador

```bash
# Build APK debug para dispositivo físico
flutter build apk --debug

# Build APK release (requiere keystore)
flutter build apk --release

# Instalar directamente en dispositivo conectado
flutter install
```

- Habilitar "Opciones de desarrollador" y "Depuración USB" en el dispositivo.
- No se requiere Play Store ni firma de producción para pruebas.
- El archivo APK se genera en: `build/app/outputs/flutter-apk/app-debug.apk`

---

## pubspec.yaml de Referencia

```yaml
name: elis_art_supplies
description: Tienda de suministros de arte multiplataforma sin telemetría.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter
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

flutter:
  uses-material-design: true
  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Regular.ttf
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-SemiBold.ttf
```

---

## Referencias de Diseño

| Recurso | URL | Uso |
|---|---|---|
| Figma | `https://www.figma.com/make/MAaxGR5D5x7JYjslKhF8Mr/ArtStore-mobile-app-design` | Layouts, componentes, flujo visual |
| artsupplies.jp | `https://artsupplies.jp/` | Organización de catálogo, jerarquía de categorías |

> **Prioridad**: La paleta de colores del Figma prevalece sobre cualquier color observado en artsupplies.jp.
