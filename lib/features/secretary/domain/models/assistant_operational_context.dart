class AssistantWarehouse {
  final String id;
  final String nombre;

  const AssistantWarehouse({
    required this.id,
    required this.nombre,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };
}

class AssistantOperationalContext {
  final String empresaId;
  final String usuarioId;
  final String rolId;
  final List<String> permisos;
  final String? selectedWarehouseId;
  final List<AssistantWarehouse> allowedWarehouses;
  final bool cajaSesionAbierta;
  final String? cajaId;
  final String? openCashSessionId;

  const AssistantOperationalContext({
    required this.empresaId,
    required this.usuarioId,
    required this.rolId,
    required this.permisos,
    this.selectedWarehouseId,
    this.allowedWarehouses = const [],
    this.cajaSesionAbierta = false,
    this.cajaId,
    this.openCashSessionId,
  });

  bool get isValid => empresaId.isNotEmpty && usuarioId.isNotEmpty;
  bool get hasCashOpen => cajaSesionAbierta;
  Set<String> get allowedWarehouseIds =>
      allowedWarehouses.map((b) => b.id).toSet();

  bool hasPermission(String permission) => permisos.contains(permission);
  bool canAccessWarehouse(String? warehouseId) =>
      warehouseId != null && allowedWarehouseIds.contains(warehouseId);

  AssistantWarehouse? warehouseById(String? warehouseId) {
    if (warehouseId == null) return null;
    for (final warehouse in allowedWarehouses) {
      if (warehouse.id == warehouseId) return warehouse;
    }
    return null;
  }

  Map<String, dynamic> toContextMap() => {
        'empresaId': empresaId,
        'usuarioId': usuarioId,
        'rolId': rolId,
        'selectedWarehouseId': selectedWarehouseId,
        'allowedWarehouseIds': allowedWarehouseIds.toList(),
        'allowedWarehouses': allowedWarehouses.map((b) => b.toJson()).toList(),
        'cajaSesionAbierta': cajaSesionAbierta,
        'cajaId': cajaId,
        'openCashSessionId': openCashSessionId,
      };
}
