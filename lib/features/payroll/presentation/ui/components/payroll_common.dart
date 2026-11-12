import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/domain/valueobject/publication_status.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_colors.dart';

/// Status pill: Pendiente, Pagado, Observado, Por publicar, Publicada.
class PayrollChip extends StatelessWidget {
  /// Creates the chip with its [text] over [containerColor].
  const PayrollChip({super.key, required this.text, required this.containerColor});

  /// Chip of a payment [status].
  factory PayrollChip.payment(PaymentStatus status) =>
      PayrollChip(text: status.label, containerColor: PayrollColors.payment(status));

  /// Chip of a publication [status].
  factory PayrollChip.publication(PublicationStatus status) =>
      PayrollChip(text: status.label, containerColor: PayrollColors.publication(status));

  final String text;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: containerColor, borderRadius: AppShapes.pill),
      child: Text(
        text,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}

/// Payment status on top and the publication status below: "Pagado / Publicada" (Boletas y pagos).
/// While HR has not published the payslip it only shows "Por publicar".
class PayrollStatusChips extends StatelessWidget {
  /// Creates the chips for [publication] and [payment].
  const PayrollStatusChips({super.key, required this.publication, required this.payment});

  final PublicationStatus publication;
  final PaymentStatus payment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 4,
      children: <Widget>[
        if (publication == PublicationStatus.published) PayrollChip.payment(payment),
        PayrollChip.publication(publication),
      ],
    );
  }
}

/// Round 40 dp avatar with the initials of an employee (MA-67, MA-69).
class PayrollInitialsAvatar extends StatelessWidget {
  /// Creates the avatar with [initials].
  const PayrollInitialsAvatar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.avatarContainer),
        child: Text(
          initials,
          style: const TextStyle(color: AppColors.onAvatarContainer, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

/// Round 40 dp avatar with an icon, such as the card of a payslip (MA-65).
class PayrollIconAvatar extends StatelessWidget {
  /// Creates the avatar with [icon].
  const PayrollIconAvatar({super.key, this.icon = FlowboardIcons.creditCard});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.avatarContainer),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }
}

/// Row of a list separated by a divider, as in the prototype: avatar, title, detail and the end
/// content (chip and actions).
class PayrollListRow extends StatelessWidget {
  /// Creates the row; [onTap] null makes it read-only.
  const PayrollListRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.subtitleMaxLines = 1,
    this.showDivider = true,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final List<Widget> trailing;
  final VoidCallback? onTap;
  final int subtitleMaxLines;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: showDivider ? Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              spacing: AppSpacing.m,
              children: <Widget>[
                leading,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      Text(
                        subtitle,
                        maxLines: subtitleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                ...trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner with a warning icon for the files that could not be uploaded (MA-67).
class PayrollErrorBanner extends StatelessWidget {
  /// Creates the banner with its [message].
  const PayrollErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: const BoxDecoration(color: PayrollColors.errorBanner, borderRadius: AppShapes.extraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.m,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(FlowboardIcons.warning, size: 20, color: PayrollColors.onErrorBanner),
          ),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PayrollColors.onErrorBanner),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered card for errors and empty lists, with an optional action.
class PayrollMessageState extends StatelessWidget {
  /// Creates the state; [actionLabel] null hides the button.
  const PayrollMessageState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.topPadding = 48,
    this.horizontalPadding = AppSpacing.screenHorizontal,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double topPadding;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? label = actionLabel;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s,
            children: <Widget>[
              Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (label != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(onPressed: onAction, child: Text(label)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small progress indicator shown inside a button while its action runs.
class PayrollButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const PayrollButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
