import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/app/app_bloc.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';

class SidebarItem {
  final String label;
  final IconData? icon;
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
  final Set<String> activeRouteNames;

  const CustomSidebar({
    super.key,
    this.width = 240,
    required this.items,
    required this.activeRouteNames,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final Set<String> _expanded = {};
  String? _hoveredItem;

  void _toggleExpanded(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
  }

  final SecureStorageService storage = serviceLocator.get<SecureStorageService>();

  Future<bool> isLoggedIn() async {
    final token = await storage.get(StorageConstant.token);
    return token != null;
  }

  bool _isSelected(SidebarItem item) {
    if (item.page != null) {
      if (widget.activeRouteNames.contains(item.page!.routeName)) {
        return true;
      }
    }

    if (item.hasChildren) {
      return item.children!.any((c) => _isSelected(c));
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
    final isDark = AppTheme.isDark(context);
    
    final sidebarBg = isDark ? AppColorsDark.sidebarBg : AppColorsLight.sidebarBg;
    final sidebarBorder = isDark ? AppColorsDark.borderLight : AppColorsLight.sidebarBorder;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: sidebarBg,
            border: Border(
              right: BorderSide(color: sidebarBorder),
            ),
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.apartment, color: isDark ? AppColorsDark.primary : AppColorsLight.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wisma Amal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Operational & Maint',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.items[index];
                            if (!item.hasAccess) {
                              return const SizedBox.shrink();
                            }

                            if (item.hasChildren) {
                              final id = item.label;
                              final isOpen = _expanded.contains(id) || _isSelected(item);
                              return _buildAccordionSection(context, item, isOpen, id, isDark);
                            }

                            return _buildMenuTile(context, item, isDark);
                          },
                        ),
                      ),
                      
                      // Dark Mode Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isDarkMode ? 'Dark Mode' : 'Light Mode',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                              ),
                            ),
                            Switch(
                              value: isDarkMode,
                              onChanged: (val) {
                                context.read<AppBloc>().add(AppBlocChangeThemeEvent());
                              },
                              activeColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Profile
                      if (state.isLoggedIn == false)
                        BasicButton(
                          onPressed: () {
                            context.router.push(LoginRoute());
                          },
                          label: 'login',
                        ),

                      if (state.isLoggedIn == true)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            onTap: () {
                              context.router.navigatePath('/${RouteConstant.residentProfileName}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                              ),
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state.userInfo == null || state.userInfo?.id == null) {
                                    context.read<AuthBloc>().add(const GetUserInfoEvent());
                                  }

                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                                        child: Icon(
                                          Icons.person,
                                          size: 18,
                                          color: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.userInfo?.name ?? 'Super Admin',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              state.userInfo?.roles.join(', ') ?? 'super-admin',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.logout, size: 18, color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                                        onPressed: () {
                                          context.read<AuthBloc>().add(const LogoutEvent());
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildAccordionSection(BuildContext context, SidebarItem section, bool isOpen, String id, bool isDark) {
    final sectionColor = isDark ? AppColorsDark.sidebarSection : AppColorsLight.sidebarSection;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8, top: 16),
          child: Text(
            section.label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: sectionColor,
            ),
          ),
        ),
        ...section.children!.map((child) => _buildMenuTile(context, child, isDark)),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context, SidebarItem item, bool isDark) {
    final isActive = _isSelected(item);
    final isHovered = _hoveredItem == item.label;

    final activeBg     = isDark ? AppColorsDark.sidebarActive    : AppColorsLight.sidebarActive;
    final hoverBg      = isDark ? AppColorsDark.sidebarHoverBg   : AppColorsLight.sidebarHoverBg;
    final activeIcon   = isDark ? AppColorsDark.sidebarActiveIcon : Colors.white;
    final inactiveIcon = isDark ? AppColorsDark.sidebarMuted     : AppColorsLight.sidebarMuted;
    final activeText   = isDark ? AppColorsDark.sidebarActiveText : AppColorsLight.sidebarActiveText;
    final inactiveText = isDark ? AppColorsDark.sidebarText      : AppColorsLight.sidebarText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredItem = item.label),
        onExit: (_) => setState(() => _hoveredItem = null),
        child: GestureDetector(
          onTap: () => _handleTap(context, item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isActive ? activeBg : (isHovered ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minLeadingWidth: 20,
              leading: item.icon != null ? Icon(
                item.icon,
                color: isActive ? activeIcon : inactiveIcon,
                size: 18,
              ) : null,
              title: Text(
                item.label,
                style: TextStyle(
                  color: isActive ? activeText : inactiveText,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              trailing: item.hasChildren ? Icon(
                Icons.chevron_right,
                size: 16,
                color: isActive ? activeIcon : inactiveIcon,
              ) : null,
            ),
          ),
        ),
      ),
    );
  }
}
