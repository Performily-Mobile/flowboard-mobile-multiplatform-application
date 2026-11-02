import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_formatters.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';

/// Pending request: avatar, employee, type and dates, and the "Pendiente" chip.
class RequestToAttendItem extends StatelessWidget {
  /// Creates the row; [onTap] opens the request.
  const RequestToAttendItem({super.key, required this.request, required this.onTap});

  final RequestToAttend request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String detail = DashboardFormatters.requestDetail(request);

    return Semantics(
      button: true,
      label: '${request.requesterName}, $detail, pendiente',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              EmployeeAvatar(initials: DashboardFormatters.initials(request.requesterName)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: <Widget>[
                    Text(
                      request.requesterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.awaitingContainer,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  'Pendiente',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A2600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
