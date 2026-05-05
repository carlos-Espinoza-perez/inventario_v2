# ARCHIVO: 03_riverpod_and_ui_reconnection
# ROL: State Management Expert / Flutter Lead
# PROYECTO: inventario_v2 (Reconexión de UI a Drift)

===========================================================================
🎯 OBJETIVO DE ESTE PASO
===========================================================================
Actualizar la capa de presentación para que consuma los nuevos DAOs de Drift. 
Debemos asegurar que la UI sea reactiva: que cuando se registre una venta 
o un movimiento, los widgets se actualicen automáticamente mediante 
Streams de SQLite[cite: 83].

===========================================================================
📡 REFACTORIZACIÓN DE PROVIDERS (RIVERPOD)
===========================================================================

1. PRODUCTOS Y STOCK:
   - Crear 'productosDriftProvider' que use un Stream de InventoryDao.
   - Debe realizar el Join con la tabla Inventarios para mostrar el stock 
     según la 'bodegaSeleccionada' actual[cite: 28, 36].

2. VENTAS Y REPORTES:
   - Migrar 'ventasProvider' para leer de la tabla Ventas de Drift.
   - Implementar filtros de fecha y cliente usando queries de SQL nativo.

3. ESTADO DE CONTEXTO:
   - El 'currentEmpresaProvider' debe leer la información de la tabla 
     Empresas de Drift tras el bootstrap de Supabase.

===========================================================================
🖥️ CAMBIOS EN PANTALLAS (UI)
===========================================================================

- CheckoutScreen: 
    * Eliminar la lógica de validación manual de Isar[cite: 31].
    * Llamar al método 'registrarVentaCompleta()' del SalesDao.
    * Mostrar un indicador de 'Sincronizando...' si el syncStatus es 'pending'.

- InventoryScreen:
    * Actualizar la lista para que use el Stream de Drift.
    * Implementar la búsqueda semántica básica (preparación para IA).

- Dashboard:
    * Los contadores de "Ventas Totales" y "Stock Bajo" deben venir de 
      consultas agregadas (COUNT/SUM) ejecutadas en los DAOs.

===========================================================================
⚠️ ANÁLISIS DE RENDIMIENTO (REVISIÓN SENIOR)
===========================================================================

* REACTIVIDAD: Drift es excelente con Streams. Asegúrate de no cerrar el 
  Stream prematuramente para que la UI reaccione a los cambios del SyncService.
* DEBOUNCE: En las barras de búsqueda, usa un debounce para no saturar 
  de queries SQL a la base de datos mientras el usuario escribe.
* MANEJO DE ERRORES: Si un DAO lanza una excepción de llave foránea, la UI 
  debe capturarla y mostrar un mensaje amigable (ej. "No puedes borrar este 
  producto porque tiene ventas asociadas").