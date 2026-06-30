# Auditoría RLS — Supabase (Sprint 4.1)

**Fecha:** 2026-06-27  
**Proyecto:** Sistema de inventario V2 (`tovzdapibtbufjrilptk`)  
**Resultado:** ✅ Todas las tablas de negocio tienen RLS habilitado con policy `ALL`

---

## Resultado por tabla

| Tabla | Policy | Filtro | Estado |
|---|---|---|---|
| `empresa` | `rls_empresa` | `id = get_mi_empresa_id()` | ✅ |
| `rol` | `rls_rol` / `rls_roles` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `acceso_rol` | `rls_acceso_rol` / `rls_acceso_roles` | via `rol.empresa_id` | ✅ |
| `usuario` | `rls_usuario` | `auth.uid() = id OR empresa_id = get_mi_empresa_id()` | ✅ |
| `bodega` | `rls_bodega` / `rls_bodegas` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `bodega_usuario` | `rls_bodega_usuario` | via `bodega.empresa_id` | ✅ |
| `caja` | `rls_caja` / `rls_cajas` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `caja_sesion` | `rls_caja_sesion` / `rls_caja_sesiones` | via `caja.empresa_id` | ✅ |
| `caja_movimiento_extra` | `rls_caja_movimiento_extra` | via `caja_sesion → caja.empresa_id` | ✅ |
| `categoria` | `rls_categoria` / `rls_categorias` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `producto` | `rls_producto` / `rls_productos` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `codigo_producto` | `rls_codigo_producto` | via `producto.empresa_id` | ✅ |
| `inventario_producto` | `rls_inventario_producto` | via `bodega.empresa_id` | ✅ |
| `movimiento_producto` | `rls_movimiento_producto` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `detalle_movimiento_producto` | `rls_detalle_movimiento_producto` | via `movimiento_producto.empresa_id` | ✅ |
| `cliente` | `rls_cliente` / `rls_clientes` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `venta_producto` | `rls_venta_producto` / `rls_venta_productos` | `empresa_id = get_mi_empresa_id()` | ✅ |
| `detalle_venta` | `rls_detalle_venta` / `rls_detalle_ventas` | via `venta_producto.empresa_id` | ✅ |
| `historial_pago` | `rls_historial_pago` / `rls_historial_pagos` | via `venta_producto.empresa_id` | ✅ |
| `cargo_adicional` | `rls_cargo_adicional` | `empresa_id = get_mi_empresa_id()` | ✅ |

## Observaciones

- Todas las tablas usan la función `get_mi_empresa_id()` que resuelve la empresa del usuario autenticado.
- Todas las policies son `ALL` (cubre SELECT, INSERT, UPDATE, DELETE).
- Hay policies duplicadas en algunas tablas (ej: `rls_bodega` y `rls_bodegas`), sin impacto negativo — Postgres aplica la política más permisiva cuando hay múltiples. Se pueden limpiar en una migración futura.
- `codigo_producto` tiene además policies adicionales de INSERT y UPDATE para usuarios autenticados — es redundante con la policy `ALL` pero no es dañino.
- La tabla `debug_logs` solo tiene policy de INSERT, lo cual es correcto (solo se escribe, no se lee desde el cliente).
