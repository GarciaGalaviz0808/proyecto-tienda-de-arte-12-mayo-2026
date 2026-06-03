# 🗃️ Database Mapping — Eli's Art Supplies

## Estrategia General SQL → Firestore

| Principio | Descripción |
|---|---|
| **Embedding** | Datos frecuentemente leídos juntos se guardan en el mismo documento |
| **Denormalización** | Campos como `categoryName`, `brandName` se duplican en `products` |
| **Snapshots** | `orders.items` almacena nombre, precio y marca en el momento de compra (inmutable) |
| **Subcolecciones** | `reviews` y `loyalty_transactions` usan subcolecciones para paginación independiente |
| **Singletons** | `loyalty_rules` y `settings` son documentos únicos (`doc_id: 'global'`) |
| **Transacciones** | Stock y puntos siempre se modifican con `Firestore.runTransaction()` |

---

## Colecciones y Estructura de Documentos

### `categories`
```json
{
  "cat_id": "string (auto-ID)",
  "name": "string",
  "slug": "string (único)",
  "iconUrl": "string (SVG URL)",
  "description": "string",
  "displayOrder": "number",
  "isActive": "boolean"
}
```
**Índices**: `slug` (único), `displayOrder ASC`, `isActive`

---

### `brands`
```json
{
  "brand_id": "string (auto-ID)",
  "name": "string",
  "logoUrl": "string",
  "country": "string",
  "description": "string",
  "isActive": "boolean"
}
```
**Índices**: `name ASC`, `country`, `isActive`

---

### `products`
```json
{
  "prod_id": "string (auto-ID)",
  "name": "string",
  "description": "string",
  "categoryId": "string (ref → categories)",
  "categoryName": "string (denormalizado)",
  "brandId": "string (ref → brands)",
  "brandName": "string (denormalizado)",
  "technique": "string (ej: óleo, acuarela, dibujo)",
  "skillLevel": "string (principiante | intermedio | profesional)",
  "price": "number",
  "discountPrice": "number | null",
  "stock": "number",
  "sku": "string (único)",
  "images": ["string (URLs)"],
  "dimensions": "string",
  "weight": "string",
  "materials": "string",
  "rating": "number (0-5)",
  "reviewCount": "number",
  "isFeatured": "boolean",
  "isActive": "boolean",
  "status": "string (active | inactive | offer | limited | new | sold_out)",
  "createdAt": "Timestamp"
}
```
**Índices compuestos**:
- `categoryId + stock > 0 + isActive`
- `technique + skillLevel + isActive`
- `price ASC/DESC + isActive`
- `brandId + isActive`
- `isFeatured + isActive`
- `discountPrice != null + isActive` (para ofertas flash)

---

### `users`
```json
{
  "uid": "string (Firebase Auth UID)",
  "email": "string (único)",
  "username": "string",
  "role": "string (customer | admin | superadmin)",
  "phone": "string | null",
  "photoUrl": "string | null",
  "favoriteTechnique": "string | null",
  "loyaltyPoints": "number",
  "loyaltyLevel": "string (Bronce | Plata | Oro | Platino)",
  "wishlist": ["string (prodIds)"],
  "createdAt": "Timestamp",
  "lastLogin": "Timestamp"
}
```
**Índices**: `email` (único), `role`, `loyaltyLevel`, `loyaltyPoints DESC`

---

### `addresses`
```json
{
  "addr_id": "string (auto-ID)",
  "userId": "string (ref → users)",
  "street": "string",
  "city": "string",
  "state": "string",
  "country": "string",
  "postalCode": "string",
  "phone": "string",
  "isDefault": "boolean"
}
```
**Índices**: `userId`, `userId + isDefault`

---

### `carts`
```json
{
  "cart_id": "string (= userId para carrito activo)",
  "userId": "string",
  "items": [
    {
      "prodId": "string",
      "nameSnapshot": "string",
      "priceSnapshot": "number",
      "brandSnapshot": "string",
      "imageUrl": "string",
      "quantity": "number"
    }
  ],
  "appliedCoupon": "string | null",
  "discountAmount": "number",
  "total": "number",
  "updatedAt": "Timestamp"
}
```
**Índices**: `userId` (único — 1 carrito activo por usuario), `updatedAt DESC`

---

