# ARCHIVO: 01_drift_full_schema_sync
# ROL: Lead Database Architect & Sync Expert
# PROYECTO: inventario_v2 (Migración Total Isar -> Drift)

===========================================================================
🎯 OBJETIVO DE ESTE PASO
===========================================================================
Eliminar por completo la dependencia de Isar y establecer una base de datos 
relacional (SQLite) mediante Drift. Este esquema permite:
1. Sincronización robusta con Supabase vía UUIDs[cite: 81].
2. Multi-tenencia blindada (Filtro por empresaId).
3. Integridad referencial para evitar datos huérfanos[cite: 11].
4. Preparación para IA (Campos de embeddings y tipos de datos exactos)[cite: 27].

===========================================================================
🏗️ INFRAESTRUCTURA DE TABLAS (CONTRATO DRIFT)
===========================================================================

-- MIXIN DE SINCRONIZACIÓN --
Todas las tablas de negocio deben incluir este mixin:
- id: TextColumn (UUID v4 generado localmente o por Supabase).
- createdAt / updatedAt: DateTimeColumn.
- syncStatus: TextColumn ('synced', 'pending_insert', 'pending_update').

-- 1. NÚCLEO Y ACCESOS --
- Empresas: id (PK), nombre, serverId (UUID).
- Usuarios: id (PK), empresaId (FK), nombre, email, rol, bodegaDefaultId (FK).
- Bodegas: id (PK), empresaId (FK), nombre, ubicacion.
- BodegasUsuarios: Relación N:N entre Usuarios y Bodegas.

-- 2. CATÁLOGO E INVENTARIO (IA READY) --
- Categorias: id (PK), empresaId (FK), nombre, categoriaPadreId (FK).
- Productos: 
    * id (PK), empresaId (FK), categoriaId (FK).
    * nombre, codigoBarras, marca, descripcion.
    * embedding: TextColumn (nullable) para vectores de 384 dimensiones[cite: 54, 58].
- Inventarios (STOCK REAL): 
    * id (PK), productoId (FK), bodegaId (FK).
    * cantidadActual: RealColumn (Default 0).
    * precioVenta: RealColumn (Precio específico por bodega).

-- 3. VENTAS Y CLIENTES --
- Clientes: id (PK), empresaId (FK), nombre, telefono, saldoDeudora.
- Ventas: id (PK), empresaId (FK), clienteId (FK), usuarioId (FK), cajaSesionId, total, tipoPago.
- DetalleVentas: id (PK), ventaId (FK), productoId (FK), cantidad, precioUnitario, subtotal.
- PagosVentas (RECEIVABLES): id (PK), ventaId (FK), monto, fechaPago, metodoPago.

-- 4. LOGÍSTICA --
- Movimientos: id (PK), empresaId (FK), bodegaOrigenId (FK), bodegaDestinoId (FK), tipo (Entrada/Salida/Ajuste).
- DetalleMovimientos: id (PK), movimientoId (FK), productoId (FK), cantidad.

===========================================================================
🔄 REGLAS DE IMPLEMENTACIÓN (POST-MIGRACIÓN)
===========================================================================

1. LLAVES FORÁNEAS: Configurar 'ON DELETE CASCADE' para mantener la 
   limpieza de datos locales.
2. UUID v4: Obligatorio para cada inserción nueva, garantizando que el 
   ID sea el mismo en el móvil y en Supabase.
3. FILTRO DE CONTEXTO: Cada DAO de Drift debe inyectar automáticamente 
   'WHERE empresa_id = $currentEmpresaId'[cite: 28, 29].