import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// wrapper untuk menu permission
@RoutePage(name: 'PermissionPlaceholderRoute')
class PermissionPlaceholderPage extends EmptyPlaceholderPage {
  const PermissionPlaceholderPage({super.key}) : super(title: 'Permission');
}

@RoutePage(name: 'RolePlaceholderRoute')
class RolePlaceholderPage extends EmptyPlaceholderPage {
  const RolePlaceholderPage({super.key}) : super(title: 'Role');
}

// wrapper untuk Menu Penghuni
@RoutePage(name: 'ResidentPlaceholderRoute')
class ResidentPlaceholderPage extends EmptyPlaceholderPage {
  const ResidentPlaceholderPage({super.key}) : super(title: 'Penghuni');
}

// wrapper untuk Menu Reservasi
@RoutePage(name: 'RoomAndReservationPlaceholderRoute')
class RoomAndReservationPlaceholderPage extends EmptyPlaceholderPage {
  const RoomAndReservationPlaceholderPage({super.key})
    : super(title: 'Reservasi');
}

// wrapper untuk Menu Keuangan
@RoutePage(name: 'FinancePlaceholderRoute')
class FinancePlaceholderPage extends EmptyPlaceholderPage {
  const FinancePlaceholderPage({super.key}) : super(title: 'Keuangan');
}

// wrapper untuk Menu Inventaris
@RoutePage(name: 'InventoryAndMaintenancePlaceholderRoute')
class InventoryAndMaintenancePlaceholderPage extends EmptyPlaceholderPage {
  const InventoryAndMaintenancePlaceholderPage({super.key})
    : super(title: 'Inventaris & Pemeliharaan');
}

class EmptyPlaceholderPage extends StatelessWidget {
  final String title;
  const EmptyPlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Halaman $title sedang dalam pengembangan')),
    );
  }
}
