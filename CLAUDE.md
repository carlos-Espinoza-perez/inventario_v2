# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Comandos principales

```bash
# Instalar dependencias
flutter pub get

# Generar código (Drift + Riverpod) — OBLIGATORIO después de cambiar tablas o providers anotados
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch para desarrollo activo
flutter pub run build_runner watch --delete-conflicting-outputs

# Análisis estático
flutter analyze

# Ejecutar tests
flutter test

# Ejecutar un test específico
flutter test test/widget_test.dart

# Compilar APK
flutter build apk
```

## Arquitectura

**Stack:** Flutter + Riverpod + Drift (SQLite) + Supabase + GoRouter

El proyecto usa **Clean Architecture** organizado por features dentro de `lib/`:

```
lib/
├── core/           # Código compartido: DB, providers globales, router, servicios, widgets
└── features/       # Módulos de negocio independientes
    ├── auth/
    ├── inventory/
    ├── sales/
    ├── dashboard/
    └── report/
```

Cada feature sigue la estructura `data/ → domain/ → presentation/`.

### Base de datos (Drift)

- Definición central en `lib/core/db/app_database.dart` (schema version 4)
- Las tablas están en `lib/core/db/tables/` agrupadas por dominio (`auth_tables`, `inventory_tables`, `sales_tables`, etc.)
- Los DAOs en `lib/core/db/daos/` encapsulan todas las queries SQL
- **Toda modificación de tablas requiere regenerar código** (`build_runner build`) y actualizar la versión del schema con la migración correspondiente
- Las migraciones actualmente destruyen y recrean tablas (`onUpgrade`)
- Todos los registros tienen campo `sync_status` para soporte offline-first

### Estado (Riverpod)

- Providers globales en `lib/core/providers/` (ej. `driftDatabaseProvider`, `supabaseProvider`)
- Providers por feature en `features/*/presentation/providers/` y `features/*/data/providers/`
- Se usa `@Riverpod` (riverpod_generator) para providers que generan código — sus archivos `.g.dart` no deben editarse manualmente
- Los DAOs se inyectan siempre vía `driftDatabaseProvider` usando `ref.watch`

### Navegación (GoRouter)

- Configuración centralizada en `lib/core/router/app_router.dart`
- Usa `PermissionGuard` widget para proteger rutas según permisos del rol

### Sincronización offline-first

- `lib/core/repositories/sync_repository_drift.dart` maneja la sincronización local → Supabase
- `lib/core/services/image_sync_service.dart` sincroniza imágenes
- El campo `sync_status` en cada tabla rastrea el estado de sincronización pendiente

## Generación de código

Los siguientes archivos son **generados automáticamente** y no deben editarse:
- `lib/core/db/app_database.g.dart`
- Cualquier archivo `*.g.dart` en `lib/core/` o `lib/features/auth/`

Si se agrega una nueva tabla o DAO en Drift, o un nuevo provider con `@Riverpod`, siempre ejecutar `build_runner build` antes de continuar.

## Variables de entorno

El proyecto usa `flutter_dotenv` — se requiere un archivo `.env` en la raíz con las credenciales de Supabase (URL y anon key).
