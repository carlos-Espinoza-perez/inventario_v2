-- =================================================================
-- INVENTARIO V2 — FIX: Actualizar funciones y políticas RLS
-- después del renombrado de tablas (plural → singular)
--
-- PROBLEMA: ALTER TABLE ... RENAME TO NO actualiza el cuerpo de
-- funciones ni políticas RLS que referencian el nombre antiguo.
--
-- Ejecutar en el SQL Editor de Supabase.
-- =================================================================


-- =================================================================
-- BLOQUE 1: Recrear función get_mi_empresa_id()
-- Antes apuntaba a public.usuarios → ahora debe apuntar a public.usuario
-- =================================================================

CREATE OR REPLACE FUNCTION get_mi_empresa_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT empresa_id FROM public.usuario WHERE id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- =================================================================
-- BLOQUE 2: Recrear la política de la tabla "usuario"
-- La política anterior quedó huérfana (nombre "usuarios_mi_empresa")
-- =================================================================

DROP POLICY IF EXISTS "usuarios_mi_empresa" ON public.usuario;

CREATE POLICY "rls_usuario" ON public.usuario
FOR ALL USING (
    auth.uid() = id
    OR empresa_id = get_mi_empresa_id()
) WITH CHECK (
    auth.uid() = id
    OR empresa_id = get_mi_empresa_id()
);


-- =================================================================
-- BLOQUE 3: Verificar y recrear políticas en tablas sin empresa_id
-- (usan JOINs hacia tablas renombradas)
-- =================================================================

-- acceso_rol: JOIN hacia rol (antes roles)
DROP POLICY IF EXISTS "rls_acceso_rol" ON public.acceso_rol;
CREATE POLICY "rls_acceso_rol" ON public.acceso_rol
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.rol r WHERE r.id = rol_id AND r.empresa_id = get_mi_empresa_id())
);

-- inventario_producto: JOIN hacia bodega (antes bodegas)
DROP POLICY IF EXISTS "rls_inventario_producto" ON public.inventario_producto;
CREATE POLICY "rls_inventario_producto" ON public.inventario_producto
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.bodega b WHERE b.id = bodega_id AND b.empresa_id = get_mi_empresa_id())
);

-- detalle_movimiento_producto: JOIN hacia movimiento_producto
DROP POLICY IF EXISTS "rls_detalle_movimiento_producto" ON public.detalle_movimiento_producto;
CREATE POLICY "rls_detalle_movimiento_producto" ON public.detalle_movimiento_producto
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.movimiento_producto m WHERE m.id = movimiento_producto_id AND m.empresa_id = get_mi_empresa_id())
);

-- caja_sesion: JOIN hacia caja
DROP POLICY IF EXISTS "rls_caja_sesion" ON public.caja_sesion;
CREATE POLICY "rls_caja_sesion" ON public.caja_sesion
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.caja c WHERE c.id = caja_id AND c.empresa_id = get_mi_empresa_id())
);

-- caja_movimiento_extra: JOIN hacia caja_sesion → caja
DROP POLICY IF EXISTS "rls_caja_movimiento_extra" ON public.caja_movimiento_extra;
CREATE POLICY "rls_caja_movimiento_extra" ON public.caja_movimiento_extra
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.caja_sesion s
        JOIN public.caja c ON s.caja_id = c.id
        WHERE s.id = caja_sesion_id AND c.empresa_id = get_mi_empresa_id()
    )
);

-- detalle_venta: JOIN hacia venta_producto
DROP POLICY IF EXISTS "rls_detalle_venta" ON public.detalle_venta;
CREATE POLICY "rls_detalle_venta" ON public.detalle_venta
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.venta_producto v WHERE v.id = venta_id AND v.empresa_id = get_mi_empresa_id())
);

-- historial_pago: JOIN hacia venta_producto
DROP POLICY IF EXISTS "rls_historial_pago" ON public.historial_pago;
CREATE POLICY "rls_historial_pago" ON public.historial_pago
FOR ALL USING (
    EXISTS (SELECT 1 FROM public.venta_producto v WHERE v.id = venta_id AND v.empresa_id = get_mi_empresa_id())
);

-- bodega_usuario: JOIN hacia bodega
DROP POLICY IF EXISTS "rls_bodega_usuario" ON public.bodega_usuario;
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
-- BLOQUE 4: Recrear políticas genéricas (tablas con empresa_id)
-- Las antiguas apuntaban a nombres plurales en el DO$$
-- =================================================================

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'rol', 'bodega', 'categoria', 'producto',
        'movimiento_producto', 'caja', 'cliente',
        'venta_producto', 'regla_costo', 'cargo_adicional'
    ]
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "rls_%I" ON public.%I', t, t);
        EXECUTE format(
            'CREATE POLICY "rls_%I" ON public.%I FOR ALL USING (empresa_id = get_mi_empresa_id()) WITH CHECK (empresa_id = get_mi_empresa_id())',
            t, t
        );
    END LOOP;
END $$;


-- =================================================================
-- BLOQUE 5: Recrear también la política de empresa
-- =================================================================

DROP POLICY IF EXISTS "empresas_solo_mi_empresa" ON public.empresa;
CREATE POLICY "rls_empresa" ON public.empresa
FOR ALL USING (id = get_mi_empresa_id());


-- =================================================================
-- BLOQUE 6: Recrear los triggers con los nuevos nombres de tabla
-- =================================================================

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'empresa', 'rol', 'acceso_rol', 'usuario', 'bodega', 'bodega_usuario',
        'categoria', 'producto', 'inventario_producto',
        'movimiento_producto', 'detalle_movimiento_producto',
        'caja', 'caja_sesion', 'caja_movimiento_extra',
        'cliente', 'venta_producto', 'detalle_venta',
        'historial_pago', 'regla_costo', 'cargo_adicional'
    ]
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated ON public.%I', t, t);
        EXECUTE format(
            'CREATE TRIGGER trg_%I_updated BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE PROCEDURE update_ultima_actualizacion()',
            t, t
        );
    END LOOP;
END $$;


-- =================================================================
-- VERIFICACIÓN: Confirma que get_mi_empresa_id ya usa el nombre nuevo
-- =================================================================
-- SELECT prosrc FROM pg_proc WHERE proname = 'get_mi_empresa_id';
-- Debe mostrar: SELECT empresa_id FROM public.usuario WHERE id = auth.uid() LIMIT 1

-- =================================================================
-- FIN DEL SCRIPT
-- =================================================================
