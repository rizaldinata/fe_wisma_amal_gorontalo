import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/presentation/get/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final String route;

  SidebarItem({required this.label, required this.icon, required this.route});
} // model di atas

class CustomSidebar extends StatelessWidget {
  final String currentRoute;
  final List<SidebarItem> items;

  var authController = Get.find<AuthController>();

  CustomSidebar({super.key, required this.currentRoute, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Wisma Amal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Operational & Maintenance",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Menu",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          // Menu items dari list
          ...items.map((item) => _buildMenuItem(context, item)),

          const Spacer(),

          // Profile
          GetBuilder(
            init: authController,
            initState: (state) {
              if (authController.userInfo.value.id == null) {
                authController.getUserInfo();
              }
            },
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authController.userInfo.value.name ?? "User Name",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              authController.userInfo.value.selectedRoles ?? "No Role",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),

          ListTile(
            leading: const Icon(Icons.logout, size: 20),
            title: const Text("Log out"),
            onTap: () {
              authController.logout();
              context.goNamed(RouteConstant.loginName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, SidebarItem item) {
    final bool isSelected = currentRoute == item.route;

    return InkWell(
      onTap: () => context.go(item.route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
