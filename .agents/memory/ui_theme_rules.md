# 🎨 UI Theme Rules — Eli's Art Supplies

## Paleta de Colores

| Token | HEX | Nombre | Uso |
|---|---|---|---|
| `backgroundPrimary` | `#FDFBF7` | Blanco Crema Suave | Fondos generales, canvas principal |
| `backgroundSecondary` | `#F5F0E6` | Beige Arena | Tarjetas, drawers, secciones secundarias |
| `surface` | `#FFFFFF` | Blanco Puro | Cards de producto, modales, inputs |
| `textPrimary` | `#2C241B` | Café Profundo | Títulos, precios, datos críticos |
| `textSecondary` | `#6B5D52` | Taupe Grisáceo | Subtítulos, metadatos, placeholders |
| `primaryAccent` | `#8B6F47` | Marrón Tierra | Botones principales, badges, acentos |
| `secondaryAccent` | `#C4A57B` | Dorado Muted | Ofertas, puntos de fidelidad, wishlist |
| `success` | `#5A7F6E` | Verde Musgo | Stock disponible, confirmaciones, envíos |
| `warning` | `#D4A574` | Ámbar Suave | Stock bajo, ofertas por tiempo, alertas |
| `error` | `#A65E5E` | Rojo Terracota | Errores, stock agotado, fallos |
| `loyaltyGold` | `#B89A6A` | Oro Artístico | Puntos, niveles de miembro, recompensas |
| `borderSubtle` | `#E8E0D5` | Gris Cálido | Separadores, bordes de inputs |

### Implementación en Dart
```dart
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundPrimary   = Color(0xFFFDFBF7);
  static const Color backgroundSecondary = Color(0xFFF5F0E6);
  static const Color surface             = Color(0xFFFFFFFF);
  static const Color textPrimary         = Color(0xFF2C241B);
  static const Color textSecondary       = Color(0xFF6B5D52);
  static const Color primaryAccent       = Color(0xFF8B6F47);
  static const Color secondaryAccent     = Color(0xFFC4A57B);
  static const Color success             = Color(0xFF5A7F6E);
  static const Color warning             = Color(0xFFD4A574);
  static const Color error               = Color(0xFFA65E5E);
  static const Color loyaltyGold         = Color(0xFFB89A6A);
  static const Color borderSubtle        = Color(0xFFE8E0D5);
}
```

---

## Tipografía

### Familias
| Uso | Familia | Variantes |
|---|---|---|
| Títulos, precios destacados, nombres de producto | `Playfair Display` | Regular, Bold |
| Cuerpo, botones, etiquetas, inputs | `Inter` | Regular, SemiBold |

### Jerarquía de Texto
| Estilo | Familia | Tamaño | Peso | Color |
|---|---|---|---|---|
| `displayLarge` | Playfair Display | 32sp | Bold | `textPrimary` |
| `headlineMedium` | Playfair Display | 24sp | Bold | `textPrimary` |
| `headlineSmall` | Playfair Display | 20sp | Regular | `textPrimary` |
| `titleLarge` | Inter | 18sp | SemiBold | `textPrimary` |
| `titleMedium` | Inter | 16sp | SemiBold | `textPrimary` |
| `bodyLarge` | Inter | 16sp | Regular | `textPrimary` |
| `bodyMedium` | Inter | 14sp | Regular | `textSecondary` |
| `bodySmall` | Inter | 12sp | Regular | `textSecondary` |
| `labelLarge` | Inter | 14sp | SemiBold | `surface` (sobre botón) |
| `labelSmall` | Inter | 10sp | SemiBold | `textSecondary` |

---

## Dimensiones y Bordes

| Elemento | Border Radius |
|---|---|
| Tarjetas de producto (`ProductCardArt`) | `16px` |
| Botones principales y secundarios | `12px` |
| Inputs / TextFields | `12px` |
| Modales / BottomSheets | `24px` (top corners) |
| Badges de categoría | `8px` |
| Chips de filtro | `20px` (pill) |
| Avatar de perfil | `50%` (circular) |

