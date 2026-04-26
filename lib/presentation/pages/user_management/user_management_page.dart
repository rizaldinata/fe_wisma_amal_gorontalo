import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';

@RoutePage()
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<UserManagementBloc>()..add(FetchUsers()),
      child: const UserManagementView(),
    );
  }
}

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserManagementActionSuccess) {
          AppSnackbar.showSuccess(state.message);
        } else if (state is UserManagementError) {
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
                        'User Management',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your team member and their account permissions here',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showUserForm(context),
                        icon: const Icon(
                          Icons.person_add_alt_outlined,
                          size: 18,
                        ),
                        label: const Text('Invite User'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Cards
              BlocBuilder<UserManagementBloc, UserManagementState>(
                builder: (context, state) {
                  int total = 0;
                  int admins = 0;
                  int members = 0;
                  int residents = 0;

                  if (state is UserManagementLoaded) {
                    total = state.users.length;
                    admins = state.users
                        .where(
                          (u) =>
                              u.role?.toLowerCase() == 'admin' ||
                              u.role?.toLowerCase() == 'super-admin',
                        )
                        .length;
                    members = state.users
                        .where((u) => u.role?.toLowerCase() == 'member')
                        .length;
                    residents = state.users
                        .where((u) => u.role?.toLowerCase() == 'resident')
                        .length;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Users',
                          count: total.toString(),
                          // icon: const Icon(Icons.people_alt_outlined),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Admins',
                          count: admins.toString(),
                          // icon: const Icon(Icons.security_outlined),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Residents',
                          count: residents.toString(),
                          // icon: const Icon(Icons.home_work_outlined),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'New Members',
                          count: members.toString(),
                          // icon: const Icon(Icons.person_add_outlined),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Main Table Content
              BlocBuilder<UserManagementBloc, UserManagementState>(
                builder: (context, state) {
                  final columns = [
                    const TableColumn(label: 'USER', flex: 4),
                    const TableColumn(label: 'ROLE', flex: 3),
                    const TableColumn(label: 'STATUS', flex: 2),
                    const TableColumn(label: 'CREATED AT', flex: 2),
                    const TableColumn(
                      label: 'ACTIONS',
                      flex: 2,
                      align: TextAlign.center,
                    ),
                  ];

                  List<List<dynamic>> rows = [];
                  if (state is UserManagementLoaded) {
                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final currentUserId = authState.userInfo?.id;

                        rows = state.users.map((user) {
                          final isSelf = user.id == currentUserId;

                          return [
                            _UserCell(user: user),
                            _RoleChip(role: user.role ?? 'member'),
                            _StatusChip(status: 'Active'),
                            Text(
                              user.createdAt?.split('T').first ?? '-',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (!isSelf)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _showUserForm(context, user: user),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, user),
                                  ),
                                ],
                              )
                            else
                              const Center(
                                child: Text(
                                  '-',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ];
                        }).toList();

                        return TableCard(
                          title: 'Data Pengguna',
                          columns: columns,
                          rows: rows,
                          emptyMessage: state is UserManagementLoading
                              ? 'Sedang memuat...'
                              : 'Tidak ada data pengguna',
                          actions: Row(
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search users...',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list, size: 18),
                                label: const Text('Filter'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return TableCard(
                    title: 'Data Pengguna',
                    columns: columns,
                    rows: const [],
                    emptyMessage: state is UserManagementLoading
                        ? 'Sedang memuat...'
                        : 'Tidak ada data pengguna',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus akun ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<UserManagementBloc>().add(DeleteUser(user.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserEntity? user}) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'member';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Invite User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                if (user == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['admin', 'member', 'resident']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedRole = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (user == null) {
                  context.read<UserManagementBloc>().add(
                    CreateUser(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      role: selectedRole,
                    ),
                  );
                } else {
                  context.read<UserManagementBloc>().add(
                    UpdateUserDetails(
                      id: user.id,
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(user == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  final UserEntity user;
  const _UserCell({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.1,
          ),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.email,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;

    switch (role.toLowerCase()) {
      case 'admin':
      case 'super-admin':
        color = theme.colorScheme.primary;
        break;
      case 'resident':
        color = Colors.green;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          role.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF18BF10),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Active',
          style: TextStyle(
            color: Color(0xFF18BF10),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