### `orders`
```json
{
  "order_id": "string (auto-ID)",
  "userId": "string",
  "items": [
    {
      "prodId": "string",
      "name": "string (snapshot)",
      "priceUnit": "number (snapshot)",
      "brand": "string (snapshot)",
      "imageUrl": "string (snapshot)",
      "quantity": "number"
    }
  ],
  "subtotal": "number",
  "discountApplied": {
    "couponCode": "string | null",
    "amount": "number"
  },
  "shippingCost": "number",
  "total": "number",
  "loyaltyPointsEarned": "number",
  "status": "string (pending | processing | shipped | delivered | cancelled)",
  "paymentMethod": "string (cash | card | paypal)",
  "shippingAddress": {
    "street": "string",
    "city": "string",
    "state": "string",
    "country": "string",
    "postalCode": "string",
    "phone": "string"
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```
**Índices compuestos**:
- `userId + createdAt DESC`
- `status + createdAt DESC`
- `userId + status`

---

### `coupons`
```json
{
  "code": "string (ID del documento = código del cupón)",
  "type": "string (percentage | fixed)",
  "value": "number",
  "minPurchase": "number",
  "maxUses": "number",
  "usedCount": "number",
  "expiresAt": "Timestamp",
  "applicableCategories": ["string (catIds) | null"],
  "applicableBrands": ["string (brandIds) | null"],
  "isActive": "boolean",
  "createdAt": "Timestamp"
}
```
**Índices**: `isActive + expiresAt`, `code` (ID único)

---

### `loyalty_rules` (singleton)
```json
{
  "doc_id": "global",
  "pointsPerAmount": "number (ej: 1 punto por cada $10)",
  "amountDivisor": "number (ej: 10)",
  "levelThresholds": [
    {"level": "Bronce",  "minPoints": 0,    "benefit": "5% descuento en siguiente compra"},
    {"level": "Plata",   "minPoints": 500,  "benefit": "10% descuento + envío gratis"},
    {"level": "Oro",     "minPoints": 1500, "benefit": "15% descuento + acceso anticipado"},
    {"level": "Platino", "minPoints": 3000, "benefit": "20% descuento + kit sorpresa trimestral"}
  ],
  "redeemableRewards": [
    {
      "rewardId": "string",
      "name": "string",
      "pointsCost": "number",
      "type": "string (discount | free_product | free_shipping)",
      "value": "number | string"
    }
  ],
  "updatedAt": "Timestamp"
}
```

---

### `loyalty_transactions` (subcolección de `users`)
Ruta: `users/{uid}/loyalty_transactions/{tx_id}`
```json
{
  "tx_id": "string (auto-ID)",
  "type": "string (earned | redeemed)",
  "points": "number",
  "orderId": "string | null",
  "rewardId": "string | null",
  "description": "string",
  "createdAt": "Timestamp"
}
```
**Índices**: `createdAt DESC`, `type`

---

### `reviews` (subcolección de `products`)
Ruta: `products/{prodId}/reviews/{review_id}`
```json
{
  "review_id": "string (auto-ID)",
  "userId": "string",
  "username": "string",
  "userLevel": "string (nivel de fidelidad)",
  "rating": "number (1-5)",
  "comment": "string",
  "images": ["string (URLs) | null"],
  "verifiedPurchase": "boolean",
  "isAdminResponse": "boolean",
  "createdAt": "Timestamp"
}
```
**Índices**: `createdAt DESC`, `rating`, `verifiedPurchase`

---

### `banners`
```json
{
  "banner_id": "string (auto-ID)",
  "imageUrl": "string",
  "redirectUrl": "string",
  "startDate": "Timestamp",
  "endDate": "Timestamp",
  "displayOrder": "number",
  "isActive": "boolean",
  "targetAudience": "string | null (all | customer | loyalty_gold)"
}
```
**Índices**: `isActive + startDate`, `displayOrder ASC`

---

### `admin_permissions`
```json
{
  "adminId": "string (= uid del admin)",
  "permissions": [
    {
      "collection": "string (ej: products, orders, coupons)",
      "actions": ["read", "write", "delete"]
    }
  ],
  "grantedBy": "string (uid del superadmin)",
  "grantedAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```
**Índices**: `adminId` (único)

---

### `inventory_movements`
```json
{
  "move_id": "string (auto-ID)",
  "prodId": "string",
  "type": "string (sale | restock | adjustment)",
  "quantity": "number (negativo para salidas)",
  "reason": "string",
  "adminId": "string | null",
  "orderId": "string | null",
  "createdAt": "Timestamp"
}
```
**Índices**: `prodId + createdAt DESC`, `type`, `adminId`

---

### `settings` (singleton)
```json
{
  "doc_id": "global",
  "currency": "string (ej: MXN)",
  "currencySymbol": "string (ej: $)",
  "taxRate": "number (ej: 0.16)",
  "shippingBaseCost": "number",
  "freeShippingThreshold": "number",
  "supportEmail": "string",
  "maintenanceMode": "boolean",
  "updatedAt": "Timestamp"
}
```

