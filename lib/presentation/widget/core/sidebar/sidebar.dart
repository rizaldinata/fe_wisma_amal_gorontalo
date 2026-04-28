import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/app/app_bloc.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

class SidebarItem {
  final String label;
  final IconData? icon;
  // final String? routeName;
  final VoidCallback? onTap;
  final PageRouteInfo? page;
  final List<SidebarItem>? children;
  final bool hasAccess;

  const SidebarItem({
    required this.label,
    this.icon,
    this.onTap,
    this.children,
    this.page,
    this.hasAccess = true,
  });

  bool get hasChildren => (children ?? []).isNotEmpty;
}

class CustomSidebar extends StatefulWidget {
  final double width;
  final List<SidebarItem> items;
  final String? activeRouteName;

  const CustomSidebar({
    super.key,
    this.width = 250,
    required this.items,
    this.activeRouteName,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final Set<String> _expanded = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
  }

  final SecureStorageService storage = serviceLocator
      .get<SecureStorageService>();

  Future<bool> isLoggedIn() async {
    final token = await storage.get(StorageConstant.token);
    return token != null;
  }

  bool _isSelected(BuildContext context, SidebarItem item) {
    final current = context.router.current;
    final segments = context.router.currentSegments;

    if (item.page != null) {
      final activeOverride = (widget.activeRouteName != null)
          ? widget.activeRouteName
          : null;
      if (activeOverride != null && activeOverride == item.page!.routeName) {
        return true;
      }

      if (current.name == item.page!.routeName) return true;

      if (segments.any((s) => s.name == item.page!.routeName)) return true;
      try {
        final stack = context.router.stack;
        for (final entry in stack) {
          if (entry.name == item.page!.routeName) return true;
        }
      } catch (_) {}
    }

    if (item.hasChildren) {
      return item.children!.any((c) => _isSelected(context, c));
    }
    return false;
  }

  void _handleTap(BuildContext context, SidebarItem item) {
    setState(() {
      if (item.onTap != null) {
        item.onTap!.call();
        return;
      }
      if (item.page != null) {
        context.router.navigate(item.page!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode = context.select((AppBloc bloc) => bloc.state.isDarkMode);

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wisma Amal',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Operational & Maintenance',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Divider + menu label
                      Text(
                        'Menu',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            if (!item.hasAccess) {
                              // Return an empty widget instead of null to keep
                              // the children's indices contiguous for the
                              // underlying sliver list.
                              return const SizedBox.shrink();
                            }

                            if (item.hasChildren) {
                              final id = item.label;
                              final isOpen =
                                  _expanded.contains(id) ||
                                  _isSelected(context, item);
                              return _buildAccordionSection(
                                context,
                                item,
                                isOpen,
                                id,
                              );
                            }

                            return _buildMenuTile(context, item);
                          },
                        ),
                      ),
                      ToggleButtons(
                        isSelected: [!isDarkMode, isDarkMode],
                        onPressed: (index) {
                          context.read<AppBloc>().add(
                            AppBlocChangeThemeEvent(),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Theme.of(context).colorScheme.onPrimary,
                        fillColor: Theme.of(context).colorScheme.primary,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        constraints: const BoxConstraints(
                          minWidth: 105,
                          minHeight: 30,
                        ),
                        children: const [
                          Icon(Icons.light_mode_rounded, size: 18),
                          Icon(Icons.dark_mode_rounded, size: 18),
                        ],
                      ),

                      // Profile
                      const SizedBox(height: 8),

                      if (state.isLoggedIn == false)
                        BasicButton(
                          onPressed: () {
                            context.router.push(LoginRoute());
                          },
                          label: 'login',
                        ),

                      if (state.isLoggedIn == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state.userInfo == null ||
                                  state.userInfo?.id == null) {
                                context.read<AuthBloc>().add(
                                  const GetUserInfoEvent(),
                                );
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.userInfo?.name ?? 'User',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.userInfo?.roles.join(', ') ??
                                              'Guest',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 12),

                      if (state.isLoggedIn == true)
                        CustomIconButton(
                          boxShadow: [],
                          icon: Icon(Icons.logout),
                          title: 'Logout',
                          onPressed: () {
                            context.read<AuthBloc>().add(const LogoutEvent());
                          },
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAccordionSection(
    BuildContext context,
    SidebarItem section,
    bool isOpen,
    String id,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isOpen
            ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey(id),
            initiallyExpanded: isOpen,
            onExpansionChanged: (v) => _toggleExpanded(id),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: section.icon != null
                ? Icon(
                    section.icon,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(170),
                  )
                : null,
            title: Text(
              section.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
              ),
            ),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 12,
              bottom: 8,
            ),
            children: section.children!
                .map((child) => _buildMenuTile(context, child))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, SidebarItem item) {
    final selected = _isSelected(context, item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _handleTap(context, item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                if (item.icon != null)
                  Icon(
                    item.icon,
                    size: 20,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                if (item.icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
