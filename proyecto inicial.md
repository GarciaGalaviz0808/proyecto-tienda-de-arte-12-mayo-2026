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
<img width="764" height="375" alt="image" src="https://github.com/user-attachments/assets/3c77dbd5-5839-4793-aefd-a1ed5b8a8d4f" />
<img width="773" height="394" alt="image" src="https://github.com/user-attachments/assets/ca2e4d6f-701a-49f4-9c60-843c52b31426" />
<img width="765" height="342" alt="image" src="https://github.com/user-attachments/assets/aba1ac3b-e946-4dd6-a872-7ff380c9d637" />
<img width="761" height="354" alt="image" src="https://github.com/user-attachments/assets/773fc22d-910d-4e96-910f-c3f16504cd5b" />
<img width="717" height="416" alt="image" src="https://github.com/user-attachments/assets/ea20e2cb-22d2-4c48-a3cb-425787b20674" />
<img width="762" height="351" alt="image" src="https://github.com/user-attachments/assets/402c8e42-639d-4842-b453-c576bd1a5c1f" />
<img width="772" height="423" alt="image" src="https://github.com/user-attachments/assets/00477a84-792b-4d0f-8aaf-726bc10aa37b" />
<img width="765" height="417" alt="image" src="https://github.com/user-attachments/assets/9f7250cc-89f0-4bd3-af81-249f178ea6c5" />
