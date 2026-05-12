-- Script de creación de la Base de Datos ArtStore
-- Generado para la gestión de suministros de arte

CREATE DATABASE IF NOT EXISTS ArtStore;
USE ArtStore;

-- 1. Tabla: CATEGORIA
-- Soporta jerarquía (ej. Pinturas -> Acrílicos)
CREATE TABLE CATEGORIA (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    descripcion TEXT,
    categoria_padre_id INT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (categoria_padre_id) REFERENCES CATEGORIA(categoria_id)
);

-- 2. Tabla: PROVEEDOR
CREATE TABLE PROVEEDOR (
    proveedor_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    contacto VARCHAR(100),
    email VARCHAR(150),
    telefono VARCHAR(20),
    pais VARCHAR(60),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. Tabla: PRODUCTO
CREATE TABLE PRODUCTO (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT,
    proveedor_id INT,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    codigo_barras VARCHAR(50),
    precio DECIMAL(10,2) NOT NULL,
    unidad_medida VARCHAR(30) NOT NULL, -- ml, pieza, kg, set
    imagen_url VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES CATEGORIA(categoria_id),
    FOREIGN KEY (proveedor_id) REFERENCES PROVEEDOR(proveedor_id)
);

-- 4. Tabla: CLIENTE
CREATE TABLE CLIENTE (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(80),
    pais VARCHAR(60),
    fecha_registro DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 5. Tabla: EMPLEADO
CREATE TABLE EMPLEADO (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    puesto VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_contrato DATE NOT NULL,
    salario DECIMAL(10,2),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 6. Tabla: PEDIDO
CREATE TABLE PEDIDO (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    empleado_id INT,
    fecha_pedido DATETIME NOT NULL,
    estado ENUM('pendiente', 'confirmado', 'enviado', 'entregado', 'cancelado') NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    impuesto DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    notas TEXT,
    FOREIGN KEY (cliente_id) REFERENCES CLIENTE(cliente_id),
    FOREIGN KEY (empleado_id) REFERENCES EMPLEADO(empleado_id)
);

-- 7. Tabla: DETALLE_PEDIDO
-- Tabla puente que guarda el histórico de precios
CREATE TABLE DETALLE_PEDIDO (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL, -- Precio al momento de la compra
    descuento DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    subtotal_linea DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES PEDIDO(pedido_id),
    FOREIGN KEY (producto_id) REFERENCES PRODUCTO(producto_id)
);

-- 8. Tabla: PAGO
CREATE TABLE PAGO (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    metodo ENUM('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'paypal') NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME NOT NULL,
    referencia VARCHAR(100),
    estado ENUM('pendiente', 'procesado', 'fallido', 'reembolsado') NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES PEDIDO(pedido_id)
);

-- 9. Tabla: ENVIO
CREATE TABLE ENVIO (
    envio_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT,
    transportista VARCHAR(80) NOT NULL,
    numero_guia VARCHAR(80),
    direccion_destino TEXT NOT NULL,
    fecha_envio DATE,
    fecha_entrega DATE,
    estado ENUM('pendiente', 'en_transito', 'entregado', 'devuelto') NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES PEDIDO(pedido_id)
);

-- 10. Tabla: INVENTARIO
CREATE TABLE INVENTARIO (
    inventario_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    stock_maximo INT,
    ubicacion VARCHAR(60), -- Pasillo / Estante
    ultima_actualizacion DATETIME NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES PRODUCTO(producto_id)
);
