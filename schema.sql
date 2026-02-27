-- Supabase PostgreSQL Schema Script
-- Generated based on Isar Collections from inventario_v2

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: acceso_rol
CREATE TABLE public.acceso_rol (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rol_id TEXT NOT NULL,
  codigo_acceso TEXT NOT NULL,
  usuario_registro_id TEXT NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: bodega
CREATE TABLE public.bodega (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT NOT NULL,
  direccion TEXT,
  es_punto_venta BOOLEAN NOT NULL,
  usuario_registro_id TEXT NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: empresa
CREATE TABLE public.empresa (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  nombre_comercial TEXT,
  ruc TEXT,
  configuracion TEXT,
  estado BOOLEAN NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE,
  usuario_registro_id TEXT,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: rol
CREATE TABLE public.rol (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT NOT NULL,
  user_admin BOOLEAN NOT NULL,
  usuario_registro_id TEXT,
  fecha_registro TIMESTAMP WITH TIME ZONE,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: usuario
CREATE TABLE public.usuario (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  rol_id TEXT NOT NULL,
  nombre_completo TEXT NOT NULL,
  correo TEXT,
  password_hash TEXT,
  pin_offline TEXT,
  usuario_registro_id TEXT,
  fecha_registro TIMESTAMP WITH TIME ZONE,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: cargo_adicional
CREATE TABLE public.cargo_adicional (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT,
  valor NUMERIC NOT NULL,
  es_porcentaje BOOLEAN NOT NULL,
  aplicar_automatico BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: categoria
CREATE TABLE public.categoria (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT NOT NULL,
  categoria_padre_id TEXT,
  especificacion_json TEXT,
  usuario_registro_id TEXT NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: codigo_producto
CREATE TABLE public.codigo_producto (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producto_id TEXT NOT NULL,
  talla TEXT NOT NULL,
  color TEXT,
  codigo_sku TEXT NOT NULL,
  precio_especifico NUMERIC,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  usuario_registro_id TEXT NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: detalle_movimiento_producto
CREATE TABLE public.detalle_movimiento_producto (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  movimiento_producto_id TEXT NOT NULL,
  producto_id TEXT NOT NULL,
  cantidad NUMERIC NOT NULL,
  costo_proveedor NUMERIC NOT NULL,
  cargos_adicionales_json TEXT,
  costo_unitario_final NUMERIC NOT NULL,
  variantes_json TEXT,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: inventario_codigo_producto
CREATE TABLE public.inventario_codigo_producto (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inventario_id TEXT NOT NULL,
  codigo_producto_id TEXT NOT NULL,
  cantidad NUMERIC NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  usuario_registro_id TEXT NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: inventario
CREATE TABLE public.inventario (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bodega_id TEXT NOT NULL,
  producto_id TEXT NOT NULL,
  cantidad_actual NUMERIC NOT NULL,
  cantidad_reservada NUMERIC NOT NULL,
  ubicacion_pasillo TEXT,
  costo_promedio NUMERIC NOT NULL,
  actualizado_por TEXT,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: movimiento_producto
CREATE TABLE public.movimiento_producto (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  tipo_movimiento TEXT NOT NULL,
  bodega_origen_id TEXT,
  bodega_destino_id TEXT,
  estado_movimiento TEXT NOT NULL,
  descripcion TEXT,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  usuario_registro_id TEXT,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: producto
CREATE TABLE public.producto (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  categoria_id TEXT NOT NULL,
  codigo_personalizado TEXT,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  imagen_url TEXT,
  precio_base NUMERIC,
  especificacion_json TEXT,
  ultimo_costo NUMERIC NOT NULL,
  ultimo_precio_venta NUMERIC NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  usuario_registro_id TEXT NOT NULL,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  imagen_local TEXT,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: regla_costo
CREATE TABLE public.regla_costo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT,
  factor_redondeo NUMERIC NOT NULL,
  activo BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: caja
CREATE TABLE public.caja (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  bodega_id TEXT NOT NULL,
  nombre TEXT NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  usuario_registro_id TEXT,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: caja_movimiento_extra
CREATE TABLE public.caja_movimiento_extra (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caja_sesion_id TEXT NOT NULL,
  referencia_venta_id TEXT,
  tipo TEXT NOT NULL,
  motivo TEXT,
  monto NUMERIC NOT NULL,
  usuario_registro_id TEXT,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: caja_sesion
CREATE TABLE public.caja_sesion (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caja_id TEXT NOT NULL,
  usuario_apertura_id TEXT NOT NULL,
  usuario_cierre_id TEXT,
  fecha_apertura TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_cierre TIMESTAMP WITH TIME ZONE,
  monto_inicial NUMERIC NOT NULL,
  total_ventas_sistema NUMERIC NOT NULL,
  total_efectivo_real NUMERIC NOT NULL,
  diferencia NUMERIC NOT NULL,
  estado_sesion TEXT NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: cliente
CREATE TABLE public.cliente (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  nombre TEXT NOT NULL,
  identificacion TEXT,
  celular TEXT,
  direccion TEXT,
  monto_credito_maximo NUMERIC NOT NULL,
  saldo_deudor_actual NUMERIC NOT NULL,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  estado BOOLEAN NOT NULL,
  usuario_registro_id TEXT,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: detalle_venta
CREATE TABLE public.detalle_venta (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id TEXT NOT NULL,
  producto_id TEXT NOT NULL,
  cantidad NUMERIC NOT NULL,
  precio_unitario NUMERIC NOT NULL,
  descuento NUMERIC NOT NULL,
  sub_total NUMERIC NOT NULL,
  costo_historico_compra NUMERIC NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: historial_pago
CREATE TABLE public.historial_pago (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id TEXT NOT NULL,
  caja_sesion_id TEXT NOT NULL,
  monto_pagado NUMERIC NOT NULL,
  metodo_de_pago TEXT NOT NULL,
  referencia TEXT,
  fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL,
  usuario_registro_id TEXT,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

-- Table: venta
CREATE TABLE public.venta (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id TEXT NOT NULL,
  cliente_id TEXT NOT NULL,
  caja_sesion_id TEXT NOT NULL,
  tipo_venta TEXT NOT NULL,
  estado_pago TEXT NOT NULL,
  total_venta NUMERIC NOT NULL,
  total_pagado NUMERIC NOT NULL,
  saldo_pendiente NUMERIC NOT NULL,
  fecha_venta TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_vencimiento TIMESTAMP WITH TIME ZONE,
  usuario_registro_id TEXT,
  estado BOOLEAN NOT NULL,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL,
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  pendiente_sincronizacion BOOLEAN NOT NULL
);

