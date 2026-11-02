import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/detail_row.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// "Puesto" tab of the employee record: current job data and the history of job assignments.
class JobAssignmentTab extends StatelessWidget {
  /// Creates the tab.
  const JobAssignmentTab({
    super.key,
    required this.employee,
    required this.directManagerName,
    required this.jobAssignments,
  });

  final Employee employee;
  final String? directManagerName;
  final List<JobAssignment> jobAssignments;

  @override
  Widget build(BuildContext context) {
    final DateTime? contractEndDate = employee.employmentPeriod.contractEndDate;
    final TerminationDetails? termination = employee.termination;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.itemGap,
      children: <Widget>[
        InfoPanel(
          children: <Widget>[
            DetailRow(label: 'Área', value: employee.areaName),
            DetailRow(label: 'Posición', value: employee.positionTitle),
            DetailRow(
              label: 'Jefe directo',
              value: directManagerName ?? (employee.hasDirectManager ? '—' : 'Sin jefe directo'),
            ),
            DetailRow(label: 'Tipo de contrato', value: employee.contractType.label),
            DetailRow(label: 'Fecha de ingreso', value: formatDisplayDate(employee.employmentPeriod.hireDate)),
            if (contractEndDate != null) DetailRow(label: 'Fin de contrato', value: formatDisplayDate(contractEndDate)),
          ],
        ),
        if (termination != null)
          InfoPanel(
            children: <Widget>[
              DetailRow(label: 'Fecha de cese', value: formatDisplayDate(termination.terminationDate)),
              DetailRow(label: 'Motivo', value: termination.reason),
            ],
          ),
        if (jobAssignments.isNotEmpty) ...<Widget>[
          const SectionTitle('Historial de puestos'),
          for (final JobAssignment assignment in jobAssignments) _JobAssignmentItem(assignment: assignment),
        ],
      ],
    );
  }
}

/// Card with one entry of the job assignment history.
class _JobAssignmentItem extends StatelessWidget {
  const _JobAssignmentItem({required this.assignment});

  final JobAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime? endDate = assignment.endDate;
    final String period =
        '${formatDisplayDate(assignment.startDate)} – ${endDate == null ? 'Actual' : formatDisplayDate(endDate)}';
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  '${assignment.positionTitle} · ${assignment.areaName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '${assignment.changeType.label} · $period',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (assignment.current) const LabelChip(text: 'Vigente', containerColor: AppColors.activeContainer),
        ],
      ),
    );
  }
}