### Sombras
```dart
// Sombra estándar para cards de producto
BoxShadow(
  color: Color(0x102C241B),   // textPrimary al 6% opacidad
  blurRadius: 16,
  offset: Offset(0, 4),
)

// Sombra elevada para modales y drawers
BoxShadow(
  color: Color(0x1A2C241B),   // textPrimary al 10% opacidad
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

### Padding Estándar
| Contexto | Valor |
|---|---|
| Padding de pantalla (horizontal) | `16px` |
| Padding interno de cards | `16px` |
| Padding de sección (vertical) | `24px` |
| Espaciado entre cards en grid | `12px` |
| Altura mínima de botones | `48px` |
| Tamaño mínimo de área táctil | `48×48px` |

---

## Componentes Reutilizables

### `ProductCardArt`
Widget: `lib/widgets/product_card_art.dart`

Especificaciones:
- Imagen con `CachedNetworkImage` y placeholder `ShimmerProductCard`
- Badge de estado superpuesto (esquina superior izquierda): `"Nuevo"` · `"Best Seller"` · `"Edición Limitada"` · `"Agotado"`
- Precio tachado + precio promocional en `secondaryAccent` cuando hay `discountPrice`
- Nombre del producto: `Playfair Display` 14sp Bold, color `textPrimary`
- Marca: `Inter` 12sp Regular, color `textSecondary`
- Precio: `Inter` 16sp SemiBold, color `primaryAccent`
- Indicador de stock: dot 8px — verde `success` si disponible, rojo `error` si agotado
- Tamaño: ancho proporcional al grid (2 columnas ≈ 48% del ancho de pantalla), alto fijo 260px
- `border_radius: 16px`, sombra estándar
- Toque completo navega a `/product/:prodId`

---

### `CategoryTile`
Widget: `lib/widgets/category_tile.dart`

Especificaciones:
- Imagen de fondo o ilustración SVG representativa de la categoría
- Overlay de gradiente: `Colors.black` de 0% (top) a 25% (bottom)
- Nombre: `Playfair Display` 16sp Bold, color `surface`
- Contador de productos: `Inter` 12sp, color `surface` con 80% opacidad
- Icono minimalista en esquina superior derecha (pincel, lienzo, gota de pintura, paleta)
- `border_radius: 16px`
- Altura fija: 140px

---

### `LoyaltyBadge`
Widget: `lib/widgets/loyalty_badge.dart`

Colores por nivel:
| Nivel | Color de fondo | Color de texto |
|---|---|---|
| Bronce | `#CD7F32` | `#FFFFFF` |
| Plata | `#A8A9AD` | `#2C241B` |
| Oro | `#B89A6A` (`loyaltyGold`) | `#FFFFFF` |
| Platino | `#E5E4E2` | `#2C241B` |

- Forma: pill (`border_radius: 20px`)
- Icono de estrella o corona a la izquierda del texto
- Tipografía: `Inter` 10sp SemiBold
- Padding: `4px vertical, 10px horizontal`

---

### `PriceTag`
Widget: `lib/widgets/price_tag.dart`

- Con descuento activo:
  - Precio original: `Inter` 14sp Regular, tachado, color `textSecondary`
  - Precio promocional: `Playfair Display` 20sp Bold, color `primaryAccent`
  - Badge de porcentaje: pill `secondaryAccent`, texto `surface` 10sp Bold
- Sin descuento:
  - Precio único: `Inter` 18sp SemiBold, color `textPrimary`

---

### `FlashOfferBadge`
Widget: `lib/widgets/flash_offer_badge.dart`

- Fondo: `error` (`#A65E5E`)
- Texto `"OFERTA"`: `Inter` 10sp Bold, color `surface`
- `border_radius: 6px`
- Padding: `3px vertical, 8px horizontal`
- Acompañar con `CountdownTimer` widget cuando aplique (texto `warning` para urgencia)

---

### `ShimmerProductCard`
Widget: `lib/widgets/shimmer_product_card.dart`

- Usa paquete `shimmer`
- `baseColor`: `backgroundSecondary` (`#F5F0E6`)
- `highlightColor`: `borderSubtle` (`#E8E0D5`)
- Animación con gradiente diagonal (simulación de pincelada)
- Mismas dimensiones que `ProductCardArt`: alto 260px, `border_radius: 16px`

---

### `CouponCard`
Widget: `lib/widgets/coupon_card.dart`

- Borde izquierdo de 4px sólido en `secondaryAccent`
- `background: surface`, `border_radius: 12px`
- Código del cupón: `Playfair Display` 18sp Bold, color `primaryAccent`
- Descripción: `Inter` 14sp Regular, color `textSecondary`
- Fecha de expiración: icono reloj + texto `Inter` 12sp, color `warning`
- Mínimo de compra: `Inter` 12sp, color `textSecondary`
- Botón `"Copiar código"`: outlined, color `primaryAccent`, `border_radius: 8px`

