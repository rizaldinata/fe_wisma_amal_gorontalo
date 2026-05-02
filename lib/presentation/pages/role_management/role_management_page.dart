import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/role/role_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/bloc/role/role_bloc.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';

@RoutePage()
class RoleManagementPage extends StatelessWidget {
  const RoleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<RoleBloc>()..add(FetchRolesAndPermissions()),
      child: const RoleManagementView(),
    );
  }
}

class RoleManagementView extends StatelessWidget {
  const RoleManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<RoleBloc, RoleState>(
      listener: (context, state) {
        if (state is RoleActionSuccess) {
          AppSnackbar.showSuccess(state.message);
        } else if (state is RoleError) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role Management',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define and manage roles and their associated permissions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showRoleForm(context),
                    icon: const Icon(Icons.add_moderator_outlined, size: 18),
                    label: const Text('Add New Role'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats
              BlocBuilder<RoleBloc, RoleState>(
                builder: (context, state) {
                  int totalRoles = 0;
                  int totalPermissions = 0;

                  if (state is RoleLoaded) {
                    totalRoles = state.roles.length;
                    totalPermissions = state.permissions.length;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Roles',
                          count: totalRoles.toString(),
                          color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Available Permissions',
                          count: totalPermissions.toString(),
                          color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Table
              BlocBuilder<RoleBloc, RoleState>(
                builder: (context, state) {
                  final columns = [
                    const TableColumn(label: 'ROLE NAME', flex: 3),
                    const TableColumn(label: 'DESCRIPTION', flex: 5),
                    const TableColumn(label: 'PERMISSIONS COUNT', flex: 2, align: TextAlign.center),
                    const TableColumn(label: 'ACTIONS', flex: 2, align: TextAlign.center),
                  ];

                  List<List<dynamic>> rows = [];
                  if (state is RoleLoaded) {
                    rows = state.roles.map((role) {
                      return [
                        Text(
                          role.name.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          role.description ?? '-',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${role.permissions.length} Perms',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _showRoleForm(context, role: role),
                            ),
                            if (role.name != 'super-admin' &&
                                role.name != 'member' &&
                                role.name != 'resident')
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () => _confirmDelete(context, role),
                              ),
                          ],
                        ),
                      ];
                    }).toList();
                  }

                  return TableCard(
                    title: 'Role List',
                    columns: columns,
                    rows: rows,
                    emptyMessage: state is RoleLoading ? 'Loading roles...' : 'No roles found',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RoleEntity role) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete the role "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<RoleBloc>().add(DeleteRole(role.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRoleForm(BuildContext context, {RoleEntity? role}) {
    final nameController = TextEditingController(text: role?.name);
    final descController = TextEditingController(text: role?.description);
    final List<String> selectedPermissions = role?.permissions.map((p) => p.name).toList() ?? [];

    final state = context.read<RoleBloc>().state;
    if (state is! RoleLoaded) return;

    final allPermissions = state.permissions;

    final roleBloc = context.read<RoleBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: roleBloc,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(role == null ? 'Add New Role' : 'Edit Role'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Role Name', hintText: 'e.g., manager'),
                      readOnly: role?.name == 'super-admin',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description', hintText: 'Role description...'),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    _buildPermissionGroups(allPermissions, selectedPermissions, setState),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (role == null) {
                    roleBloc.add(CreateRole(
                      name: nameController.text,
                      description: descController.text,
                      permissions: selectedPermissions,
                    ));
                  } else {
                    roleBloc.add(UpdateRole(
                      id: role.id,
                      name: nameController.text,
                      description: descController.text,
                      permissions: selectedPermissions,
                    ));
                  }
                  Navigator.pop(dialogContext);
                },
                child: Text(role == null ? 'Create' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Nama tampilan per modul (target → label)
  static const _moduleLabels = {
    'dashboard':   'Dashboard',
    'permission':  'Manajemen Permission',
    'role':        'Manajemen Role',
    'user':        'Manajemen User',
    'room':        'Manajemen Kamar',
    'lease':       'Sewa & Reservasi',
    'finance':     'Keuangan',
    'inventory':   'Inventaris',
    'maintenance': 'Pemeliharaan',
    'resident':    'Penghuni',
    'setting':     'Pengaturan',
  };

  Widget _buildPermissionGroups(
    List<PermissionEntity> allPermissions,
    List<String> selected,
    StateSetter setState,
  ) {
    // Grouping by field `target` (modul) — reliable, no string hacks
    final Map<String, List<PermissionEntity>> groups = {};

    for (final p in allPermissions) {
      final groupKey = (p.target?.isNotEmpty == true) ? p.target! : 'other';
      groups.putIfAbsent(groupKey, () => []).add(p);
    }

    // Urutkan sesuai urutan modul yang diketahui
    final orderedKeys = [
      ..._moduleLabels.keys.where((k) => groups.containsKey(k)),
      ...groups.keys.where((k) => !_moduleLabels.containsKey(k)),
    ];

    return Column(
      children: orderedKeys.map((key) {
        final label = _moduleLabels[key] ?? key[0].toUpperCase() + key.substring(1);
        final perms = groups[key]!;

        return ExpansionTile(
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: perms.map((p) {
                  final isSelected = selected.contains(p.name);
                  return FilterChip(
                    label: Text(
                      p.name.replaceAll('-', ' '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    tooltip: p.description,
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selected.add(p.name);
                        } else {
                          selected.remove(p.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
