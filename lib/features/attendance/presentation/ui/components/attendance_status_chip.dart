import 'package:flutter/material.dart';

class AttendanceStatusChip extends StatelessWidget {
  const AttendanceStatusChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
      );
}