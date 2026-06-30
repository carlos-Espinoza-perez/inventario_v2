-- Sprint 2.1: campo auxiliar para preservar el tipo_movimiento local exacto
-- El enum tipo_movimiento_enum del servidor no incluye 'entrada'/'salida',
-- por lo que se mapean a 'compra'/'ajuste'. Este campo guarda el valor
-- original para recuperarlo sin pérdida al hacer pull en otro dispositivo.
ALTER TABLE public.movimiento_producto
  ADD COLUMN IF NOT EXISTS tipo_movimiento_local TEXT;
