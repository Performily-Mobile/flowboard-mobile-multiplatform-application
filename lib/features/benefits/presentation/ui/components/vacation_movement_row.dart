import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/vacation_movement_type.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_icons.dart';

/// One movement of the vacation balance.
///
/// In the employee view (MA-57) the days go at the end; in the HR view (MA-63) they go in the
/// detail: "−5 días · 10/08/2026".
class VacationMovementRow extends StatelessWidget {
  /// Creates the row; [daysInSubtitle] moves the days to the detail line.
  const VacationMovementRow({super.key, required this.movement, this.daysInSubtitle = false});

  final VacationMovement movement;
  final bool daysInSubtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String days = BenefitsFormatters.signedDays(movement.days);
    final String detail = BenefitsFormatters.movementDetail(movement);
    return BenefitListItem(
      leading: GlassIconBadge(icon: _icon),
      title: BenefitsFormatters.movementTitle(movement),
      subtitle: daysInSubtitle ? '$days · $detail' : detail,
      subtitleMaxLines: 3,
      trailing: daysInSubtitle
          ? null
          : Text(days, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  IconData get _icon => switch (movement.type) {
        VacationMovementType.manualAdjustment => BenefitsIcons.edit,
        VacationMovementType.reversal => BenefitsIcons.sync,
        _ => movement.days < 0 ? BenefitsIcons.minus : BenefitsIcons.plus,
      };
}
