-- =================================================================
-- FIX 1: Agregar valores MAYÚSCULAS a los enums en Supabase
--
-- El toJson() de los mappers Dart envía los valores en MAYÚSCULAS:
--   'APROBADO', 'PENDIENTE', 'RECHAZADO'
--   'COMPRA', 'TRASLADO', 'AJUSTE', 'SOLICITUD'
--
-- Pero los enums en Supabase solo tenían los valores en minúsculas.
-- La solución es agregar los valores UPPERCASE a cada enum.
-- =================================================================

-- ── estado_movimiento_enum ───────────────────────────────────────
ALTER TYPE estado_movimiento_enum ADD VALUE IF NOT EXISTS 'PENDIENTE';
ALTER TYPE estado_movimiento_enum ADD VALUE IF NOT EXISTS 'APROBADO';
ALTER TYPE estado_movimiento_enum ADD VALUE IF NOT EXISTS 'RECHAZADO';

-- ── tipo_movimiento_enum ─────────────────────────────────────────
ALTER TYPE tipo_movimiento_enum ADD VALUE IF NOT EXISTS 'COMPRA';
ALTER TYPE tipo_movimiento_enum ADD VALUE IF NOT EXISTS 'TRASLADO';
ALTER TYPE tipo_movimiento_enum ADD VALUE IF NOT EXISTS 'AJUSTE';
ALTER TYPE tipo_movimiento_enum ADD VALUE IF NOT EXISTS 'SOLICITUD';

-- (Por si hay otros enums usados por otros mappers)
-- ── tipo_venta_enum ──────────────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_venta_enum') THEN
    ALTER TYPE tipo_venta_enum ADD VALUE IF NOT EXISTS 'CONTADO';
    ALTER TYPE tipo_venta_enum ADD VALUE IF NOT EXISTS 'CREDITO';
  END IF;
END $$;

-- ── estado_pago_enum ─────────────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'estado_pago_enum') THEN
    ALTER TYPE estado_pago_enum ADD VALUE IF NOT EXISTS 'PAGADO';
    ALTER TYPE estado_pago_enum ADD VALUE IF NOT EXISTS 'PENDIENTE';
    ALTER TYPE estado_pago_enum ADD VALUE IF NOT EXISTS 'PARCIAL';
    ALTER TYPE estado_pago_enum ADD VALUE IF NOT EXISTS 'ANULADO';
  END IF;
END $$;

-- ── metodo_pago_enum ─────────────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'metodo_pago_enum') THEN
    ALTER TYPE metodo_pago_enum ADD VALUE IF NOT EXISTS 'EFECTIVO';
    ALTER TYPE metodo_pago_enum ADD VALUE IF NOT EXISTS 'TARJETA';
    ALTER TYPE metodo_pago_enum ADD VALUE IF NOT EXISTS 'TRANSFERENCIA';
  END IF;
END $$;

-- ── estado_sesion_enum ───────────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'estado_sesion_enum') THEN
    ALTER TYPE estado_sesion_enum ADD VALUE IF NOT EXISTS 'ABIERTA';
    ALTER TYPE estado_sesion_enum ADD VALUE IF NOT EXISTS 'CERRADA';
    ALTER TYPE estado_sesion_enum ADD VALUE IF NOT EXISTS 'ARQUEADA';
  END IF;
END $$;

-- ── tipo_movimiento_caja_enum ────────────────────────────────────
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_movimiento_caja_enum') THEN
    ALTER TYPE tipo_movimiento_caja_enum ADD VALUE IF NOT EXISTS 'INGRESO';
    ALTER TYPE tipo_movimiento_caja_enum ADD VALUE IF NOT EXISTS 'EGRESO';
  END IF;
END $$;


