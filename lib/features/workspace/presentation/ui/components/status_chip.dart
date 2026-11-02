import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// Chip with the employment status, colored by status and always labeled with text.
class StatusChip extends StatelessWidget {
  /// Creates the chip for [status].
  const StatusChip({super.key, required this.status});

  final EmploymentStatus status;

  @override
  Widget build(BuildContext context) {
    final Color container = switch (status) {
      EmploymentStatus.active => AppColors.activeContainer,
      EmploymentStatus.suspended => AppColors.suspendedContainer,
      EmploymentStatus.terminated => AppColors.terminatedContainer,
    };
    return LabelChip(text: status.label, containerColor: container);
  }
}

/// Chip that tells whether an area or position is active.
class ActiveChip extends StatelessWidget {
  /// Creates the chip.
  const ActiveChip({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return LabelChip(
      text: active ? 'Activo' : 'Inactivo',
      containerColor: active ? AppColors.activeContainer : AppColors.surfaceContainerHigh,
    );
  }
}

/// Small pill with a text over a solid color.
class LabelChip extends StatelessWidget {
  /// Creates the chip with its [text] and [containerColor].
  const LabelChip({super.key, required this.text, required this.containerColor});

  final String text;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}
