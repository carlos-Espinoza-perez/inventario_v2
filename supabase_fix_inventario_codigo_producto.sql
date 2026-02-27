-- =================================================================
-- FIX: inventario_codigo_producto
--
-- Problema: La tabla fue creada con 'cantidad_actual' y
-- 'cantidad_reservada', pero el mapper Dart (toJson) envía 'cantidad'.
--
-- Solución: Recrear la tabla con el esquema exacto del mapper.
-- =================================================================

-- 1. Eliminar la tabla existente (si fue creada con el schema incorrecto)
DROP TABLE IF EXISTS public.inventario_codigo_producto CASCADE;

-- 2. Crear con las columnas correctas según InventarioCodigoProductoCollection.toJson()
CREATE TABLE public.inventario_codigo_producto (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventario_id        UUID NOT NULL REFERENCES public.inventario_productos(id) ON DELETE CASCADE,
    codigo_producto_id   UUID NOT NULL REFERENCES public.codigo_producto(id) ON DELETE CASCADE,
    cantidad             NUMERIC(15, 4) DEFAULT 0,       -- ← campo que usa el Dart

    -- Auditoría
    usuario_registro_id  UUID REFERENCES public.usuarios(id),
    fecha_registro       TIMESTAMPTZ DEFAULT now(),
    estado               BOOLEAN DEFAULT true,
    ultima_actualizacion TIMESTAMPTZ DEFAULT now(),
    fecha_eliminacion    TIMESTAMPTZ,

    CONSTRAINT unique_inv_codigo_producto
        UNIQUE (inventario_id, codigo_producto_id)
);

-- 3. Índices
CREATE INDEX idx_inv_cod_prod_inventario
    ON public.inventario_codigo_producto(inventario_id);
CREATE INDEX idx_inv_cod_prod_codigo
    ON public.inventario_codigo_producto(codigo_producto_id);

-- 4. RLS
ALTER TABLE public.inventario_codigo_producto ENABLE ROW LEVEL SECURITY;

-- 5. Agregar a Realtime
ALTER PUBLICATION supabase_realtime
    ADD TABLE public.inventario_codigo_producto;

-- 6. Verificar estructura final
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'inventario_codigo_producto'
ORDER BY ordinal_position;
