bash

cat > /mnt/user-data/outputs/artstore_plan_implementacion.md << 'ENDOFFILE'
# ArtStore — Plan de Implementación Completo
## Tienda de Suministros de Arte | Flutter + Firebase + Firestore

---

# ÍNDICE

1. [Visión General del Proyecto](#1-vision-general)
2. [Entidades y Atributos (Base de Datos)](#2-entidades)
3. [Paleta de Colores y Sistema de Diseño](#3-paleta-de-colores)
4. [Estructura de Carpetas Completa](#4-estructura-de-carpetas)
5. [pubspec.yaml — Dependencias](#5-pubspec)
6. [Modelos Dart — Entidades](#6-modelos)
7. [Servicios Firebase](#7-servicios)
8. [Providers — Gestión de Estado](#8-providers)
9. [Pantallas Principales](#9-pantallas)
10. [Configuración Firebase](#10-firebase)
11. [Hoja de Ruta de Implementación](#11-hoja-de-ruta)

---

# 1. VISIÓN GENERAL DEL PROYECTO

| Campo          | Detalle                                        |
|----------------|------------------------------------------------|
| Nombre         | ArtStore                                       |
| Descripción    | Tienda de suministros de arte                  |
| Framework      | Flutter 3.x / Dart 3.x                        |
| Base de datos  | Cloud Firestore (Firebase)                     |
| Autenticación  | Firebase Auth — Email + Password               |
| Estado         | Provider (ChangeNotifier / MultiProvider)      |
| Plataformas    | Android, iOS, Web, Windows                     |
| Analytics      | Deshabilitado                                  |
| Producción     | Deshabilitado (modo desarrollo)                |

## Arquitectura: MVVM + Provider

```
Screen / Widget  →  Provider (ChangeNotifier)  →  Service  →  Firestore
     ↑                        |
context.watch<T>()      notifyListeners()
```

El flujo de datos es **unidireccional**:
- Los Screens escuchan Providers con `Consumer<T>` o `context.watch<T>()`
- Las acciones del usuario llaman métodos del Provider
- El Provider llama al Service para persistencia en Firestore
- El Provider llama `notifyListeners()` y la UI se actualiza

---

# 2. ENTIDADES Y ATRIBUTOS (BASE DE DATOS)

**Leyenda:** `PK` = Llave Primaria | `FK` = Llave Foránea | `NOT NULL` = Requerido | `NULL` = Opcional

---

## 2.1 CLIENTE

| Atributo        | Tipo           | Restricción | Descripción                    |
|-----------------|----------------|-------------|--------------------------------|
| cliente_id      | String (UUID)  | PK          | Identificador único            |
| nombre          | VARCHAR(100)   | NOT NULL    | Nombre completo                |
| email           | VARCHAR(150)   | NOT NULL    | Correo electrónico (único)     |
| telefono        | VARCHAR(20)    | NULL        | Número de contacto             |
| direccion       | TEXT           | NULL        | Dirección de entrega principal |
| ciudad          | VARCHAR(80)    | NULL        | Ciudad de residencia           |
| pais            | VARCHAR(60)    | NULL        | País de residencia             |
| fecha_registro  | DateTime       | NOT NULL    | Alta en el sistema             |
| activo          | Boolean        | NOT NULL    | Estado de la cuenta            |

---

## 2.2 PEDIDO

| Atributo       | Tipo           | Restricción | Descripción                                        |
|----------------|----------------|-------------|----------------------------------------------------|
| pedido_id      | String (UUID)  | PK          | Identificador único                                |
| cliente_id     | String         | FK NOT NULL | Referencia a CLIENTE                               |
| empleado_id    | String         | FK NOT NULL | Referencia a EMPLEADO                              |
| fecha_pedido   | DateTime       | NOT NULL    | Fecha y hora del pedido                            |
| estado         | ENUM           | NOT NULL    | pendiente/confirmado/enviado/entregado/cancelado   |
| subtotal       | Decimal(10,2)  | NOT NULL    | Total antes de impuestos                           |
| impuesto       | Decimal(10,2)  | NOT NULL    | IVA u otros impuestos                              |
| total          | Decimal(10,2)  | NOT NULL    | Monto total a pagar                                |
| notas          | TEXT           | NULL        | Instrucciones especiales                           |

---

## 2.3 DETALLE_PEDIDO

| Atributo        | Tipo           | Restricción | Descripción                     |
|-----------------|----------------|-------------|---------------------------------|
| detalle_id      | String (UUID)  | PK          | Identificador único             |
| pedido_id       | String         | FK NOT NULL | Referencia a PEDIDO             |
| producto_id     | String         | FK NOT NULL | Referencia a PRODUCTO           |
| cantidad        | INT            | NOT NULL    | Unidades solicitadas            |
| precio_unitario | Decimal(10,2)  | NOT NULL    | Precio al momento de la venta   |
| descuento       | Decimal(5,2)   | NOT NULL    | Porcentaje de descuento         |
| subtotal_linea  | Decimal(10,2)  | NOT NULL    | cantidad × precio − descuento   |

---

## 2.4 PRODUCTO

| Atributo      | Tipo           | Restricción | Descripción                         |
|---------------|----------------|-------------|-------------------------------------|
| producto_id   | String (UUID)  | PK          | Identificador único                 |
| categoria_id  | String         | FK NOT NULL | Referencia a CATEGORIA              |
| proveedor_id  | String         | FK NOT NULL | Referencia a PROVEEDOR              |
| nombre        | VARCHAR(150)   | NOT NULL    | Nombre del producto                 |
| descripcion   | TEXT           | NULL        | Descripción detallada               |
| codigo_barras | VARCHAR(50)    | NULL        | EAN / SKU del producto              |
| precio        | Decimal(10,2)  | NOT NULL    | Precio de venta actual              |
| unidad_medida | VARCHAR(30)    | NOT NULL    | pieza / ml / kg / set              |
| imagen_url    | VARCHAR(255)   | NULL        | Ruta de imagen (Firebase Storage)   |
| activo        | Boolean        | NOT NULL    | Disponible en catálogo              |

---

## 2.5 CATEGORIA

| Atributo           | Tipo           | Restricción | Descripción                        |
|--------------------|----------------|-------------|------------------------------------|
| categoria_id       | String (UUID)  | PK          | Identificador único                |
| nombre             | VARCHAR(80)    | NOT NULL    | Nombre de la categoría             |
| descripcion        | TEXT           | NULL        | Descripción de la categoría        |
| categoria_padre_id | String         | FK NULL     | Auto-referencia (jerarquía)        |
| activo             | Boolean        | NOT NULL    | Estado de la categoría             |

---

## 2.6 PROVEEDOR

| Atributo     | Tipo           | Restricción | Descripción                |
|--------------|----------------|-------------|----------------------------|
| proveedor_id | String (UUID)  | PK          | Identificador único        |
| nombre       | VARCHAR(120)   | NOT NULL    | Nombre de la empresa       |
| contacto     | VARCHAR(100)   | NULL        | Persona de contacto        |
| email        | VARCHAR(150)   | NULL        | Correo del proveedor       |
| telefono     | VARCHAR(20)    | NULL        | Teléfono de contacto       |
| pais         | VARCHAR(60)    | NULL        | País de origen             |
| activo       | Boolean        | NOT NULL    | Proveedor vigente          |

---

## 2.7 INVENTARIO

| Atributo            | Tipo           | Restricción | Descripción                          |
|---------------------|----------------|-------------|--------------------------------------|
| inventario_id       | String (UUID)  | PK          | Identificador único                  |
| producto_id         | String         | FK NOT NULL | Referencia a PRODUCTO                |
| stock_actual        | INT            | NOT NULL    | Unidades disponibles                 |
| stock_minimo        | INT            | NOT NULL    | Nivel para alerta de reabastecimiento|
| stock_maximo        | INT            | NULL        | Capacidad máxima del almacén         |
| ubicacion           | VARCHAR(60)    | NULL        | Pasillo / estante                    |
| ultima_actualizacion| DateTime       | NOT NULL    | Último movimiento registrado         |

---

## 2.8 PAGO

| Atributo    | Tipo           | Restricción | Descripción                                           |
|-------------|----------------|-------------|-------------------------------------------------------|
| pago_id     | String (UUID)  | PK          | Identificador único                                   |
| pedido_id   | String         | FK NOT NULL | Referencia a PEDIDO                                   |
| metodo      | ENUM           | NOT NULL    | efectivo/tarjeta_credito/tarjeta_debito/transferencia |
| monto       | Decimal(10,2)  | NOT NULL    | Monto pagado                                          |
| fecha_pago  | DateTime       | NOT NULL    | Fecha y hora del pago                                 |
| referencia  | VARCHAR(100)   | NULL        | Número de referencia / folio                          |
| estado      | ENUM           | NOT NULL    | pendiente/procesado/fallido/reembolsado               |

---

## 2.9 ENVIO

| Atributo         | Tipo           | Restricción | Descripción                    |
|------------------|----------------|-------------|--------------------------------|
| envio_id         | String (UUID)  | PK          | Identificador único            |
| pedido_id        | String         | FK NOT NULL | Referencia a PEDIDO            |
| transportista    | VARCHAR(80)    | NOT NULL    | Empresa transportista          |
| numero_guia      | VARCHAR(80)    | NULL        | Número de rastreo              |
| direccion_destino| TEXT           | NOT NULL    | Dirección de entrega           |
| fecha_envio      | Date           | NULL        | Fecha de despacho              |
| fecha_entrega    | Date           | NULL        | Fecha de entrega real          |
| estado           | ENUM           | NOT NULL    | pendiente/en_camino/entregado  |

---

## 2.10 EMPLEADO

| Atributo        | Tipo           | Restricción | Descripción                |
|-----------------|----------------|-------------|----------------------------|
| empleado_id     | String (UUID)  | PK          | Identificador único        |
| nombre          | VARCHAR(100)   | NOT NULL    | Nombre completo            |
| puesto          | VARCHAR(80)    | NOT NULL    | Cargo o rol en la tienda   |
| email           | VARCHAR(150)   | NOT NULL    | Correo corporativo (único) |
| telefono        | VARCHAR(20)    | NULL        | Número de contacto         |
| fecha_contrato  | Date           | NOT NULL    | Fecha de inicio            |
| salario         | Decimal(10,2)  | NULL        | Salario mensual            |
| activo          | Boolean        | NOT NULL    | Empleado vigente           |

---

## 2.11 Colecciones Firestore → Modelos

| Colección Firestore | Modelo Dart          | Subcolección |
|---------------------|----------------------|--------------|
| clientes            | ClienteModel         | —            |
| productos           | ProductoModel        | —            |
| categorias          | CategoriaModel       | —            |
| proveedores         | ProveedorModel       | —            |
| pedidos             | PedidoModel          | detalles     |
| inventario          | InventarioModel      | —            |
| pagos               | PagoModel            | —            |
| envios              | EnvioModel           | —            |
| empleados           | EmpleadoModel        | —            |

---

# 3. PALETA DE COLORES Y SISTEMA DE DISEÑO

## 3.1 Paleta Principal — Tonalidades Café

| Token      | Hex       | Uso                          |
|------------|-----------|------------------------------|
| espresso   | #1C0D00   | Background oscuro            |
| cafeNegro  | #3E1F00   | Surface oscuro               |
| canela     | #6B3A1F   | Primary brand / AppBar       |
| sienna     | #A0522D   | Color secundario             |
| caramelo   | #C68642   | Acento / CTA / Botones       |
| arena      | #E8C49A   | Highlight / texto sobre oscuro|
| crema      | #F5ECD8   | Surface claro / Cards        |
| marfil     | #FDF6ED   | Background claro / Scaffold  |
| terracota  | #D4956A   | Error / Alertas              |

<img width="743" height="278" alt="image" src="https://github.com/user-attachments/assets/246712dc-0c2f-4bdf-ba60-aacc7c4316e2" />


## 3.2 Tipografía

- **Display / Títulos:** Playfair Display (elegancia artesanal)
- **Cuerpo / UI:** Google Fonts — Lato o Nunito (legibilidad)
- **Código:** Monospace del sistema

## 3.3 app_colors.dart

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Fondos: de más oscuro a más claro
  static const Color espresso  = Color(0xFF1C0D00); // background oscuro
  static const Color cafeNegro = Color(0xFF3E1F00); // surface oscuro
  static const Color canela    = Color(0xFF6B3A1F); // primary
  static const Color sienna    = Color(0xFFA0522D); // secondary
  static const Color caramelo  = Color(0xFFC68642); // accent / CTA
  static const Color arena     = Color(0xFFE8C49A); // highlight
  static const Color crema     = Color(0xFFF5ECD8); // surface claro
  static const Color marfil    = Color(0xFFFDF6ED); // background claro
  static const Color terracota = Color(0xFFD4956A); // error / warning
  static const Color blanco    = Color(0xFFFFFFFF);
  static const Color negro     = Color(0xFF1A0A00);
}
```

## 3.4 app_theme.dart

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─── TEMA CLARO ───────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary:          AppColors.canela,
      onPrimary:        AppColors.marfil,
      secondary:        AppColors.sienna,
      onSecondary:      AppColors.marfil,
      tertiary:         AppColors.caramelo,
      surface:          AppColors.crema,
      onSurface:        AppColors.cafeNegro,
      background:       AppColors.marfil,
      onBackground:     AppColors.cafeNegro,
      error:            AppColors.terracota,
      onError:          AppColors.marfil,
    ),
    scaffoldBackgroundColor: AppColors.marfil,
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.canela),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.canela),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.cafeNegro),
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: AppColors.cafeNegro),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: AppColors.sienna),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor:  AppColors.canela,
      foregroundColor:  AppColors.marfil,
      elevation:        0,
      centerTitle:      true,
      titleTextStyle:   GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.marfil),
    ),
    cardTheme: CardThemeData(
      color:     AppColors.crema,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.arena.withOpacity(0.5), width: 0.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.canela,
        foregroundColor: AppColors.marfil,
        elevation:       0,
        padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle:       GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.canela,
        side:            const BorderSide(color: AppColors.canela, width: 1.5),
        padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:           true,
      fillColor:        AppColors.crema,
      border:           OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   const BorderSide(color: AppColors.arena),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:   const BorderSide(color: AppColors.canela, width: 2),
      ),
      labelStyle:       GoogleFonts.lato(color: AppColors.sienna),
      hintStyle:        GoogleFonts.lato(color: AppColors.sienna.withOpacity(0.6)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.crema,
      selectedItemColor:    AppColors.canela,
      unselectedItemColor:  AppColors.sienna,
      type:                 BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.caramelo,
      foregroundColor: AppColors.marfil,
    ),
    chipTheme: ChipThemeData(
      backgroundColor:      AppColors.crema,
      selectedColor:        AppColors.canela,
      labelStyle:           GoogleFonts.lato(fontSize: 13, color: AppColors.cafeNegro),
      side:                 const BorderSide(color: AppColors.arena),
      shape:                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.arena, thickness: 0.5),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cafeNegro,
      contentTextStyle: GoogleFonts.lato(color: AppColors.arena),
    ),
  );

  // ─── TEMA OSCURO ──────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary:      AppColors.caramelo,
      onPrimary:    AppColors.espresso,
      secondary:    AppColors.arena,
      onSecondary:  AppColors.espresso,
      surface:      AppColors.cafeNegro,
      onSurface:    AppColors.crema,
      background:   AppColors.espresso,
      onBackground: AppColors.arena,
      error:        AppColors.terracota,
    ),
    scaffoldBackgroundColor: AppColors.espresso,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.caramelo),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.arena),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cafeNegro,
      foregroundColor: AppColors.arena,
      elevation:       0,
      centerTitle:     true,
      titleTextStyle:  GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.arena),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cafeNegro,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.sienna.withOpacity(0.4), width: 0.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.caramelo,
        foregroundColor: AppColors.espresso,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.cafeNegro,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.sienna),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.caramelo, width: 2),
      ),
      labelStyle: GoogleFonts.lato(color: AppColors.arena),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.cafeNegro,
      selectedItemColor:   AppColors.caramelo,
      unselectedItemColor: AppColors.sienna,
    ),
  );
}
```

## 3.5 app_text_styles.dart

```dart
// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get displayTitle => GoogleFonts.playfairDisplay(
    fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.canela);

  static TextStyle get sectionTitle => GoogleFonts.playfairDisplay(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.cafeNegro);

  static TextStyle get cardTitle => GoogleFonts.lato(
    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cafeNegro);

  static TextStyle get bodyText => GoogleFonts.lato(
    fontSize: 14, color: AppColors.sienna);

  static TextStyle get price => GoogleFonts.lato(
    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.caramelo);

  static TextStyle get label => GoogleFonts.lato(
    fontSize: 12, color: AppColors.sienna, letterSpacing: 0.5);

  static TextStyle get buttonText => GoogleFonts.lato(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.marfil);
}
```

---

# 4. ESTRUCTURA DE CARPETAS COMPLETA

```
artstore/
│
├── bin/                                    ← Punto de entrada CLI / scripts
│   ├── main.dart                           ← Entrada principal del proyecto
│   └── seed_firestore.dart                 ← Script para poblar datos de prueba
│
├── lib/
│   ├── main.dart                           ← runApp, Firebase init, MultiProvider raíz
│   │
│   ├── core/                               ← Compartido entre todos los módulos
│   │   ├── theme/
│   │   │   ├── app_colors.dart             ← Tokens de color (paleta café)
│   │   │   ├── app_theme.dart              ← ThemeData claro y oscuro
│   │   │   └── app_text_styles.dart        ← Estilos tipográficos
│   │   │
│   │   ├── widgets/                        ← Widgets reutilizables
│   │   │   ├── art_button.dart             ← Botón principal con estilo ArtStore
│   │   │   ├── art_text_field.dart         ← Campo de texto estilizado
│   │   │   ├── art_card.dart               ← Card base con borde arena
│   │   │   ├── art_badge.dart              ← Badge de estado (pedido, inventario)
│   │   │   ├── loading_overlay.dart        ← Overlay de carga café
│   │   │   ├── empty_state.dart            ← Pantalla vacía genérica
│   │   │   └── confirm_dialog.dart         ← Diálogo de confirmación
│   │   │
│   │   ├── constants/
│   │   │   ├── firestore_collections.dart  ← Nombres de colecciones Firestore
│   │   │   └── app_routes.dart             ← Definición de rutas go_router
│   │   │
│   │   └── utils/
│   │       ├── date_formatter.dart         ← Formato de fechas (intl)
│   │       ├── currency_formatter.dart     ← Formato de moneda (intl)
│   │       └── validators.dart             ← Funciones de validación de formularios
│   │
│   ├── data/
│   │   ├── models/                         ← Entidades Dart (fromMap / toMap)
│   │   │   ├── cliente_model.dart
│   │   │   ├── producto_model.dart
│   │   │   ├── categoria_model.dart
│   │   │   ├── proveedor_model.dart
│   │   │   ├── pedido_model.dart
│   │   │   ├── detalle_pedido_model.dart
│   │   │   ├── inventario_model.dart
│   │   │   ├── pago_model.dart
│   │   │   ├── envio_model.dart
│   │   │   └── empleado_model.dart
│   │   │
│   │   └── services/                       ← Acceso a Firestore y Firebase Auth
│   │       ├── auth_service.dart
│   │       ├── cliente_service.dart
│   │       ├── producto_service.dart
│   │       ├── categoria_service.dart
│   │       ├── proveedor_service.dart
│   │       ├── pedido_service.dart
│   │       ├── inventario_service.dart
│   │       ├── pago_service.dart
│   │       ├── envio_service.dart
│   │       └── empleado_service.dart
│   │
│   ├── providers/                          ← Estado global con ChangeNotifier
│   │   ├── auth_provider.dart
│   │   ├── cliente_provider.dart
│   │   ├── producto_provider.dart
│   │   ├── categoria_provider.dart
│   │   ├── proveedor_provider.dart
│   │   ├── carrito_provider.dart
│   │   ├── pedido_provider.dart
│   │   ├── inventario_provider.dart
│   │   └── empleado_provider.dart
│   │
│   └── presentation/                       ← Pantallas por módulo
│       ├── auth/
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   └── forgot_password_screen.dart
│       │
│       ├── home/
│       │   └── home_screen.dart            ← Shell con navegación adaptativa
│       │
│       ├── productos/
│       │   ├── productos_screen.dart        ← Catálogo con grid/lista
│       │   ├── producto_detalle_screen.dart ← Vista de producto individual
│       │   └── producto_form_screen.dart    ← Crear / editar producto
│       │
│       ├── pedidos/
│       │   ├── carrito_screen.dart          ← Carrito de compras
│       │   ├── checkout_screen.dart         ← Confirmación y pago
│       │   ├── pedidos_screen.dart          ← Lista de pedidos
│       │   └── pedido_detalle_screen.dart   ← Detalle de pedido
│       │
│       ├── clientes/
│       │   ├── clientes_screen.dart
│       │   └── cliente_form_screen.dart
│       │
│       ├── inventario/
│       │   └── inventario_screen.dart       ← Stock con alertas y gráfica
│       │
│       ├── empleados/
│       │   ├── empleados_screen.dart
│       │   └── empleado_form_screen.dart
│       │
│       └── proveedores/
│           ├── proveedores_screen.dart
│           └── proveedor_form_screen.dart
│
├── assets/
│   ├── images/                             ← Logo, placeholders
│   ├── fonts/                              ← Playfair Display (.ttf)
│   └── icons/                              ← SVG custom icons
│
├── android/                                ← Configuración Android
├── ios/                                    ← Configuración iOS
├── web/                                    ← Configuración Web
├── windows/                                ← Configuración Windows
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
└── README.md
```

---

# 5. PUBSPEC.YAML — DEPENDENCIAS

```yaml
name: artstore
description: Tienda de suministros de arte - ArtStore
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

  # ── Firebase ──────────────────────────────────────────────────────
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0           # Autenticación email + password
  cloud_firestore: ^4.15.0         # Base de datos en la nube
  firebase_storage: ^11.6.0        # Almacenamiento de imágenes de productos

  # ── Estado ────────────────────────────────────────────────────────
  provider: ^6.1.2                 # Gestión de estado (ChangeNotifier)

  # ── Tipografía y UI ───────────────────────────────────────────────
  google_fonts: ^6.2.1             # Lato, Nunito (cuerpo)
  cached_network_image: ^3.3.1     # Imágenes de productos con caché
  flutter_svg: ^2.0.10+1           # Iconos SVG personalizados
  shimmer: ^3.0.0                  # Skeleton loaders mientras carga
  badges: ^3.1.2                   # Badge numérico en icono del carrito
  fl_chart: ^0.67.0                # Gráficas de inventario en tonos café
  flutter_slidable: ^3.1.0         # Swipe para editar/borrar en listas
  dropdown_search: ^5.0.6          # Selects con búsqueda (categorías, etc.)
  awesome_snackbar_content: ^0.1.3 # Notificaciones elegantes

  # ── Formularios y validación ──────────────────────────────────────
  form_field_validator: ^1.1.1
  intl: ^0.19.0                    # Formato de fechas y moneda (MXN, etc.)

  # ── Utilidades ────────────────────────────────────────────────────
  uuid: ^4.3.3                     # Generación de IDs únicos en cliente
  equatable: ^2.0.5                # Comparación de instancias de modelos
  image_picker: ^1.0.7             # Seleccionar / capturar foto de producto
  go_router: ^13.2.0               # Navegación declarativa con guards de auth

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/

  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Regular.ttf
          weight: 400
        - asset: assets/fonts/PlayfairDisplay-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
```

---

# 6. MODELOS DART — ENTIDADES

## 6.1 firestore_collections.dart

```dart
// lib/core/constants/firestore_collections.dart

class FirestoreCollections {
  static const String clientes   = 'clientes';
  static const String productos  = 'productos';
  static const String categorias = 'categorias';
  static const String proveedores= 'proveedores';
  static const String pedidos    = 'pedidos';
  static const String detalles   = 'detalles';   // subcolección de pedidos
  static const String inventario = 'inventario';
  static const String pagos      = 'pagos';
  static const String envios     = 'envios';
  static const String empleados  = 'empleados';
}
```

## 6.2 cliente_model.dart

```dart
// lib/data/models/cliente_model.dart
import 'package:equatable/equatable.dart';

class ClienteModel extends Equatable {
  final String  id;
  final String  nombre;
  final String  email;
  final String? telefono;
  final String? direccion;
  final String? ciudad;
  final String? pais;
  final DateTime fechaRegistro;
  final bool    activo;

  const ClienteModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.pais,
    required this.fechaRegistro,
    this.activo = true,
  });

  factory ClienteModel.fromMap(String id, Map<String, dynamic> map) =>
      ClienteModel(
        id:            id,
        nombre:        map['nombre']        ?? '',
        email:         map['email']         ?? '',
        telefono:      map['telefono'],
        direccion:     map['direccion'],
        ciudad:        map['ciudad'],
        pais:          map['pais'],
        fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
        activo:        map['activo']        ?? true,
      );

  Map<String, dynamic> toMap() => {
    'nombre':        nombre,
    'email':         email,
    'telefono':      telefono,
    'direccion':     direccion,
    'ciudad':        ciudad,
    'pais':          pais,
    'fechaRegistro': fechaRegistro,
    'activo':        activo,
  };

  ClienteModel copyWith({String? nombre, String? telefono, String? direccion,
      String? ciudad, String? pais, bool? activo}) =>
      ClienteModel(
        id: id, nombre: nombre ?? this.nombre, email: email,
        telefono: telefono ?? this.telefono, direccion: direccion ?? this.direccion,
        ciudad: ciudad ?? this.ciudad, pais: pais ?? this.pais,
        fechaRegistro: fechaRegistro, activo: activo ?? this.activo);

  @override
  List<Object?> get props => [id, email, activo];
}
```

## 6.3 producto_model.dart

```dart
// lib/data/models/producto_model.dart
import 'package:equatable/equatable.dart';

class ProductoModel extends Equatable {
  final String  id;
  final String  categoriaId;
  final String  proveedorId;
  final String  nombre;
  final String? descripcion;
  final String? codigoBarras;
  final double  precio;
  final String  unidadMedida; // pieza | ml | kg | set
  final String? imagenUrl;
  final bool    activo;

  const ProductoModel({
    required this.id,
    required this.categoriaId,
    required this.proveedorId,
    required this.nombre,
    this.descripcion,
    this.codigoBarras,
    required this.precio,
    required this.unidadMedida,
    this.imagenUrl,
    this.activo = true,
  });

  factory ProductoModel.fromMap(String id, Map<String, dynamic> map) =>
      ProductoModel(
        id:            id,
        categoriaId:   map['categoriaId']   ?? '',
        proveedorId:   map['proveedorId']   ?? '',
        nombre:        map['nombre']        ?? '',
        descripcion:   map['descripcion'],
        codigoBarras:  map['codigoBarras'],
        precio:        (map['precio'] as num).toDouble(),
        unidadMedida:  map['unidadMedida']  ?? 'pieza',
        imagenUrl:     map['imagenUrl'],
        activo:        map['activo']        ?? true,
      );

  Map<String, dynamic> toMap() => {
    'categoriaId':  categoriaId,
    'proveedorId':  proveedorId,
    'nombre':       nombre,
    'descripcion':  descripcion,
    'codigoBarras': codigoBarras,
    'precio':       precio,
    'unidadMedida': unidadMedida,
    'imagenUrl':    imagenUrl,
    'activo':       activo,
  };

  ProductoModel copyWith({String? nombre, double? precio,
      String? imagenUrl, bool? activo, String? descripcion}) =>
      ProductoModel(
        id: id, categoriaId: categoriaId, proveedorId: proveedorId,
        nombre: nombre ?? this.nombre, descripcion: descripcion ?? this.descripcion,
        codigoBarras: codigoBarras, precio: precio ?? this.precio,
        unidadMedida: unidadMedida, imagenUrl: imagenUrl ?? this.imagenUrl,
        activo: activo ?? this.activo);

  @override
  List<Object?> get props => [id, nombre, precio, activo];
}
```

## 6.4 categoria_model.dart

```dart
// lib/data/models/categoria_model.dart
import 'package:equatable/equatable.dart';

class CategoriaModel extends Equatable {
  final String  id;
  final String  nombre;
  final String? descripcion;
  final String? categoriaPadreId; // auto-referencia para jerarquía
  final bool    activo;

  const CategoriaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaPadreId,
    this.activo = true,
  });

  factory CategoriaModel.fromMap(String id, Map<String, dynamic> map) =>
      CategoriaModel(
        id:               id,
        nombre:           map['nombre']           ?? '',
        descripcion:      map['descripcion'],
        categoriaPadreId: map['categoriaPadreId'],
        activo:           map['activo']           ?? true,
      );

  Map<String, dynamic> toMap() => {
    'nombre':           nombre,
    'descripcion':      descripcion,
    'categoriaPadreId': categoriaPadreId,
    'activo':           activo,
  };

  @override
  List<Object?> get props => [id, nombre];
}
```

## 6.5 proveedor_model.dart

```dart
// lib/data/models/proveedor_model.dart
import 'package:equatable/equatable.dart';

class ProveedorModel extends Equatable {
  final String  id;
  final String  nombre;
  final String? contacto;
  final String? email;
  final String? telefono;
  final String? pais;
  final bool    activo;

  const ProveedorModel({
    required this.id,
    required this.nombre,
    this.contacto,
    this.email,
    this.telefono,
    this.pais,
    this.activo = true,
  });

  factory ProveedorModel.fromMap(String id, Map<String, dynamic> map) =>
      ProveedorModel(
        id:       id,
        nombre:   map['nombre']   ?? '',
        contacto: map['contacto'],
        email:    map['email'],
        telefono: map['telefono'],
        pais:     map['pais'],
        activo:   map['activo']   ?? true,
      );

  Map<String, dynamic> toMap() => {
    'nombre':   nombre,
    'contacto': contacto,
    'email':    email,
    'telefono': telefono,
    'pais':     pais,
    'activo':   activo,
  };

  @override
  List<Object?> get props => [id, nombre];
}
```

## 6.6 pedido_model.dart

```dart
// lib/data/models/pedido_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PedidoModel extends Equatable {
  final String   id;
  final String   clienteId;
  final String   empleadoId;
  final DateTime fechaPedido;
  final String   estado; // pendiente|confirmado|enviado|entregado|cancelado
  final double   subtotal;
  final double   impuesto;
  final double   total;
  final String?  notas;

  const PedidoModel({
    required this.id,
    required this.clienteId,
    required this.empleadoId,
    required this.fechaPedido,
    required this.estado,
    required this.subtotal,
    required this.impuesto,
    required this.total,
    this.notas,
  });

  factory PedidoModel.fromMap(String id, Map<String, dynamic> map) =>
      PedidoModel(
        id:          id,
        clienteId:   map['clienteId']   ?? '',
        empleadoId:  map['empleadoId']  ?? '',
        fechaPedido: (map['fechaPedido'] as Timestamp).toDate(),
        estado:      map['estado']      ?? 'pendiente',
        subtotal:    (map['subtotal']   as num).toDouble(),
        impuesto:    (map['impuesto']   as num).toDouble(),
        total:       (map['total']      as num).toDouble(),
        notas:       map['notas'],
      );

  Map<String, dynamic> toMap() => {
    'clienteId':   clienteId,
    'empleadoId':  empleadoId,
    'fechaPedido': Timestamp.fromDate(fechaPedido),
    'estado':      estado,
    'subtotal':    subtotal,
    'impuesto':    impuesto,
    'total':       total,
    'notas':       notas,
  };

  PedidoModel copyWith({String? estado}) =>
      PedidoModel(
        id: id, clienteId: clienteId, empleadoId: empleadoId,
        fechaPedido: fechaPedido, estado: estado ?? this.estado,
        subtotal: subtotal, impuesto: impuesto, total: total, notas: notas);

  @override
  List<Object?> get props => [id, estado, total];
}
```

## 6.7 detalle_pedido_model.dart

```dart
// lib/data/models/detalle_pedido_model.dart
import 'package:equatable/equatable.dart';
import 'producto_model.dart';

class DetallePedidoModel extends Equatable {
  final String  id;
  final String  pedidoId;
  final String  productoId;
  final String  nombreProducto; // snapshot del nombre al momento de la venta
  final int     cantidad;
  final double  precioUnitario;
  final double  descuento;      // porcentaje 0-100
  final double  subtotalLinea;  // calculado: cantidad * precio * (1 - descuento/100)

  const DetallePedidoModel({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
    required this.subtotalLinea,
  });

  // Constructor desde ProductoModel (para agregar al carrito)
  factory DetallePedidoModel.fromProducto(ProductoModel p, {int cantidad = 1}) {
    final subtotal = p.precio * cantidad;
    return DetallePedidoModel(
      id:             '',
      pedidoId:       '',
      productoId:     p.id,
      nombreProducto: p.nombre,
      cantidad:       cantidad,
      precioUnitario: p.precio,
      descuento:      0,
      subtotalLinea:  subtotal,
    );
  }

  factory DetallePedidoModel.fromMap(String id, Map<String, dynamic> map) =>
      DetallePedidoModel(
        id:             id,
        pedidoId:       map['pedidoId']       ?? '',
        productoId:     map['productoId']      ?? '',
        nombreProducto: map['nombreProducto']  ?? '',
        cantidad:       map['cantidad']        ?? 1,
        precioUnitario: (map['precioUnitario'] as num).toDouble(),
        descuento:      (map['descuento']      as num).toDouble(),
        subtotalLinea:  (map['subtotalLinea']  as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'pedidoId':       pedidoId,
    'productoId':     productoId,
    'nombreProducto': nombreProducto,
    'cantidad':       cantidad,
    'precioUnitario': precioUnitario,
    'descuento':      descuento,
    'subtotalLinea':  subtotalLinea,
  };

  DetallePedidoModel copyWith({int? cantidad}) {
    final c = cantidad ?? this.cantidad;
    return DetallePedidoModel(
      id: id, pedidoId: pedidoId, productoId: productoId,
      nombreProducto: nombreProducto, cantidad: c,
      precioUnitario: precioUnitario, descuento: descuento,
      subtotalLinea: precioUnitario * c * (1 - descuento / 100));
  }

  @override
  List<Object?> get props => [id, productoId, cantidad];
}
```

## 6.8 inventario_model.dart

```dart
// lib/data/models/inventario_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class InventarioModel extends Equatable {
  final String   id;
  final String   productoId;
  final int      stockActual;
  final int      stockMinimo;
  final int?     stockMaximo;
  final String?  ubicacion;
  final DateTime ultimaActualizacion;

  const InventarioModel({
    required this.id,
    required this.productoId,
    required this.stockActual,
    required this.stockMinimo,
    this.stockMaximo,
    this.ubicacion,
    required this.ultimaActualizacion,
  });

  bool get bajoStock => stockActual <= stockMinimo;

  factory InventarioModel.fromMap(String id, Map<String, dynamic> map) =>
      InventarioModel(
        id:                  id,
        productoId:          map['productoId']          ?? '',
        stockActual:         map['stockActual']         ?? 0,
        stockMinimo:         map['stockMinimo']         ?? 0,
        stockMaximo:         map['stockMaximo'],
        ubicacion:           map['ubicacion'],
        ultimaActualizacion: (map['ultimaActualizacion'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'productoId':          productoId,
    'stockActual':         stockActual,
    'stockMinimo':         stockMinimo,
    'stockMaximo':         stockMaximo,
    'ubicacion':           ubicacion,
    'ultimaActualizacion': Timestamp.fromDate(ultimaActualizacion),
  };

  @override
  List<Object?> get props => [id, productoId, stockActual];
}
```

## 6.9 pago_model.dart

```dart
// lib/data/models/pago_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PagoModel extends Equatable {
  final String   id;
  final String   pedidoId;
  final String   metodo;     // efectivo|tarjeta_credito|tarjeta_debito|transferencia
  final double   monto;
  final DateTime fechaPago;
  final String?  referencia;
  final String   estado;     // pendiente|procesado|fallido|reembolsado

  const PagoModel({
    required this.id,
    required this.pedidoId,
    required this.metodo,
    required this.monto,
    required this.fechaPago,
    this.referencia,
    required this.estado,
  });

  factory PagoModel.fromMap(String id, Map<String, dynamic> map) =>
      PagoModel(
        id:         id,
        pedidoId:   map['pedidoId']  ?? '',
        metodo:     map['metodo']    ?? 'efectivo',
        monto:      (map['monto']    as num).toDouble(),
        fechaPago:  (map['fechaPago'] as Timestamp).toDate(),
        referencia: map['referencia'],
        estado:     map['estado']    ?? 'pendiente',
      );

  Map<String, dynamic> toMap() => {
    'pedidoId':   pedidoId,
    'metodo':     metodo,
    'monto':      monto,
    'fechaPago':  Timestamp.fromDate(fechaPago),
    'referencia': referencia,
    'estado':     estado,
  };

  @override
  List<Object?> get props => [id, pedidoId, estado];
}
```

## 6.10 envio_model.dart

```dart
// lib/data/models/envio_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EnvioModel extends Equatable {
  final String  id;
  final String  pedidoId;
  final String  transportista;
  final String? numeroGuia;
  final String  direccionDestino;
  final DateTime? fechaEnvio;
  final DateTime? fechaEntrega;
  final String  estado; // pendiente|en_camino|entregado

  const EnvioModel({
    required this.id,
    required this.pedidoId,
    required this.transportista,
    this.numeroGuia,
    required this.direccionDestino,
    this.fechaEnvio,
    this.fechaEntrega,
    required this.estado,
  });

  factory EnvioModel.fromMap(String id, Map<String, dynamic> map) =>
      EnvioModel(
        id:               id,
        pedidoId:         map['pedidoId']         ?? '',
        transportista:    map['transportista']     ?? '',
        numeroGuia:       map['numeroGuia'],
        direccionDestino: map['direccionDestino']  ?? '',
        fechaEnvio:       map['fechaEnvio']   != null
            ? (map['fechaEnvio'] as Timestamp).toDate() : null,
        fechaEntrega:     map['fechaEntrega'] != null
            ? (map['fechaEntrega'] as Timestamp).toDate() : null,
        estado:           map['estado']            ?? 'pendiente',
      );

  Map<String, dynamic> toMap() => {
    'pedidoId':         pedidoId,
    'transportista':    transportista,
    'numeroGuia':       numeroGuia,
    'direccionDestino': direccionDestino,
    'fechaEnvio':       fechaEnvio != null
        ? Timestamp.fromDate(fechaEnvio!) : null,
    'fechaEntrega':     fechaEntrega != null
        ? Timestamp.fromDate(fechaEntrega!) : null,
    'estado':           estado,
  };

  @override
  List<Object?> get props => [id, pedidoId, estado];
}
```

## 6.11 empleado_model.dart

```dart
// lib/data/models/empleado_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EmpleadoModel extends Equatable {
  final String  id;
  final String  nombre;
  final String  puesto;
  final String  email;
  final String? telefono;
  final DateTime fechaContrato;
  final double? salario;
  final bool    activo;

  const EmpleadoModel({
    required this.id,
    required this.nombre,
    required this.puesto,
    required this.email,
    this.telefono,
    required this.fechaContrato,
    this.salario,
    this.activo = true,
  });

  factory EmpleadoModel.fromMap(String id, Map<String, dynamic> map) =>
      EmpleadoModel(
        id:            id,
        nombre:        map['nombre']         ?? '',
        puesto:        map['puesto']         ?? '',
        email:         map['email']          ?? '',
        telefono:      map['telefono'],
        fechaContrato: (map['fechaContrato'] as Timestamp).toDate(),
        salario:       map['salario'] != null
            ? (map['salario'] as num).toDouble() : null,
        activo:        map['activo']         ?? true,
      );

  Map<String, dynamic> toMap() => {
    'nombre':        nombre,
    'puesto':        puesto,
    'email':         email,
    'telefono':      telefono,
    'fechaContrato': Timestamp.fromDate(fechaContrato),
    'salario':       salario,
    'activo':        activo,
  };

  @override
  List<Object?> get props => [id, email, activo];
}
```

---

# 7. SERVICIOS FIREBASE

## 7.1 auth_service.dart

```dart
// lib/data/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();
  User?         get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> updateDisplayName(String name) =>
      _auth.currentUser!.updateDisplayName(name);
}
```

## 7.2 producto_service.dart

```dart
// lib/data/services/producto_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import '../../core/constants/firestore_collections.dart';

class ProductoService {
  final _col = FirebaseFirestore.instance
      .collection(FirestoreCollections.productos);

  // ── Lectura ──────────────────────────────────────────────────────
  Future<List<ProductoModel>> getAll({bool soloActivos = true}) async {
    Query q = soloActivos
        ? _col.where('activo', isEqualTo: true)
        : _col;
    final snap = await q.get();
    return snap.docs
        .map((d) => ProductoModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductoModel>> getByCategoria(String categoriaId) async {
    final snap = await _col
        .where('activo',      isEqualTo: true)
        .where('categoriaId', isEqualTo: categoriaId)
        .get();
    return snap.docs
        .map((d) => ProductoModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<ProductoModel>> stream() =>
      _col.where('activo', isEqualTo: true).snapshots().map((s) =>
          s.docs.map((d) =>
              ProductoModel.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList());

  Future<ProductoModel?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProductoModel.fromMap(doc.id, doc.data()!);
  }

  // ── Escritura ────────────────────────────────────────────────────
  Future<String> save(ProductoModel p) async {
    if (p.id.isEmpty) {
      final ref = await _col.add(p.toMap());
      return ref.id;
    } else {
      await _col.doc(p.id).set(p.toMap(), SetOptions(merge: true));
      return p.id;
    }
  }

  // Soft delete: nunca elimina del documento
  Future<void> delete(String id) =>
      _col.doc(id).update({'activo': false});
}
```

## 7.3 pedido_service.dart

```dart
// lib/data/services/pedido_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';
import '../models/detalle_pedido_model.dart';
import '../../core/constants/firestore_collections.dart';

class PedidoService {
  final _db  = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance
      .collection(FirestoreCollections.pedidos);

  Future<List<PedidoModel>> getByCliente(String clienteId) async {
    final snap = await _col
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fechaPedido', descending: true)
        .get();
    return snap.docs
        .map((d) => PedidoModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<PedidoModel>> getAll() async {
    final snap = await _col
        .orderBy('fechaPedido', descending: true)
        .get();
    return snap.docs
        .map((d) => PedidoModel.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<List<PedidoModel>> stream() =>
      _col.orderBy('fechaPedido', descending: true).snapshots().map((s) =>
          s.docs.map((d) => PedidoModel.fromMap(d.id, d.data())).toList());

  // Crea pedido + detalles en una sola transacción atómica
  Future<String> crearPedido(
      PedidoModel pedido, List<DetallePedidoModel> detalles) async {
    final pedidoRef = _col.doc();

    await _db.runTransaction((tx) async {
      tx.set(pedidoRef, pedido.toMap());
      for (final det in detalles) {
        final detRef = pedidoRef
            .collection(FirestoreCollections.detalles)
            .doc();
        tx.set(detRef, {
          ...det.toMap(),
          'pedidoId': pedidoRef.id,
        });
      }
    });

    return pedidoRef.id;
  }

  Future<void> actualizarEstado(String pedidoId, String nuevoEstado) =>
      _col.doc(pedidoId).update({'estado': nuevoEstado});

  Future<List<DetallePedidoModel>> getDetalles(String pedidoId) async {
    final snap = await _col
        .doc(pedidoId)
        .collection(FirestoreCollections.detalles)
        .get();
    return snap.docs
        .map((d) => DetallePedidoModel.fromMap(d.id, d.data()))
        .toList();
  }
}
```

## 7.4 inventario_service.dart

```dart
// lib/data/services/inventario_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventario_model.dart';
import '../../core/constants/firestore_collections.dart';

class InventarioService {
  final _col = FirebaseFirestore.instance
      .collection(FirestoreCollections.inventario);

  Future<List<InventarioModel>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => InventarioModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<InventarioModel>> getBajoStock() async {
    final all = await getAll();
    return all.where((i) => i.bajoStock).toList();
  }

  Stream<List<InventarioModel>> stream() =>
      _col.snapshots().map((s) =>
          s.docs.map((d) => InventarioModel.fromMap(d.id, d.data())).toList());

  Future<void> actualizarStock(String inventarioId, int nuevoStock) =>
      _col.doc(inventarioId).update({
        'stockActual':         nuevoStock,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });

  Future<void> save(InventarioModel m) async {
    if (m.id.isEmpty) {
      await _col.add(m.toMap());
    } else {
      await _col.doc(m.id).set(m.toMap(), SetOptions(merge: true));
    }
  }
}
```

---

# 8. PROVIDERS — GESTIÓN DE ESTADO

## 8.1 main.dart — MultiProvider Raíz

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/categoria_provider.dart';
import 'providers/proveedor_provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/pedido_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/inventario_provider.dart';
import 'providers/empleado_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ArtStoreApp());
}

class ArtStoreApp extends StatelessWidget {
  const ArtStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => EmpleadoProvider()),
      ],
      child: MaterialApp.router(
        title:            'ArtStore',
        debugShowCheckedModeBanner: false,
        theme:            AppTheme.light,
        darkTheme:        AppTheme.dark,
        themeMode:        ThemeMode.system,
        routerConfig:     AppRouter.router,
      ),
    );
  }
}
```

## 8.2 auth_provider.dart

```dart
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  User?   _user;
  bool    _loading = false;
  String? _error;

  User?   get user    => _user;
  bool    get loading => _loading;
  String? get error   => _error;
  bool    get isAuth  => _user != null;

  AuthProvider() {
    _service.authState.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await _service.signIn(email, password);
      _loading = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error   = _mapError(e.code);
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String nombre) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await _service.register(email, password);
      await _service.updateDisplayName(nombre);
      _loading = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error   = _mapError(e.code);
      _loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  Future<bool> resetPassword(String email) async {
    _loading = true; notifyListeners();
    try {
      await _service.resetPassword(email);
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error   = 'No se pudo enviar el correo de recuperación';
      _loading = false; notifyListeners();
      return false;
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':      return 'No existe cuenta con ese correo';
      case 'wrong-password':      return 'Contraseña incorrecta';
      case 'email-already-in-use':return 'El correo ya está registrado';
      case 'weak-password':       return 'La contraseña es muy débil (mín. 6 chars)';
      case 'invalid-email':       return 'Correo electrónico inválido';
      default:                    return 'Error de autenticación: $code';
    }
  }
}
```

## 8.3 carrito_provider.dart

```dart
// lib/providers/carrito_provider.dart
import 'package:flutter/material.dart';
import '../data/models/producto_model.dart';
import '../data/models/detalle_pedido_model.dart';

class CarritoProvider extends ChangeNotifier {
  final Map<String, DetallePedidoModel> _items = {};

  // ── Getters ──────────────────────────────────────────────────────
  Map<String, DetallePedidoModel> get items   => Map.unmodifiable(_items);
  List<DetallePedidoModel>        get lista   => _items.values.toList();
  int    get totalItems  => _items.values.fold(0, (s, i) => s + i.cantidad);
  bool   get isEmpty     => _items.isEmpty;

  double get subtotal    => _items.values.fold(
      0, (s, i) => s + i.subtotalLinea);
  double get iva         => subtotal * 0.16;
  double get total       => subtotal + iva;

  // ── Acciones ─────────────────────────────────────────────────────
  void agregar(ProductoModel producto) {
    if (_items.containsKey(producto.id)) {
      final item = _items[producto.id]!;
      _items[producto.id] = item.copyWith(cantidad: item.cantidad + 1);
    } else {
      _items[producto.id] = DetallePedidoModel.fromProducto(producto);
    }
    notifyListeners();
  }

  void quitar(String productoId) {
    if (!_items.containsKey(productoId)) return;
    final item = _items[productoId]!;
    if (item.cantidad <= 1) {
      _items.remove(productoId);
    } else {
      _items[productoId] = item.copyWith(cantidad: item.cantidad - 1);
    }
    notifyListeners();
  }

  void eliminar(String productoId) {
    _items.remove(productoId);
    notifyListeners();
  }

  void limpiar() {
    _items.clear();
    notifyListeners();
  }
}
```

## 8.4 producto_provider.dart

```dart
// lib/providers/producto_provider.dart
import 'package:flutter/material.dart';
import '../data/models/producto_model.dart';
import '../data/services/producto_service.dart';

class ProductoProvider extends ChangeNotifier {
  final _service = ProductoService();

  List<ProductoModel> _productos  = [];
  bool                _loading    = false;
  String?             _error;
  String              _filtro     = '';
  String?             _categoriaFiltro;

  List<ProductoModel> get productos => _filtrados;
  bool                get loading  => _loading;
  String?             get error    => _error;

  List<ProductoModel> get _filtrados {
    var lista = _productos;
    if (_categoriaFiltro != null) {
      lista = lista.where((p) => p.categoriaId == _categoriaFiltro).toList();
    }
    if (_filtro.isNotEmpty) {
      lista = lista.where((p) =>
          p.nombre.toLowerCase().contains(_filtro.toLowerCase())).toList();
    }
    return lista;
  }

  void setFiltro(String v)      { _filtro = v; notifyListeners(); }
  void setCategoria(String? id) { _categoriaFiltro = id; notifyListeners(); }

  Future<void> cargar() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _productos = await _service.getAll();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<bool> guardar(ProductoModel p) async {
    try {
      await _service.save(p);
      await cargar();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _service.delete(id);
      await cargar();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

## 8.5 pedido_provider.dart

```dart
// lib/providers/pedido_provider.dart
import 'package:flutter/material.dart';
import '../data/models/pedido_model.dart';
import '../data/models/detalle_pedido_model.dart';
import '../data/services/pedido_service.dart';

class PedidoProvider extends ChangeNotifier {
  final _service = PedidoService();

  List<PedidoModel>         _pedidos       = [];
  List<DetallePedidoModel>  _detallesActual= [];
  bool                      _loading       = false;
  String?                   _error;

  List<PedidoModel>        get pedidos        => _pedidos;
  List<DetallePedidoModel> get detallesActual => _detallesActual;
  bool                     get loading        => _loading;
  String?                  get error          => _error;

  Future<void> cargar() async {
    _loading = true; notifyListeners();
    try {
      _pedidos = await _service.getAll();
      _error   = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<String?> crear(PedidoModel pedido,
      List<DetallePedidoModel> detalles) async {
    _loading = true; notifyListeners();
    try {
      final id = await _service.crearPedido(pedido, detalles);
      await cargar();
      _loading = false; notifyListeners();
      return id;
    } catch (e) {
      _error   = e.toString();
      _loading = false; notifyListeners();
      return null;
    }
  }

  Future<void> actualizarEstado(String pedidoId, String estado) async {
    await _service.actualizarEstado(pedidoId, estado);
    await cargar();
  }

  Future<void> cargarDetalles(String pedidoId) async {
    _detallesActual = await _service.getDetalles(pedidoId);
    notifyListeners();
  }
}
```

## 8.6 inventario_provider.dart

```dart
// lib/providers/inventario_provider.dart
import 'package:flutter/material.dart';
import '../data/models/inventario_model.dart';
import '../data/services/inventario_service.dart';

class InventarioProvider extends ChangeNotifier {
  final _service = InventarioService();

  List<InventarioModel> _inventario = [];
  bool                  _loading    = false;
  String?               _error;

  List<InventarioModel> get inventario  => _inventario;
  List<InventarioModel> get bajoStock   =>
      _inventario.where((i) => i.bajoStock).toList();
  bool                  get loading     => _loading;
  String?               get error       => _error;

  Future<void> cargar() async {
    _loading = true; notifyListeners();
    try {
      _inventario = await _service.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<void> actualizarStock(String id, int nuevoStock) async {
    await _service.actualizarStock(id, nuevoStock);
    await cargar();
  }
}
```

---

# 9. PANTALLAS PRINCIPALES

## 9.1 app_routes.dart — Navegación con go_router

```dart
// lib/core/constants/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/productos/productos_screen.dart';
import '../../presentation/productos/producto_detalle_screen.dart';
import '../../presentation/productos/producto_form_screen.dart';
import '../../presentation/pedidos/carrito_screen.dart';
import '../../presentation/pedidos/checkout_screen.dart';
import '../../presentation/pedidos/pedidos_screen.dart';
import '../../presentation/clientes/clientes_screen.dart';
import '../../presentation/inventario/inventario_screen.dart';
import '../../presentation/empleados/empleados_screen.dart';
import '../../presentation/proveedores/proveedores_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuth = context.read<AuthProvider>().isAuth;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth  &&  isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot',   builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(path: 'productos',           builder: (_, __) => const ProductosScreen()),
          GoRoute(path: 'productos/nuevo',     builder: (_, __) => const ProductoFormScreen()),
          GoRoute(path: 'productos/:id',       builder: (_, s) => ProductoDetalleScreen(id: s.pathParameters['id']!)),
          GoRoute(path: 'carrito',             builder: (_, __) => const CarritoScreen()),
          GoRoute(path: 'checkout',            builder: (_, __) => const CheckoutScreen()),
          GoRoute(path: 'pedidos',             builder: (_, __) => const PedidosScreen()),
          GoRoute(path: 'clientes',            builder: (_, __) => const ClientesScreen()),
          GoRoute(path: 'inventario',          builder: (_, __) => const InventarioScreen()),
          GoRoute(path: 'empleados',           builder: (_, __) => const EmpleadosScreen()),
          GoRoute(path: 'proveedores',         builder: (_, __) => const ProveedoresScreen()),
        ],
      ),
    ],
  );
}
```

## 9.2 login_screen.dart

```dart
// lib/presentation/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form     = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool  _obscure  = true;

  @override
  void dispose() {
    _email.dispose(); _password.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Error al iniciar sesión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──
                Text('ArtStore', style: AppTextStyles.displayTitle.copyWith(
                    color: AppColors.caramelo, fontSize: 44)),
                const SizedBox(height: 6),
                Text('Suministros de arte', style: AppTextStyles.bodyText
                    .copyWith(color: AppColors.arena, fontSize: 15)),
                const SizedBox(height: 48),

                // ── Email ──
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.arena),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.caramelo),
                    labelStyle: TextStyle(color: AppColors.arena.withOpacity(0.7)),
                    fillColor: AppColors.cafeNegro,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.sienna)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.caramelo, width: 2)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Contraseña ──
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  style: TextStyle(color: AppColors.arena),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.caramelo),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.sienna),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    labelStyle: TextStyle(color: AppColors.arena.withOpacity(0.7)),
                    fillColor: AppColors.cafeNegro,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.sienna)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.caramelo, width: 2)),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 8),

                // ── Olvidé contraseña ──
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot'),
                    child: Text('¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColors.caramelo, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Botón Ingresar ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.caramelo,
                      foregroundColor: AppColors.espresso,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: auth.loading
                        ? const CircularProgressIndicator(color: AppColors.espresso)
                        : Text('Ingresar', style: AppTextStyles.buttonText
                            .copyWith(color: AppColors.espresso, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Registro ──
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('¿No tienes cuenta? ', style: TextStyle(color: AppColors.arena)),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text('Regístrate',
                        style: TextStyle(color: AppColors.caramelo, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 9.3 home_screen.dart — Navegación Adaptativa

```dart
// lib/presentation/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/producto_provider.dart';
import '../productos/productos_screen.dart';
import '../pedidos/pedidos_screen.dart';
import '../inventario/inventario_screen.dart';
import '../clientes/clientes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ProductosScreen(),
    PedidosScreen(),
    InventarioScreen(),
    ClientesScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette),     label: 'Catálogo'),
    NavigationDestination(icon: Icon(Icons.receipt_outlined),  selectedIcon: Icon(Icons.receipt),     label: 'Pedidos'),
    NavigationDestination(icon: Icon(Icons.inventory_outlined),selectedIcon: Icon(Icons.inventory),   label: 'Inventario'),
    NavigationDestination(icon: Icon(Icons.people_outline),    selectedIcon: Icon(Icons.people),      label: 'Clientes'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final auth    = context.watch<AuthProvider>();
    final wide    = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text('ArtStore', style: AppTextStyles.displayTitle
            .copyWith(color: AppColors.marfil, fontSize: 22)),
        actions: [
          // Carrito con badge
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.marfil),
              onPressed: () => context.push('/home/carrito'),
            ),
            if (carrito.totalItems > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.caramelo, shape: BoxShape.circle),
                  child: Center(child: Text('${carrito.totalItems}',
                      style: const TextStyle(fontSize: 11, color: AppColors.espresso,
                          fontWeight: FontWeight.bold))),
                ),
              ),
          ]),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.marfil),
            onPressed: () async {
              await auth.signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),

      // Navegación adaptativa
      body: wide
          ? Row(children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                backgroundColor: AppColors.crema,
                selectedIconTheme:   const IconThemeData(color: AppColors.canela),
                unselectedIconTheme: const IconThemeData(color: AppColors.sienna),
                selectedLabelTextStyle: const TextStyle(color: AppColors.canela),
                destinations: _destinations.map((d) =>
                    NavigationRailDestination(
                      icon: d.icon, selectedIcon: d.selectedIcon,
                      label: Text(d.label))).toList(),
              ),
              const VerticalDivider(width: 1, color: AppColors.arena),
              Expanded(child: _screens[_selectedIndex]),
            ])
          : _screens[_selectedIndex],

      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor:  AppColors.crema,
        indicatorColor:   AppColors.canela.withOpacity(0.15),
        destinations:     _destinations,
      ),
    );
  }
}
```

## 9.4 productos_screen.dart

```dart
// lib/presentation/productos/productos_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/producto_model.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/producto_provider.dart';

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<ProductoProvider>();
    final carrito = context.read<CarritoProvider>();

    return Scaffold(
      backgroundColor: AppColors.marfil,
      body: Column(children: [
        // ── Barra de búsqueda ──
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: prov.setFiltro,
            decoration: InputDecoration(
              hintText:   'Buscar suministros…',
              prefixIcon: const Icon(Icons.search, color: AppColors.sienna),
              filled:     true,
              fillColor:  AppColors.crema,
              border:     OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide.none),
            ),
          ),
        ),

        // ── Grid de productos ──
        Expanded(
          child: prov.loading
              ? _buildSkeleton()
              : prov.productos.isEmpty
                  ? Center(child: Text('Sin productos', style: AppTextStyles.bodyText))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12,
                        mainAxisSpacing: 12, childAspectRatio: 0.72),
                      itemCount: prov.productos.length,
                      itemBuilder: (_, i) =>
                          _ProductoCard(p: prov.productos[i], carrito: carrito),
                    ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/productos/nuevo'),
        backgroundColor: AppColors.caramelo,
        child: const Icon(Icons.add, color: AppColors.espresso),
      ),
    );
  }

  Widget _buildSkeleton() => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12,
        mainAxisSpacing: 12, childAspectRatio: 0.72),
    itemCount: 6,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: AppColors.crema,
      highlightColor: AppColors.marfil,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.crema,
          borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _ProductoCard extends StatelessWidget {
  final ProductoModel p;
  final CarritoProvider carrito;
  const _ProductoCard({required this.p, required this.carrito});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/productos/${p.id}'),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.crema,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.arena.withOpacity(0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: p.imagenUrl != null
                  ? CachedNetworkImage(imageUrl: p.imagenUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.crema,
                      child: const Icon(Icons.palette, color: AppColors.sienna, size: 48)),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.nombre, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              Text('\$${p.precio.toStringAsFixed(2)} MXN',
                  style: AppTextStyles.price.copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    carrito.agregar(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p.nombre} agregado al carrito'),
                        backgroundColor: AppColors.canela,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Agregar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canela,
                    foregroundColor: AppColors.marfil,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
```

## 9.5 carrito_screen.dart

```dart
// lib/presentation/pedidos/carrito_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: AppColors.marfil,
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: AppColors.canela,
        foregroundColor: AppColors.marfil,
      ),
      body: carrito.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 80, color: AppColors.arena),
              const SizedBox(height: 16),
              Text('Tu carrito está vacío', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Ver productos', style: TextStyle(color: AppColors.canela)),
              ),
            ]))
          : Column(children: [
              // Lista de items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: carrito.lista.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.arena, height: 1),
                  itemBuilder: (_, i) {
                    final item = carrito.lista[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      title: Text(item.nombreProducto,
                          style: AppTextStyles.cardTitle),
                      subtitle: Text('\$${item.precioUnitario.toStringAsFixed(2)} c/u',
                          style: AppTextStyles.bodyText),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.sienna),
                          onPressed: () =>
                              context.read<CarritoProvider>().quitar(item.productoId),
                        ),
                        Text('${item.cantidad}',
                            style: AppTextStyles.cardTitle),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppColors.canela),
                          onPressed: () {
                            // agregar requiere ProductoModel; aquí se simplifica
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.terracota),
                          onPressed: () =>
                              context.read<CarritoProvider>().eliminar(item.productoId),
                        ),
                      ]),
                    );
                  },
                ),
              ),

              // Resumen de totales
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.crema,
                  border: Border(top: BorderSide(color: AppColors.arena)),
                ),
                child: Column(children: [
                  _TotalRow(label: 'Subtotal',
                      valor: '\$${carrito.subtotal.toStringAsFixed(2)} MXN'),
                  _TotalRow(label: 'IVA (16%)',
                      valor: '\$${carrito.iva.toStringAsFixed(2)} MXN'),
                  const Divider(color: AppColors.arena),
                  _TotalRow(label: 'Total',
                      valor: '\$${carrito.total.toStringAsFixed(2)} MXN',
                      bold: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/home/checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramelo,
                        foregroundColor: AppColors.espresso,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Confirmar pedido',
                          style: AppTextStyles.buttonText
                              .copyWith(color: AppColors.espresso)),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label, valor;
  final bool   bold;
  const _TotalRow({required this.label, required this.valor, this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
          color: AppColors.sienna,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(valor, style: TextStyle(
          color: bold ? AppColors.canela : AppColors.cafeNegro,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: bold ? 18 : 14)),
    ]),
  );
}
```

---

# 10. CONFIGURACIÓN FIREBASE

## 10.1 firestore.rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Función auxiliar: verifica si el usuario tiene rol admin
    function isAdmin() {
      return request.auth != null && request.auth.token.admin == true;
    }

    // Función auxiliar: verifica autenticación básica
    function isAuth() {
      return request.auth != null;
    }

    // Todos los documentos: lectura solo autenticados
    match /{document=**} {
      allow read: if isAuth();
    }

    // Productos: solo admin puede escribir
    match /productos/{id} {
      allow write: if isAdmin();
    }

    // Categorías: solo admin
    match /categorias/{id} {
      allow write: if isAdmin();
    }

    // Proveedores: solo admin
    match /proveedores/{id} {
      allow write: if isAdmin();
    }

    // Pedidos: cualquier autenticado puede crear; admin puede modificar
    match /pedidos/{pedidoId} {
      allow create: if isAuth();
      allow update, delete: if isAdmin();

      // Detalles del pedido: misma regla
      match /detalles/{detalleId} {
        allow create: if isAuth();
        allow update, delete: if isAdmin();
      }
    }

    // Clientes: solo admin puede crear/modificar
    match /clientes/{id} {
      allow write: if isAdmin();
    }

    // Inventario: solo admin
    match /inventario/{id} {
      allow write: if isAdmin();
    }

    // Pagos: cualquier autenticado puede crear; admin modifica
    match /pagos/{id} {
      allow create: if isAuth();
      allow update, delete: if isAdmin();
    }

    // Envíos: solo admin
    match /envios/{id} {
      allow write: if isAdmin();
    }

    // Empleados: solo admin
    match /empleados/{id} {
      allow write: if isAdmin();
    }
  }
}
```

