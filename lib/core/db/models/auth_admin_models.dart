import '../app_database.dart';

class StaffAdminDataDrift {
  final List<Usuario> users;
  final List<Role> roles;
  final List<Bodega> warehouses;
  final List<BodegasUsuario> assignments;

  const StaffAdminDataDrift({
    required this.users,
    required this.roles,
    required this.warehouses,
    required this.assignments,
  });
}

class RoleManagementDataDrift {
  final List<Role> roles;
  final List<AccesosRolData> accesses;

  const RoleManagementDataDrift({
    required this.roles,
    required this.accesses,
  });
}
