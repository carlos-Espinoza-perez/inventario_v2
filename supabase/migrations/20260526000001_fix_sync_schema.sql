-- Migración: Alinear esquema remoto con modelo local para corregir fallos de sync
-- Issue #38

-- ============================================================
-- 1. inventario_producto
--    - Agregar producto_variante_id
--    - Agregar fecha_registro y estado (presentes en local)
--    - Reemplazar unique_inventario(bodega_id, producto_id)
--      por unique_inventario(bodega_id, producto_variante_id)
-- ============================================================

ALTER TABLE inventario_producto
  ADD COLUMN IF NOT EXISTS producto_variante_id UUID
    REFERENCES codigo_producto(id) ON DELETE SET NULL;

ALTER TABLE inventario_producto
  ADD COLUMN IF NOT EXISTS fecha_registro TIMESTAMPTZ DEFAULT now();

ALTER TABLE inventario_producto
  ADD COLUMN IF NOT EXISTS estado BOOLEAN DEFAULT true;

-- Poblar producto_variante_id en filas existentes usando el primer variant del producto
UPDATE inventario_producto ip
SET producto_variante_id = (
  SELECT cp.id
  FROM codigo_producto cp
  WHERE cp.producto_id = ip.producto_id
  ORDER BY cp.fecha_registro
  LIMIT 1
)
WHERE ip.producto_variante_id IS NULL;

-- Reemplazar constraint unique para incluir variante
ALTER TABLE inventario_producto DROP CONSTRAINT IF EXISTS unique_inventario;
ALTER TABLE inventario_producto
  ADD CONSTRAINT unique_inventario UNIQUE (bodega_id, producto_variante_id);

-- ============================================================
-- 2. detalle_movimiento_producto
--    - Agregar producto_variante_id
--    - Agregar variantes_json (presentes en local)
--    - Agregar fecha_registro (presente en local)
-- ============================================================

ALTER TABLE detalle_movimiento_producto
  ADD COLUMN IF NOT EXISTS producto_variante_id UUID
    REFERENCES codigo_producto(id) ON DELETE SET NULL;

ALTER TABLE detalle_movimiento_producto
  ADD COLUMN IF NOT EXISTS variantes_json TEXT;

ALTER TABLE detalle_movimiento_producto
  ADD COLUMN IF NOT EXISTS fecha_registro TIMESTAMPTZ DEFAULT now();

-- ============================================================
-- 3. detalle_venta
--    - Agregar producto_variante_id
--    - Agregar fecha_registro (presente en local)
-- ============================================================

ALTER TABLE detalle_venta
  ADD COLUMN IF NOT EXISTS producto_variante_id UUID
    REFERENCES codigo_producto(id) ON DELETE SET NULL;

ALTER TABLE detalle_venta
  ADD COLUMN IF NOT EXISTS fecha_registro TIMESTAMPTZ DEFAULT now();

-- ============================================================
-- 4. codigo_producto (producto_variantes)
--    - talla es NOT NULL en remoto pero nullable en local.
--      Al subir variantes sin talla la FK no falla pero el
--      insert sí si talla=null. Hacerla nullable.
-- ============================================================

ALTER TABLE codigo_producto
  ALTER COLUMN talla DROP NOT NULL;

-- ============================================================
-- 5. Refrescar schema cache de PostgREST
-- ============================================================
NOTIFY pgrst, 'reload schema';