-- =================================================================
-- FIX 2: Crear tabla codigo_producto (si no existe)
--
-- Mapper: CodigoProductoCollection.toJson()
-- Campos: id, producto_id, talla, color, codigo_sku,
--         precio_especifico, costo_especifico,
--         usuario_registro_id, fecha_registro, estado,
--         ultima_actualizacion, fecha_eliminacion
-- =================================================================

CREATE TABLE IF NOT EXISTS public.codigo_producto (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id          UUID NOT NULL REFERENCES public.producto(id) ON DELETE CASCADE,
    talla                TEXT NOT NULL,
    color                TEXT,
    codigo_sku           TEXT UNIQUE NOT NULL,
    precio_especifico    NUMERIC(15, 2),
    costo_especifico     NUMERIC(15, 2),

    -- Auditoría
    usuario_registro_id  UUID REFERENCES public.usuario(id),
    fecha_registro       TIMESTAMPTZ DEFAULT now(),
    estado               BOOLEAN DEFAULT true,
    ultima_actualizacion TIMESTAMPTZ DEFAULT now(),
    fecha_eliminacion    TIMESTAMPTZ
);

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_codigo_producto_producto_id
    ON public.codigo_producto(producto_id);
CREATE INDEX IF NOT EXISTS idx_codigo_producto_sku
    ON public.codigo_producto(codigo_sku);

-- RLS
ALTER TABLE public.codigo_producto ENABLE ROW LEVEL SECURITY;

-- Política: Solo puede ver/modificar registros de su propia empresa
-- (a través de la relación con producto)
DROP POLICY IF EXISTS rls_codigo_producto ON public.codigo_producto;
CREATE POLICY rls_codigo_producto ON public.codigo_producto
    USING (
        producto_id IN (
            SELECT id FROM public.producto
            WHERE empresa_id = get_mi_empresa_id()
        )
    );


-- =================================================================
-- FIX 3: Crear tabla inventario_codigo_producto (si no existe)
--
-- Propósito: Stock individual por SKU/talla en cada bodega
-- Mapper: InventarioCodigoProductoCollection (si existe) o
--         se crea para futura sincronización
-- =================================================================

CREATE TABLE IF NOT EXISTS public.inventario_codigo_producto (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bodega_id            UUID NOT NULL REFERENCES public.bodega(id) ON DELETE CASCADE,
    codigo_producto_id   UUID NOT NULL REFERENCES public.codigo_producto(id) ON DELETE CASCADE,
    cantidad_actual      NUMERIC(15, 4) DEFAULT 0,
    cantidad_reservada   NUMERIC(15, 4) DEFAULT 0,
    ultima_actualizacion TIMESTAMPTZ DEFAULT now(),
    fecha_eliminacion    TIMESTAMPTZ,

    CONSTRAINT unique_inv_codigo UNIQUE (bodega_id, codigo_producto_id)
);

CREATE INDEX IF NOT EXISTS idx_inv_codigo_producto_bodega
    ON public.inventario_codigo_producto(bodega_id);
CREATE INDEX IF NOT EXISTS idx_inv_codigo_producto_codigo
    ON public.inventario_codigo_producto(codigo_producto_id);

-- RLS
ALTER TABLE public.inventario_codigo_producto ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_inventario_codigo_producto ON public.inventario_codigo_producto;
CREATE POLICY rls_inventario_codigo_producto ON public.inventario_codigo_producto
    USING (
        bodega_id IN (
            SELECT id FROM public.bodega
            WHERE empresa_id = get_mi_empresa_id()
        )
    );


-- =================================================================
-- FIX 4: Agregar tablas nuevas a la publicación de Realtime
-- =================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.codigo_producto;
ALTER PUBLICATION supabase_realtime ADD TABLE public.inventario_codigo_producto;


-- =================================================================
-- VERIFICACIÓN (opcional – ejecuta para confirmar)
-- =================================================================
SELECT enumlabel FROM pg_enum
WHERE enumtypid = 'estado_movimiento_enum'::regtype
ORDER BY enumsortorder;
