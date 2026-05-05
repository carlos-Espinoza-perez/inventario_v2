import 'package:flutter/material.dart';
class PermissionCode {
  static const dashboardRead = 'dashboard.read';

  static const warehouseRead = 'warehouse.read';
  static const warehouseCreate = 'warehouse.create';
  static const warehouseUpdate = 'warehouse.update';
  static const warehouseDelete = 'warehouse.delete';

  static const productRead = 'product.read';
  static const productCreate = 'product.create';
  static const productUpdate = 'product.update';
  static const productDelete = 'product.delete';

  static const categoryRead = 'category.read';
  static const categoryCreate = 'category.create';
  static const categoryUpdate = 'category.update';
  static const categoryDelete = 'category.delete';

  static const saleRead = 'sale.read';
  static const saleCreate = 'sale.create';
  static const saleUpdate = 'sale.update';
  static const saleDelete = 'sale.delete';
  static const saleCredit = 'sale.credit';

  static const reportRead = 'report.read';

  static const staffRead = 'staff.read';
  static const staffCreate = 'staff.create';
  static const staffUpdate = 'staff.update';
  static const staffDelete = 'staff.delete';

  static const roleRead = 'role.read';
  static const roleCreate = 'role.create';
  static const roleUpdate = 'role.update';
  static const roleDelete = 'role.delete';
}

class PermissionDefinition {
  final String code;
  final String label;
  final String description;

  const PermissionDefinition({
    required this.code,
    required this.label,
    required this.description,
  });
}

class PermissionSection {
  final String title;
  final IconData icon;
  final List<PermissionDefinition> permissions;

  const PermissionSection({
    required this.title,
    required this.icon,
    required this.permissions,
  });
}