## 10.2 firestore.indexes.json

```json
{
  "indexes": [
    {
      "collectionGroup": "productos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "activo",      "order": "ASCENDING" },
        { "fieldPath": "categoriaId", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "productos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "activo",      "order": "ASCENDING" },
        { "fieldPath": "proveedorId", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "clienteId",   "order": "ASCENDING" },
        { "fieldPath": "fechaPedido", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pedidos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "estado",      "order": "ASCENDING" },
        { "fieldPath": "fechaPedido", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "inventario",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "productoId",  "order": "ASCENDING" },
        { "fieldPath": "stockActual", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## 10.3 firebase.json

```json
{
  "firestore": {
    "rules":   "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public":    "build/web",
    "ignore":    ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
```

## 10.4 storage.rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Imágenes de productos: lectura pública, escritura solo admin
    match /productos/{imageId} {
      allow read:  if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true
                   && request.resource.size < 5 * 1024 * 1024  // máx 5MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 10.5 Pasos de Configuración Inicial

```
PASO 1 — Crear proyecto Flutter
  flutter create artstore --platforms android,ios,web,windows
  cd artstore

PASO 2 — Instalar FlutterFire CLI
  dart pub global activate flutterfire_cli
  flutterfire configure
  (esto genera lib/firebase_options.dart automáticamente)

PASO 3 — Firebase Console
  → Ir a console.firebase.google.com
  → Crear proyecto (SIN Google Analytics)
  → Authentication → Sign-in method → Email/Password: ACTIVAR
  → Desactivar todos los demás métodos

PASO 4 — Crear Firestore
  → Firestore Database → Crear base de datos
  → Modo: Producción
  → Región: us-central1 (o la más cercana)
  → Reemplazar reglas con el contenido de firestore.rules

PASO 5 — Firebase Storage
  → Storage → Comenzar
  → Modo: Producción
  → Reemplazar reglas con el contenido de storage.rules

PASO 6 — Desplegar reglas e índices
  firebase deploy --only firestore:rules,firestore:indexes

PASO 7 — Asignar rol admin (Firebase Functions o consola)
  En la consola de Firebase → Authentication → seleccionar usuario
  → Se recomienda Firebase Admin SDK para asignar custom claims:
  admin.auth().setCustomUserClaims(uid, { admin: true })
```

---

# 11. HOJA DE RUTA DE IMPLEMENTACIÓN

## Fase 1 — Fundamentos (Semanas 1–2)

| # | Tarea | Detalle |
|---|-------|---------|
| 1 | Setup del proyecto | `flutter create artstore --platforms android,ios,web,windows`, agregar dependencias, `flutterfire configure` |
| 2 | Sistema de diseño | Crear `app_colors.dart`, `app_theme.dart`, `app_text_styles.dart`. Construir widgets base: `ArtButton`, `ArtTextField`, `ArtCard` |
| 3 | Auth completo | `AuthService` + `AuthProvider` + `LoginScreen` + `RegisterScreen` + `ForgotPasswordScreen`. Guards de ruta con go_router |
| 4 | Estructura de carpetas | Crear todos los archivos vacíos con la estructura definida. Configurar `AppRouter` |

## Fase 2 — Catálogo y Pedidos (Semanas 3–4)

| # | Tarea | Detalle |
|---|-------|---------|
| 5 | Módulo de productos | `ProductoModel` + `ProductoService` + `ProductoProvider`. CRUD completo con subida de imágenes a Storage |
| 6 | Categorías y proveedores | `CategoriaModel`, `ProveedorModel` con sus services y providers. Dropdown jerárquico en formularios |
| 7 | Carrito | `CarritoProvider` completo con agregado, eliminado, cálculo de totales + IVA |
| 8 | Pedidos y checkout | `PedidoService.crearPedido()` en transacción atómica. `CheckoutScreen` que consume CarritoProvider |

## Fase 3 — Administración (Semanas 5–6)

| # | Tarea | Detalle |
|---|-------|---------|
| 9  | Clientes y empleados | CRUD completo. Asignación de custom claims de admin via Firebase Admin SDK |
| 10 | Inventario | `InventarioScreen` con lista de alertas de bajo stock. Gráfica de niveles con `fl_chart` en tonos café |
| 11 | Pagos y envíos | `PagoScreen` dentro del detalle del pedido. `EnvioScreen` con rastreo de estado y número de guía |

## Fase 4 — Pulido y Despliegue (Semanas 7–8)

| # | Tarea | Detalle |
|---|-------|---------|
| 12 | Responsive | `LayoutBuilder` para móvil vs tablet vs desktop. `NavigationRail` en pantallas >= 800px, `NavigationBar` en móvil |
| 13 | Testing | Unit tests para Providers y Services. Widget tests para formularios de auth y carrito |
| 14 | Build Android | `flutter build apk --release` → `flutter build appbundle --release` |
| 15 | Build iOS | `flutter build ios --release` → Xcode Archive → App Store Connect |
| 16 | Build Web | `flutter build web --release` → `firebase deploy --only hosting` |
| 17 | Build Windows | `flutter build windows --release` → empaquetar instalador con MSIX |

## Comandos Útiles de Referencia

```bash
# Crear proyecto
flutter create artstore --platforms android,ios,web,windows

# Instalar dependencias
flutter pub get

# Configurar Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# Ejecutar en diferentes plataformas
flutter run -d chrome          # Web
flutter run -d android         # Android
flutter run -d ios             # iOS  
flutter run -d windows         # Windows

# Builds de producción
flutter build apk --release
flutter build web --release
flutter build windows --release

# Firebase deploy
firebase deploy --only firestore:rules,firestore:indexes
firebase deploy --only hosting
```

---

*ArtStore — Plan de Implementación v1.0 | Flutter + Firebase + Firestore*
*Framework: Flutter 3.x / Dart 3.x | Estado: Provider | DB: Cloud Firestore*
ENDOFFILE

echo "Archivo creado exitosamente"
wc -l /mnt/user-data/outputs/artstore_plan_implementacion.md
Salida

Command argument is 101_127 bytes, exceeding the 100_000-byte per-argument limit. For large content, pipe via stdin or use a file-write API instead of embedding the content inline in the command. Argument preview: "cat > /mnt/user-data/outputs/artstore_plan_implementacion.md << 'ENDOFFILE'\n# ArtStore — Plan de Implementación Completo\n## Tienda de Suministros de Arte | Flutter + Firebase + Firestore\n\n---\n\n# ÍNDIC"

## Prompt
ahora con toda la informacion anteior, crearemos un plan de implementacion mejorado, donde juntaremos lo que me diste anterioremente, pero tambien necesito que agreguemos con las tablas que ya me has dado, las estructura de carpetas, modelos, colores de la app que me gustan que tengan tonalidades cafés creando un armonia con los colores de los productos y colores de fondo café de oscuros a claros , servivcios, provider, pantalllass, dependencia pubspec.yaml, y entidades. Framework: flutter dart. base de datos en la nube: console firebase, firestore, autenticacion por correo electronico y password. no usar analiticas, ni para produccion,.Estructura de carpetas y archivos dentro de la carpeta bin. aplicación para android/ web/IOS/windows diseño UI UX y establecer que colores vas a usar en primer plano( tonos cafés como te lo mencione anteriormente) las dependencias de pubspec.yaml agregar las tablas o entidades con su atributos. Utiliza provider cada paso detallado de manera completa por favor
