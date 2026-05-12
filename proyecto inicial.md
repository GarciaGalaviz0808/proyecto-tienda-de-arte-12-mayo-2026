Como administrador de base de datos, aquí está el análisis completo de entidades para el sistema **ArtStore**:Aquí está el resumen de las **10 entidades principales** y su justificación:
<img width="1180" height="559" alt="image" src="https://github.com/user-attachments/assets/2c6456d4-65b2-442d-9cc7-73244bdf9d9d" />

---

**Núcleo comercial**

- `CLIENTE` — persona que compra. Necesitamos historial, contacto y dirección para envíos y fidelización.
- `PEDIDO` — transacción central del negocio. Conecta cliente, empleado, pago y envío.
- `DETALLE_PEDIDO` — tabla puente entre pedido y producto. Almacena cantidad, precio y descuento aplicado en el momento de la venta (no el precio actual del producto).
- `PAGO` — separado del pedido para soportar múltiples métodos (tarjeta, transferencia, efectivo) y pagos parciales.

**Catálogo y logística**

- `PRODUCTO` — unidad de venta. Incluye código de barras, precio y unidad de medida (ml, piezas, kg) relevante para suministros de arte.
- `CATEGORIA` — jerárquica (ej. *Pinturas → Acrílicos → Marcas premium*). El campo `categoria_padre_id` permite árbol de categorías.
- `PROVEEDOR` — quién surte los productos. Permite rastrear origen y contactar ante faltantes.
- `INVENTARIO` — control de stock por producto con alertas de mínimo. Separado de `PRODUCTO` para no mezclar datos de catálogo con operación.
- `ENVIO` — seguimiento de entrega con número de guía y transportista.

**Operación interna**

- `EMPLEADO` — quién gestiona cada pedido. Base para comisiones, rendimiento y auditoría.

---

**Entidades opcionales a considerar según el crecimiento del negocio:** tabla de `DESCUENTO`/`PROMO` (cupones o rebajas por temporada), `RESEÑA` (calificaciones de productos), `LISTA_DESEOS`, y `SUCURSAL` si hay múltiples puntos de venta.

¿Quieres que profundice en alguna entidad, defina los tipos de datos exactos, o genere el script SQL de creación?
