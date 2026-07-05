-- Auditoría 2026-07-04: cursor de sincronización con hora de servidor.
--
-- Problema: ultima_actualizacion la escribe el cliente con el reloj del
-- dispositivo. Un teléfono con reloj atrasado sube filas "en el pasado" que
-- los demás dispositivos nunca descargan (su cursor incremental ya las pasó).
--
-- Solución: columna server_updated_at gestionada exclusivamente por trigger
-- con now() del servidor. Se usa SOLO como cursor de pull incremental;
-- ultima_actualizacion se conserva intacta para la resolución de conflictos
-- (last-write-wins por fecha de edición real).

CREATE OR REPLACE FUNCTION public.set_server_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.server_updated_at := now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  t text;
  tablas text[] := ARRAY[
    'empresa', 'rol', 'acceso_rol', 'usuario', 'bodega', 'bodega_usuario',
    'caja', 'caja_sesion', 'caja_movimiento_extra', 'categoria', 'producto',
    'codigo_producto', 'inventario_producto', 'cliente', 'movimiento_producto',
    'detalle_movimiento_producto', 'venta_producto', 'detalle_venta',
    'historial_pago'
  ];
BEGIN
  FOREACH t IN ARRAY tablas LOOP
    EXECUTE format(
      'ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS server_updated_at timestamptz NOT NULL DEFAULT now()',
      t
    );
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS idx_%s_server_updated_at ON public.%I (server_updated_at)',
      t, t
    );
    EXECUTE format('DROP TRIGGER IF EXISTS trg_server_updated_at ON public.%I', t);
    EXECUTE format(
      'CREATE TRIGGER trg_server_updated_at BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at()',
      t
    );
  END LOOP;
END;
$$;

NOTIFY pgrst, 'reload schema';
