# ARCHIVO: 02_centralized_logic_and_daos
# ROL: Backend Architect & Logic Integrator
# PROYECTO: inventario_v2 (Unificación de Lógica Post-Isar)

===========================================================================
🎯 OBJETIVO DE ESTE PASO
===========================================================================
Centralizar la lógica de negocio en los DAOs de Drift y UseCases. 
Debemos extraer el código que "vende" o "mueve stock" de las pantallas 
hacia métodos seguros y transaccionales que tanto la UI como la IA 
puedan invocar sin riesgo de inconsistencias. 

===========================================================================
🏗️ EL CORAZÓN: BASE_DAO Y FILTRADO AUTOMÁTICO
===========================================================================
Todo DAO (AuthDao, SalesDao, InventoryDao) debe heredar de una clase base 
que inyecte el contexto operativo:

1. Inyectar 'empresaId' actual en cada consulta de forma transparente[cite: 28, 29].
2. Inyectar 'bodegaId' activa para validaciones de stock[cite: 28].
3. Proveer el 'usuarioId' para auditoría de movimientos[cite: 28].

===========================================================================
🛠️ MÉTODOS CRÍTICOS A IMPLEMENTAR (CASOS DE USO)
===========================================================================

-- SalesDao (Lógica de Venta Unificada) --
- registrarVentaCompleta(): 
    * Debe abrir una transacción SQL.
    * Verificar que exista una 'cajaSesionId' abierta[cite: 28].
    * Validar stock en la tabla 'Inventarios' (no en Productos)[cite: 36].
    * Insertar cabecera de Venta y DetalleVenta.
    * Actualizar el saldo del Cliente si es venta a crédito.

-- InventoryDao (Gestión de Existencias) --
- getStockRealPorBodega(): Join entre Productos e Inventarios filtrado por bodega[cite: 36].
- registrarMovimientoLogistico(): Manejar Entradas, Salidas y Ajustes en un solo punto[cite: 39].

-- AuthDao (Contexto de sesión) --
- getSesionActiva(): Devolver Empresa, Usuario y Permisos actuales[cite: 28, 29].

===========================================================================
🔄 FLUJO DE DATOS (ESTADO)
===========================================================================
Al eliminar Isar, los Repositorios deben ser refactorizados para:
1. Llamar al DAO correspondiente.
2. Si la operación es exitosa, marcar el registro como 'pending_insert' 
   para que el SyncService lo suba a Supabase[cite: 41, 46].
3. Invalidar los providers de Riverpod para refrescar la UI.

===========================================================================
⚠️ ANÁLISIS DE RIESGOS (REVISIÓN SENIOR)
===========================================================================

* TRANSACCIONALIDAD: Si falla la inserción del detalle de venta, se debe 
  hacer ROLLBACK de la cabecera. SQLite/Drift lo maneja nativamente.
* PERMISOS: Antes de ejecutar cualquier método del DAO, se debe verificar 
  el 'PermissionCode' del usuario activo[cite: 28].
* PRECIOS MÚLTIPLES: La lógica debe respetar el 'precioVenta' de la tabla 
  Inventarios según la bodega, no el 'precioBase' del Producto[cite: 34, 35].

===========================================================================
🚀 INSTRUCCIÓN PARA ANTIGRAVITY
===========================================================================
"Antigravity, procede a la Etapa 2 de migración:
1. Implementa el 'BaseDao' para manejar el filtrado automático por empresaId.
2. Completa los DAOs de Sales, Inventory y Auth con métodos transaccionales.
3. Extrae la lógica de 'Venta' de las pantallas hacia el 'SalesDao'.
4. Asegúrate de que todas las validaciones de stock se hagan contra la 
   tabla 'Inventarios' filtrando por la bodega activa.
5. Los repositorios deben dejar de usar Isar y consumir estos nuevos DAOs."