# Módulo de Autorización y Control de Acceso — Documentación Técnica

Este directorio contiene la especificación técnica completa para implementar el módulo de autorización del sistema `inventario_v2`.

## Decisiones Confirmadas

| Pregunta | Decisión |
|---|---|
| Envío de emails | Opción A — Templates nativos de Supabase |
| Validar permisos en vistas | **Todas** las vistas deben validar permisos |
| Acceso denegado | Opción B — Pantalla dedicada de "Sin permisos" |
| Flujo "Olvidé mi contraseña" | Sí — Flujo completo con `resetPasswordForEmail` |
| Admin resetea contraseña de staff | Sí — Vía Edge Function |
| PIN offline | Omitido — Se mantiene login con correo y contraseña |

## Estructura de Fases

| Fase | Documento | Riesgo | Esfuerzo |
|---|---|---|---|
| Fase 1 | [Fase_1_Correcciones_Conexiones.md](./Fase_1_Correcciones_Conexiones.md) | 🟢 Bajo | ~4h |
| Fase 2 | [Fase_2_Guards_Permisos.md](./Fase_2_Guards_Permisos.md) | 🟡 Medio | ~6h |
| Fase 3 | [Fase_3_Gestion_Staff_Mejorada.md](./Fase_3_Gestion_Staff_Mejorada.md) | 🟡 Medio | ~6h |
| Fase 4 | [Fase_4_Hub_Administracion.md](./Fase_4_Hub_Administracion.md) | 🟡 Medio | ~4h |

## Orden de ejecución

Las fases deben ejecutarse en orden (1 → 2 → 3 → 4). Cada fase es un PR independiente.

## Archivos de referencia del proyecto

Antes de trabajar en cualquier fase, el agente **debe leer estos archivos** para comprender la arquitectura:

- `AGENTS.md` — Reglas de trabajo para IA
- `lib/core/db/tables/auth_tables.dart` — Tablas de Drift para auth
- `lib/core/db/daos/auth_dao.dart` — DAO con queries de auth
- `lib/core/constants/permission_codes.dart` — 37 códigos de permiso
- `lib/features/auth/presentation/providers/auth_provider.dart` — Estado de autenticación
- `lib/features/auth/presentation/providers/authorization_provider.dart` — Estado de autorización
- `lib/core/router/app_router.dart` — Rutas de GoRouter
- `lib/features/auth/data/repositories/auth_repository.dart` — Login online/offline
- `lib/features/auth/data/repositories/staff_account_repository.dart` — Creación de staff
- `lib/features/auth/data/repositories/role_access_repository.dart` — Permisos de roles
- `supabase/functions/create-staff-user/index.ts` — Edge Function existente
- `requerimiento/roles_staff_supabase.sql` — SQL del esquema remoto
