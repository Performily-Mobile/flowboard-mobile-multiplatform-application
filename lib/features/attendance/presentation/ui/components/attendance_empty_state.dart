import 'package:flutter/material.dart';

class AttendanceEmptyState extends StatelessWidget {
  const AttendanceEmptyState({
    super.key,
    this.message = 'No se encontraron registros',
  });

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_outlined, size: 42),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}