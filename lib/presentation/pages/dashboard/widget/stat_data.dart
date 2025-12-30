import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/dashboard/dashboard_stat_card.dart';

class StatData extends StatelessWidget {
  const StatData({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardStatCard(),
        const SizedBox(width: 16),
        DashboardStatCard(
          title: 'Active Rooms',
          count: '150',
          icon: const Icon(Icons.meeting_room, size: 40, color: Colors.green),
          color: Colors.green.shade100,
        ),
        const SizedBox(width: 16),
        DashboardStatCard(
          title: 'Pending Payments',
          count: '25',
          icon: const Icon(Icons.payment, size: 40, color: Colors.orange),
          color: Colors.orange.shade100,
        ),
      ],
    );
  }
}