---

## Reglas de Seguridad Firestore (Iniciales)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Funciones auxiliares
    function isAuthenticated() {
      return request.auth != null;
    }
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    function isCustomer() {
      return isAuthenticated() && getUserRole() == 'customer';
    }
    function isAdmin() {
      return isAuthenticated() && (getUserRole() == 'admin' || getUserRole() == 'superadmin');
    }
    function isSuperAdmin() {
      return isAuthenticated() && getUserRole() == 'superadmin';
    }

    // users
    match /users/{uid} {
      allow read: if isAuthenticated() && (request.auth.uid == uid || isAdmin());
      allow create: if isAuthenticated() && request.auth.uid == uid;
      allow update: if isAuthenticated() && (request.auth.uid == uid || isAdmin());
      allow delete: if isSuperAdmin();
    }

    // products
    match /products/{prodId} {
      allow read: if true;
      allow write: if isAdmin();

      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if isCustomer();
        allow update, delete: if isAdmin();
      }
    }

    // categories
    match /categories/{catId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // brands
    match /brands/{brandId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // carts
    match /carts/{cartId} {
      allow read, write: if isAuthenticated() && request.auth.uid == cartId;
    }

    // orders
    match /orders/{orderId} {
      allow create: if isCustomer();
      allow read: if isAuthenticated() &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // coupons
    match /coupons/{code} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    // loyalty_rules
    match /loyalty_rules/global {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // loyalty_transactions (subcolección de users)
    match /users/{uid}/loyalty_transactions/{txId} {
      allow read: if isAuthenticated() && request.auth.uid == uid;
      allow write: if isAuthenticated() && request.auth.uid == uid;
    }

    // banners
    match /banners/{bannerId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // admin_permissions
    match /admin_permissions/{adminId} {
      allow read: if isAdmin() && (request.auth.uid == adminId || isSuperAdmin());
      allow write: if isSuperAdmin();
    }

    // inventory_movements
    match /inventory_movements/{moveId} {
      allow read: if isAdmin();
      allow create: if isAdmin();
      allow update, delete: if isSuperAdmin();
    }

    // settings
    match /settings/global {
      allow read: if isAuthenticated();
      allow write: if isSuperAdmin();
    }

    // addresses
    match /addresses/{addrId} {
      allow read, write: if isAuthenticated() &&
        (resource.data.userId == request.auth.uid || isAdmin());
    }
  }
}
```

---

## Transacciones Atómicas Críticas

### Confirmar Pedido (Checkout)
```
Firestore.runTransaction():
  1. Leer stock de cada products/{prodId}
  2. Verificar: stock >= quantity solicitada (abortar si falla)
  3. Decrementar stock en products/{prodId}.stock
  4. Crear documento en orders/{auto-id}
  5. Crear registros en inventory_movements por cada item (type: 'sale')
  6. Vaciar carts/{userId}.items
  7. Calcular puntos: floor(total / amountDivisor) * pointsPerAmount
  8. Incrementar users/{uid}.loyaltyPoints
  9. Actualizar users/{uid}.loyaltyLevel según thresholds
  10. Crear loyalty_transactions/{auto-id} con type: 'earned'
  11. Si cupón usado: incrementar coupons/{code}.usedCount
```

### Canjear Recompensa de Fidelidad
```
Firestore.runTransaction():
  1. Leer users/{uid}.loyaltyPoints
  2. Verificar: loyaltyPoints >= rewardPointsCost (abortar si falla)
  3. Decrementar users/{uid}.loyaltyPoints
  4. Actualizar users/{uid}.loyaltyLevel según thresholds
  5. Crear loyalty_transactions/{auto-id} con type: 'redeemed'
  6. Aplicar recompensa según tipo (discount | free_product | free_shipping)
```

---

## Estrategias NoSQL — Resumen

| Estrategia | Aplicación en el Proyecto |
|---|---|
| **Embedding** | `orders.items` con snapshots inmutables de precio/nombre/marca |
| **Subcolecciones** | `reviews` y `loyalty_transactions` para paginación independiente |
| **Denormalización ligera** | `products.categoryName` y `products.brandName` para evitar joins en catálogo |
| **Arrays con `array-contains`** | `users.wishlist` para consultas rápidas de favoritos |
| **Índices compuestos** | `products` por (categoryId + technique + stock > 0); `orders` por (userId + status + createdAt DESC) |
| **Cache local** | Categorías, marcas, `loyalty_rules` y `settings` se cachean para reducir lecturas |
| **Batch update** | Al renombrar categoría/marca, propagar cambio a todos los `products` afectados |