---

### `OrderStatusBadge`
Widget: `lib/widgets/order_status_badge.dart`

| Estado | Color de Fondo | Texto |
|---|---|---|
| `pending` | `warning` (`#D4A574`) | Pendiente |
| `processing` | `primaryAccent` (`#8B6F47`) | Procesando |
| `shipped` | `#5B8FA8` (Azul Artístico) | Enviado |
| `delivered` | `success` (`#5A7F6E`) | Entregado |
| `cancelled` | `error` (`#A65E5E`) | Cancelado |

- Forma: pill (`border_radius: 20px`)
- Tipografía: `Inter` 11sp SemiBold, color `surface`
- Padding: `4px vertical, 12px horizontal`

---

### `ConfirmLogoutDialog`
Widget: `lib/widgets/confirm_logout_dialog.dart`

- `Dialog` con fondo `surface`, `border_radius: 24px`
- Sombra elevada
- Título `"¿Cerrar sesión?"`: `Playfair Display` 20sp Bold, color `textPrimary`
- Cuerpo: `Inter` 14sp Regular, color `textSecondary`
- Botón **"Cancelar"**: `OutlinedButton`, borde `borderSubtle`, texto `textSecondary`
- Botón **"Sí, cerrar"**: `ElevatedButton`, fondo `error`, texto `surface`, `border_radius: 12px`

---

## Microinteracciones

| Interacción | Comportamiento | Duración |
|---|---|---|
| **Añadir al carrito** | Icono de pincel flotante animado hacia el ícono del carrito (Hero widget o custom animation) | 400ms |
| **Shimmer loader** | Gradiente diagonal `backgroundSecondary → borderSubtle → backgroundSecondary` | Loop continuo |
| **Hover/press en card** | Incremento de sombra (blurRadius 16→24) con `AnimatedContainer` | 200ms |
| **Toggle wishlist** | Corazón vacío → lleno con scale `1.0 → 1.3 → 1.0` | 300ms |
| **Confirmación de pedido** | Animación de pincelada SVG dibujándose izquierda → derecha | 600ms |
| **Contador regresivo** | Flip animation en dígitos individuales para ofertas flash | Por segundo |
| **Pull to refresh** | Icono de paleta de pinturas girando en indicador de carga | Continuo |

---

## Accesibilidad

| Requisito | Implementación |
|---|---|
| **Contraste WCAG AA** | Mínimo 4.5:1 para texto normal; 3:1 para texto grande (≥18sp Bold) |
| **Semántica** | `Semantics(label: '...')` en todos los widgets interactivos |
| **Tamaño mínimo de toque** | `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))` |
| **Lectores de pantalla** | `Image` con `semanticLabel`; `IconButton` con `tooltip` |
| **Modo alto contraste** | `ThemeData` alternativo activable en Configuración del perfil |
| **Escalado de texto** | No usar `ignoreTextScaleFactor: true`; respetar `textScaleFactor` del sistema |

---

## Responsive Breakpoints

| Breakpoint | Ancho | Comportamiento |
|---|---|---|
| Móvil (principal) | < 600px | Grid 2 columnas, padding horizontal 16px |
| Tablet (secundario) | 600px – 900px | Grid 3 columnas, padding horizontal 24px |
| Desktop (referencia) | > 900px | Grid 4 columnas, sidebar visible |

> El build objetivo de v1 es **móvil**. Tablet y desktop son opcionales.

---

## AppBar Estándar (Zona Cliente)

- Fondo: `backgroundPrimary` (`#FDFBF7`)
- Elevación: 0 (flat) con borde inferior `borderSubtle` de 1px
- Título: `Playfair Display` 20sp Bold, color `primaryAccent` + icono de pincel
- Acciones derecha:
  - Icono carrito con `Badge` numérico en `primaryAccent`
  - Icono corazón (wishlist)
  - Avatar de perfil circular
- Color de íconos: `textPrimary`

---

## AppBar Estándar (Zona Admin)

- Fondo: `backgroundSecondary` (`#F5F0E6`)
- Título: `Inter` 18sp SemiBold, color `textPrimary`
- Icono hamburguesa para toggle del `NavigationDrawer`
- Sin badge de carrito ni wishlist
