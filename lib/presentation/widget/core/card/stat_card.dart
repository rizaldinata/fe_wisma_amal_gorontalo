import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    this.title = 'Total Users',
    this.count = '200',
    this.icon,
    this.color,
  });
  final String title;
  final String count;
  final Widget? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          if (icon != null)
            BasicCard(color: color ?? Colors.blue.shade100, child: icon),
        ],
      ),
    );
  }
}
