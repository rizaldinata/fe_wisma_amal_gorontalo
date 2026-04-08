import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';

class StatData extends StatelessWidget {
  const StatData({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          title: 'Total Users',
          count: '200',
          icon: const Icon(Icons.people, size: 40, color: Colors.blue),
          color: Colors.blue.shade100,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Active Rooms',
          count: '150',
          icon: const Icon(Icons.meeting_room, size: 40, color: Colors.green),
          color: Colors.green.shade100,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Pending Payments',
          count: '25',
          icon: const Icon(Icons.payment, size: 40, color: Colors.orange),
          color: Colors.orange.shade100,
        ),
      ],
    );
  }
}
