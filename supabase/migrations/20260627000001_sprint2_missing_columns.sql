-- Sprint 2: columnas faltantes detectadas en auditoría offline-first 2026-06-26
-- Prerequisito para sprint2 de sync_repository_drift.dart

-- 1.3: fecha real del pago en historial_pago
ALTER TABLE public.historial_pago
  ADD COLUMN IF NOT EXISTS fecha_registro_pago TIMESTAMP WITH TIME ZONE;

-- 1.4: bodega por defecto del usuario (push/pull de bodega_default_id)
ALTER TABLE public.usuario
  ADD COLUMN IF NOT EXISTS bodega_default_id UUID REFERENCES public.bodega(id) ON DELETE SET NULL;

-- 2.4: descripción de bodega
ALTER TABLE public.bodega
  ADD COLUMN IF NOT EXISTS descripcion TEXT;
