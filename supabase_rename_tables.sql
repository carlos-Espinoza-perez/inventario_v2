-- =================================================================
-- INVENTARIO V2 — RENOMBRAR TABLAS DE PLURAL → SINGULAR
-- Ejecutar en el SQL Editor de Supabase.
-- 
-- OBJETIVO: Alinear los nombres de tablas de Supabase con los
-- nombres que usa el código Dart en sync_repository.dart.
-- 
-- ¡NO BORRA DATOS! Solo renombra tablas existentes.
-- =================================================================


-- =================================================================
-- BLOQUE 1: RENOMBRAR TABLAS (plural → singular)
-- Orden importante: primero las tablas hijas, luego las padre
-- para evitar problemas con FKs durante el rename.
-- =================================================================

-- Ventas / Pagos
ALTER TABLE IF EXISTS public.historial_pagos             RENAME TO historial_pago;
ALTER TABLE IF EXISTS public.detalle_ventas              RENAME TO detalle_venta;
ALTER TABLE IF EXISTS public.venta_productos             RENAME TO venta_producto;
ALTER TABLE IF EXISTS public.caja_movimientos_extra      RENAME TO caja_movimiento_extra;
ALTER TABLE IF EXISTS public.caja_sesiones               RENAME TO caja_sesion;
ALTER TABLE IF EXISTS public.cajas                       RENAME TO caja;
ALTER TABLE IF EXISTS public.clientes                    RENAME TO cliente;

-- Inventario / Movimientos
ALTER TABLE IF EXISTS public.detalle_movimiento_productos RENAME TO detalle_movimiento_producto;
ALTER TABLE IF EXISTS public.movimiento_productos        RENAME TO movimiento_producto;
ALTER TABLE IF EXISTS public.inventario_productos        RENAME TO inventario_producto;
ALTER TABLE IF EXISTS public.productos                   RENAME TO producto;
ALTER TABLE IF EXISTS public.categorias                  RENAME TO categoria;

-- Auth / Config
ALTER TABLE IF EXISTS public.acceso_roles               RENAME TO acceso_rol;
ALTER TABLE IF EXISTS public.bodegas                    RENAME TO bodega;
ALTER TABLE IF EXISTS public.usuarios                   RENAME TO usuario;
ALTER TABLE IF EXISTS public.roles                      RENAME TO rol;
ALTER TABLE IF EXISTS public.empresas                   RENAME TO empresa;
ALTER TABLE IF EXISTS public.reglas_costos              RENAME TO regla_costo;
ALTER TABLE IF EXISTS public.cargos_adicionales         RENAME TO cargo_adicional;


-- =================================================================
-- BLOQUE 2: CREAR TABLA bodega_usuario (NO EXISTÍA)
-- Mapeada desde: BodegaUsuarioColletion.toJson() / fromJson()
-- Campos: id, bodega_id, usuario_id, usuario_registro_id,
--         estado, fecha_registro, ultima_actualizacion,
--         fecha_eliminacion
-- =================================================================

CREATE TABLE IF NOT EXISTS public.bodega_usuario (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bodega_id            UUID NOT NULL REFERENCES public.bodega(id) ON DELETE CASCADE,
    usuario_id           UUID NOT NULL REFERENCES public.usuario(id) ON DELETE CASCADE,
    usuario_registro_id  UUID REFERENCES public.usuario(id),
    estado               BOOLEAN DEFAULT true,
    fecha_registro       TIMESTAMPTZ DEFAULT now(),
    ultima_actualizacion TIMESTAMPTZ DEFAULT now(),
    fecha_eliminacion    TIMESTAMPTZ,

    -- Evitar duplicados de asignación
    CONSTRAINT unique_bodega_usuario UNIQUE (bodega_id, usuario_id)
);

-- Trigger para auto-actualizar ultima_actualizacion
DROP TRIGGER IF EXISTS trg_bodega_usuario_updated ON public.bodega_usuario;
CREATE TRIGGER trg_bodega_usuario_updated
    BEFORE UPDATE ON public.bodega_usuario
    FOR EACH ROW EXECUTE PROCEDURE update_ultima_actualizacion();

-- Índices
CREATE INDEX IF NOT EXISTS idx_bodega_usuario_bodega   ON public.bodega_usuario(bodega_id);
CREATE INDEX IF NOT EXISTS idx_bodega_usuario_usuario  ON public.bodega_usuario(usuario_id);


-- =================================================================
-- BLOQUE 3: RLS para bodega_usuario
-- =================================================================

ALTER TABLE public.bodega_usuario ENABLE ROW LEVEL SECURITY;

CREATE POLICY "rls_bodega_usuario" ON public.bodega_usuario
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.bodega b
        WHERE b.id = bodega_id AND b.empresa_id = get_mi_empresa_id()
    )
) WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.bodega b
        WHERE b.id = bodega_id AND b.empresa_id = get_mi_empresa_id()
    )
);


-- =================================================================
-- BLOQUE 4: ACTUALIZAR PUBLICACIÓN REALTIME
-- Recrear la publicación con los nuevos nombres de tablas
-- =================================================================

DROP PUBLICATION IF EXISTS supabase_realtime;

CREATE PUBLICATION supabase_realtime FOR TABLE
    public.empresa,
    public.rol,
    public.acceso_rol,
    public.usuario,
    public.bodega,
    public.bodega_usuario,
    public.categoria,
    public.producto,
    public.inventario_producto,
    public.movimiento_producto,
    public.detalle_movimiento_producto,
    public.caja,
    public.caja_sesion,
    public.caja_movimiento_extra,
    public.cliente,
    public.venta_producto,
    public.detalle_venta,
    public.historial_pago,
    public.regla_costo,
    public.cargo_adicional;


-- =================================================================
-- VERIFICACIÓN: Mostrar las tablas renombradas
-- (Copiar y pegar esto por separado para confirmar)
-- =================================================================
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- =================================================================
-- FIN DEL SCRIPT
-- =================================================================
