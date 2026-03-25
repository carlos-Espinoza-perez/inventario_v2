# Esquema de Base de Datos Supabase - Inventario V2

## Información General

Este documento describe el esquema de base de datos PostgreSQL en Supabase utilizado por el proyecto Inventario V2.

## Convenciones de Nomenclatura

### Tablas
- Nombres en snake_case
- Singular (ej: `producto`, no `productos`)
- Sin prefijos

### Columnas
- Nombres en snake_case
- IDs: `id` para PK, `{tabla}_id` para FKs
- Timestamps: `fecha_registro`, `ultima_actualizacion`, `fecha_eliminacion`
- Booleanos: `estado`, `pendiente_sincronizacion`

### Tipos de Datos
- IDs: `UUID` (generados con `gen_random_uuid()`)
- Texto: `TEXT` o `VARCHAR(n)`
- Números: `NUMERIC(10,2)` para dinero, `INTEGER` para cantidades
- Fechas: `TIMESTAMP WITH TIME ZONE`
- Booleanos: `BOOLEAN`
- JSON: `JSONB`

## Estructura de Tablas

### Nivel 0: Configuración y Entidades Raíz

#### empresa
```sql
CREATE TABLE empresa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  nombre_comercial TEXT,
  ruc VARCHAR(20) UNIQUE,
  direccion TEXT,
  telefono VARCHAR(20),
  email VARCHAR(100),
  logo_url TEXT,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### regla_costo
```sql
CREATE TABLE regla_costo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  formula_json JSONB,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### cargo_adicional
```sql
CREATE TABLE cargo_adicional (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  tipo TEXT, -- 'fijo' o 'porcentaje'
  valor NUMERIC(10,2),
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

### Nivel 1: Estructura Organizacional

#### rol
```sql
CREATE TABLE rol (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### acceso_rol
```sql
CREATE TABLE acceso_rol (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rol_id UUID NOT NULL REFERENCES rol(id),
  modulo TEXT NOT NULL,
  permiso TEXT NOT NULL,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### usuario
```sql
CREATE TABLE usuario (
  id UUID PRIMARY KEY, -- ID de Supabase Auth
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  rol_id UUID NOT NULL REFERENCES rol(id),
  nombre_completo TEXT NOT NULL,
  correo VARCHAR(100),
  password_hash TEXT,
  pin_offline VARCHAR(4),
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID,
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### bodega
```sql
CREATE TABLE bodega (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  direccion TEXT,
  telefono VARCHAR(20),
  tipo TEXT, -- 'principal', 'sucursal', 'almacen'
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### bodega_usuario
```sql
CREATE TABLE bodega_usuario (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bodega_id UUID NOT NULL REFERENCES bodega(id),
  usuario_id UUID NOT NULL REFERENCES usuario(id),
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(bodega_id, usuario_id)
);
```

#### categoria
```sql
CREATE TABLE categoria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  icono TEXT,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### cliente
```sql
CREATE TABLE cliente (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  nombre TEXT NOT NULL,
  ruc_dni VARCHAR(20),
  direccion TEXT,
  celular VARCHAR(20),
  email VARCHAR(100),
  saldo_deudor_actual NUMERIC(10,2) DEFAULT 0,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

### Nivel 2: Catálogo y Operaciones

#### producto
```sql
CREATE TABLE producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  categoria_id UUID NOT NULL REFERENCES categoria(id),
  codigo_personalizado VARCHAR(50),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  imagen_url TEXT,
  precio_base NUMERIC(10,2),
  especificacion JSONB,
  ultimo_costo NUMERIC(10,2) DEFAULT 0,
  ultimo_precio_venta NUMERIC(10,2) DEFAULT 0,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  registro_usuario_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_producto_nombre ON producto(nombre);
CREATE INDEX idx_producto_categoria ON producto(categoria_id);
```

#### codigo_producto
```sql
CREATE TABLE codigo_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id UUID NOT NULL REFERENCES producto(id),
  codigo_sku TEXT NOT NULL UNIQUE,
  talla TEXT,
  precio_especifico NUMERIC(10,2),
  costo_especifico NUMERIC(10,2),
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_codigo_producto_sku ON codigo_producto(codigo_sku);
```

#### caja
```sql
CREATE TABLE caja (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  bodega_id UUID REFERENCES bodega(id),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

### Nivel 3: Inventario y Transacciones

#### inventario_producto
```sql
CREATE TABLE inventario_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bodega_id UUID NOT NULL REFERENCES bodega(id),
  producto_id UUID NOT NULL REFERENCES producto(id),
  cantidad_actual NUMERIC(10,2) DEFAULT 0,
  cantidad_reservada NUMERIC(10,2) DEFAULT 0,
  ubicacion_pasillo TEXT,
  costo_promedio NUMERIC(10,2) DEFAULT 0,
  precio_venta NUMERIC(10,2),
  
  -- Auditoría
  actualizado_por UUID REFERENCES usuario(id),
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(bodega_id, producto_id)
);

CREATE INDEX idx_inventario_bodega ON inventario_producto(bodega_id);
CREATE INDEX idx_inventario_producto ON inventario_producto(producto_id);
```

#### inventario_codigo_producto
```sql
CREATE TABLE inventario_codigo_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inventario_id UUID NOT NULL REFERENCES inventario_producto(id),
  codigo_producto_id UUID NOT NULL REFERENCES codigo_producto(id),
  cantidad NUMERIC(10,2) DEFAULT 0,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(inventario_id, codigo_producto_id)
);
```

#### movimiento_producto
```sql
CREATE TABLE movimiento_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  tipo_movimiento TEXT NOT NULL, -- 'compra', 'traslado', 'ajuste', 'solicitud'
  bodega_origen_id UUID REFERENCES bodega(id),
  bodega_destino_id UUID REFERENCES bodega(id),
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  estado_movimiento TEXT DEFAULT 'pendiente', -- 'pendiente', 'aprobado', 'rechazado'
  descripcion TEXT,
  
  -- Auditoría
  usuario_registro_id UUID REFERENCES usuario(id),
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_movimiento_bodega_origen ON movimiento_producto(bodega_origen_id);
CREATE INDEX idx_movimiento_bodega_destino ON movimiento_producto(bodega_destino_id);
```

#### detalle_movimiento_producto
```sql
CREATE TABLE detalle_movimiento_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movimiento_producto_id UUID NOT NULL REFERENCES movimiento_producto(id),
  producto_id UUID NOT NULL REFERENCES producto(id),
  cantidad NUMERIC(10,2) NOT NULL,
  costo_unitario_final NUMERIC(10,2),
  costo_proveedor NUMERIC(10,2),
  variantes_json JSONB,
  
  -- Auditoría
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### caja_sesion
```sql
CREATE TABLE caja_sesion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id UUID NOT NULL REFERENCES caja(id),
  usuario_id UUID NOT NULL REFERENCES usuario(id),
  fecha_apertura TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_cierre TIMESTAMP WITH TIME ZONE,
  monto_inicial NUMERIC(10,2) DEFAULT 0,
  monto_final NUMERIC(10,2),
  estado_sesion TEXT DEFAULT 'abierta', -- 'abierta', 'cerrada', 'arqueada'
  
  -- Auditoría
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

### Nivel 4: Ventas

#### venta_producto
```sql
CREATE TABLE venta_producto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL REFERENCES empresa(id),
  cliente_id UUID NOT NULL REFERENCES cliente(id),
  caja_sesion_id UUID NOT NULL REFERENCES caja_sesion(id),
  tipo_venta TEXT NOT NULL, -- 'contado', 'credito'
  estado_pago TEXT NOT NULL, -- 'pagado', 'pendiente', 'parcial', 'anulado'
  total_venta NUMERIC(10,2) NOT NULL,
  total_pagado NUMERIC(10,2) DEFAULT 0,
  saldo_pendiente NUMERIC(10,2) DEFAULT 0,
  fecha_venta TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_vencimiento TIMESTAMP WITH TIME ZONE,
  
  -- Auditoría
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_venta_cliente ON venta_producto(cliente_id);
CREATE INDEX idx_venta_sesion ON venta_producto(caja_sesion_id);
```

#### detalle_venta
```sql
CREATE TABLE detalle_venta (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venta_id UUID NOT NULL REFERENCES venta_producto(id),
  producto_id UUID NOT NULL REFERENCES producto(id),
  cantidad NUMERIC(10,2) NOT NULL,
  precio_unitario NUMERIC(10,2) NOT NULL,
  sub_total NUMERIC(10,2) NOT NULL,
  descuento NUMERIC(10,2) DEFAULT 0,
  costo_historico_compra NUMERIC(10,2),
  
  -- Auditoría
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### historial_pago
```sql
CREATE TABLE historial_pago (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  venta_id UUID NOT NULL REFERENCES venta_producto(id),
  caja_sesion_id UUID NOT NULL REFERENCES caja_sesion(id),
  monto_pagado NUMERIC(10,2) NOT NULL,
  metodo_de_pago TEXT NOT NULL, -- 'efectivo', 'tarjeta', 'transferencia'
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  estado BOOLEAN DEFAULT TRUE,
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

#### caja_movimiento_extra
```sql
CREATE TABLE caja_movimiento_extra (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_sesion_id UUID NOT NULL REFERENCES caja_sesion(id),
  tipo_movimiento TEXT NOT NULL, -- 'ingreso', 'egreso'
  monto NUMERIC(10,2) NOT NULL,
  concepto TEXT NOT NULL,
  descripcion TEXT,
  
  -- Auditoría
  fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  usuario_registro_id UUID REFERENCES usuario(id),
  ultima_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_eliminacion TIMESTAMP WITH TIME ZONE
);
```

## Funciones y Triggers

### Función: crear_empresa_inicial
```sql
CREATE OR REPLACE FUNCTION crear_empresa_inicial(
  p_nombre_empresa TEXT,
  p_ruc_empresa TEXT,
  p_user_id UUID,
  p_user_email TEXT,
  p_user_nombre TEXT,
  p_user_password TEXT
) RETURNS JSONB AS $$
DECLARE
  v_empresa_id UUID;
  v_rol_id UUID;
  v_result JSONB;
BEGIN
  -- Crear empresa
  INSERT INTO empresa (nombre, ruc)
  VALUES (p_nombre_empresa, p_ruc_empresa)
  RETURNING id INTO v_empresa_id;
  
  -- Crear rol admin
  INSERT INTO rol (empresa_id, nombre, descripcion)
  VALUES (v_empresa_id, 'Administrador', 'Rol con todos los permisos')
  RETURNING id INTO v_rol_id;
  
  -- Crear usuario
  INSERT INTO usuario (
    id, empresa_id, rol_id, nombre_completo, 
    correo, password_hash
  )
  VALUES (
    p_user_id, v_empresa_id, v_rol_id, p_user_nombre,
    p_user_email, p_user_password
  );
  
  -- Retornar datos
  SELECT jsonb_build_object(
    'empresa', row_to_json(e.*),
    'rol', row_to_json(r.*),
    'usuario', row_to_json(u.*)
  ) INTO v_result
  FROM empresa e, rol r, usuario u
  WHERE e.id = v_empresa_id
    AND r.id = v_rol_id
    AND u.id = p_user_id;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;
```

### Trigger: actualizar_timestamp
```sql
CREATE OR REPLACE FUNCTION actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.ultima_actualizacion = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a todas las tablas
CREATE TRIGGER trigger_actualizar_timestamp
BEFORE UPDATE ON empresa
FOR EACH ROW EXECUTE FUNCTION actualizar_timestamp();

-- Repetir para cada tabla...
```

## Políticas de Seguridad (RLS)

### Habilitar RLS
```sql
ALTER TABLE empresa ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuario ENABLE ROW LEVEL SECURITY;
-- ... para todas las tablas
```

### Políticas de Ejemplo
```sql
-- Usuarios solo ven datos de su empresa
CREATE POLICY empresa_isolation ON producto
  USING (empresa_id = (
    SELECT empresa_id FROM usuario WHERE id = auth.uid()
  ));

-- Usuarios solo ven su propia información
CREATE POLICY usuario_self ON usuario
  USING (id = auth.uid());
```

## Índices Adicionales Recomendados

```sql
-- Búsqueda de texto
CREATE INDEX idx_producto_nombre_trgm ON producto 
  USING gin(nombre gin_trgm_ops);

-- Fechas para reportes
CREATE INDEX idx_venta_fecha ON venta_producto(fecha_venta);
CREATE INDEX idx_movimiento_fecha ON movimiento_producto(fecha_registro);

-- Compuestos para consultas frecuentes
CREATE INDEX idx_inventario_bodega_producto 
  ON inventario_producto(bodega_id, producto_id);
```

## Mantenimiento

### Vacuum y Analyze
```sql
-- Ejecutar periódicamente
VACUUM ANALYZE;
```

### Backup
```bash
# Backup completo
pg_dump -h db.supabase.co -U postgres -d postgres > backup.sql

# Restore
psql -h db.supabase.co -U postgres -d postgres < backup.sql
```

## Notas Importantes

1. **UUIDs:** Todos los IDs son UUIDs para evitar colisiones en sincronización offline
2. **Soft Deletes:** Usar `estado = false` y `fecha_eliminacion` en lugar de DELETE
3. **Timestamps:** Siempre con timezone para consistencia global
4. **JSONB:** Para datos flexibles (especificaciones, variantes)
5. **Índices:** Crear según patrones de consulta reales
6. **RLS:** Habilitar para seguridad multi-tenant
