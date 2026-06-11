# Diseño Técnico

## Componentes a Modificar
- `lib/core/db/daos/inventory_dao.dart`:
  - Añadir método `searchProductosList(String query)` que retorne una `Future<List<Producto>>` limitando a unos 10 o 20 resultados por similitud usando `LIKE`.
- `lib/features/inventory/data/repository/inventario_repository.dart`:
  - Añadir método `buscarProductosPorSimilitud(String query)` que exponga la lista desde el DAO.
- `lib/features/inventory/presentation/screens/warehouse_entry_screen.dart`:
  - Reemplazar el `TextField` actual de búsqueda por un `SearchAnchor` o usar la función `showSearch` con un `SearchDelegate` personalizado.
  - Implementar el generador de sugerencias usando el nuevo método del repositorio.
  - Al seleccionar una opción, llamar a `_handleScannedProduct(producto.codigoPersonalizado ?? producto.id)`.

## Consideraciones Arquitectónicas
- Mantener la UI de Material 3 intuitiva usando componentes nativos como `SearchAnchor`.
- Realizar las consultas a la base de datos de forma asíncrona y eficiente sin bloquear el hilo principal.
- Mantener la consistencia con las reglas de negocio de `AGENTS.md` (no alterar el backend, todo es local con Drift).