const permissionSections = <PermissionSection>[
  PermissionSection(
    title: 'Inicio',
    icon: Icons.dashboard_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.dashboardRead,
        label: 'Ver panel',
        description: 'Consultar el resumen principal del negocio.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Bodegas',
    icon: Icons.warehouse_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.warehouseRead,
        label: 'Ver bodegas',
        description: 'Consultar bodegas, inventario y movimientos.',
      ),
      PermissionDefinition(
        code: PermissionCode.warehouseCreate,
        label: 'Crear bodegas',
        description: 'Registrar nuevas bodegas.',
      ),
      PermissionDefinition(
        code: PermissionCode.warehouseUpdate,
        label: 'Editar bodegas',
        description: 'Gestionar movimientos, ingresos y traslados.',
      ),
      PermissionDefinition(
        code: PermissionCode.warehouseDelete,
        label: 'Eliminar bodegas',
        description: 'Desactivar o borrar bodegas.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Productos',
    icon: Icons.inventory_2_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.productRead,
        label: 'Ver productos',
        description: 'Consultar catálogo y detalle de productos.',
      ),
      PermissionDefinition(
        code: PermissionCode.productCreate,
        label: 'Crear productos',
        description: 'Registrar nuevos productos base.',
      ),
      PermissionDefinition(
        code: PermissionCode.productUpdate,
        label: 'Editar productos',
        description: 'Modificar datos y presentaciones del producto.',
      ),
      PermissionDefinition(
        code: PermissionCode.productDelete,
        label: 'Eliminar productos',
        description: 'Desactivar productos del catálogo.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Categorías',
    icon: Icons.category_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.categoryRead,
        label: 'Ver categorías',
        description: 'Consultar categorías y árbol del catálogo.',
      ),
      PermissionDefinition(
        code: PermissionCode.categoryCreate,
        label: 'Crear categorías',
        description: 'Agregar categorías y subcategorías.',
      ),
      PermissionDefinition(
        code: PermissionCode.categoryUpdate,
        label: 'Editar categorías',
        description: 'Modificar estructura y nombres.',
      ),
      PermissionDefinition(
        code: PermissionCode.categoryDelete,
        label: 'Eliminar categorías',
        description: 'Eliminar categorías sin productos asociados.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Ventas',
    icon: Icons.point_of_sale_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.saleRead,
        label: 'Ver ventas',
        description: 'Consultar ventas, caja e historial.',
      ),
      PermissionDefinition(
        code: PermissionCode.saleCreate,
        label: 'Crear ventas',
        description: 'Abrir caja y registrar ventas nuevas.',
      ),
      PermissionDefinition(
        code: PermissionCode.saleUpdate,
        label: 'Editar ventas',
        description: 'Modificar o actualizar operaciones de venta.',
      ),
      PermissionDefinition(
        code: PermissionCode.saleDelete,
        label: 'Borrar ventas',
        description: 'Anular o eliminar ventas.',
      ),
      PermissionDefinition(
        code: PermissionCode.saleCredit,
        label: 'Ventas al crédito',
        description: 'Permitir ventas con saldo pendiente.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Reportes',
    icon: Icons.bar_chart_rounded,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.reportRead,
        label: 'Ver reportes',
        description: 'Consultar reportes financieros, ventas e inventario.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Personal',
    icon: Icons.groups_2_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.staffRead,
        label: 'Ver personal',
        description: 'Consultar personal y sus asignaciones.',
      ),
      PermissionDefinition(
        code: PermissionCode.staffCreate,
        label: 'Crear personal',
        description: 'Agregar nuevos usuarios del equipo.',
      ),
      PermissionDefinition(
        code: PermissionCode.staffUpdate,
        label: 'Editar personal',
        description: 'Modificar rol, correo y bodegas asignadas.',
      ),
      PermissionDefinition(
        code: PermissionCode.staffDelete,
        label: 'Eliminar personal',
        description: 'Desactivar miembros del equipo.',
      ),
    ],
  ),
  PermissionSection(
    title: 'Roles',
    icon: Icons.admin_panel_settings_outlined,
    permissions: [
      PermissionDefinition(
        code: PermissionCode.roleRead,
        label: 'Ver roles',
        description: 'Consultar roles y permisos.',
      ),
      PermissionDefinition(
        code: PermissionCode.roleCreate,
        label: 'Crear roles',
        description: 'Registrar nuevos roles.',
      ),
      PermissionDefinition(
        code: PermissionCode.roleUpdate,
        label: 'Editar roles',
        description: 'Modificar nombre, tipo y permisos.',
      ),
      PermissionDefinition(
        code: PermissionCode.roleDelete,
        label: 'Eliminar roles',
        description: 'Desactivar roles que ya no se usarán.',
      ),
    ],
  ),
];

final allPermissionCodes = <String>[
  for (final section in permissionSections)
    for (final permission in section.permissions) permission.code,
];

const adminDefaultPermissionCodes = <String>[
  PermissionCode.dashboardRead,
  PermissionCode.warehouseRead,
  PermissionCode.warehouseCreate,
  PermissionCode.warehouseUpdate,
  PermissionCode.warehouseDelete,
  PermissionCode.productRead,
  PermissionCode.productCreate,
  PermissionCode.productUpdate,
  PermissionCode.productDelete,
  PermissionCode.categoryRead,
  PermissionCode.categoryCreate,
  PermissionCode.categoryUpdate,
  PermissionCode.categoryDelete,
  PermissionCode.saleRead,
  PermissionCode.saleCreate,
  PermissionCode.saleUpdate,
  PermissionCode.saleDelete,
  PermissionCode.saleCredit,
  PermissionCode.reportRead,
  PermissionCode.staffRead,
  PermissionCode.staffCreate,
  PermissionCode.staffUpdate,
  PermissionCode.staffDelete,
  PermissionCode.roleRead,
  PermissionCode.roleCreate,
  PermissionCode.roleUpdate,
  PermissionCode.roleDelete,
];

const operatorDefaultPermissionCodes = <String>[
  PermissionCode.dashboardRead,
  PermissionCode.warehouseRead,
  PermissionCode.warehouseUpdate,
  PermissionCode.productRead,
  PermissionCode.categoryRead,
  PermissionCode.saleRead,
  PermissionCode.saleCreate,
  PermissionCode.saleCredit,
  PermissionCode.reportRead,
];
