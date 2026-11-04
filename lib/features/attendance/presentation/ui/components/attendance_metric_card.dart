import 'package:flutter/material.dart';

class AttendanceMetricCard extends StatelessWidget {
  const AttendanceMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon = Icons.analytics_outlined,
  });

  final String title, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(title),
            ],
          ),
        ),
      );
}