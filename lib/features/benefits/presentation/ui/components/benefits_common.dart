import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';

/// Status pill: Asignado, Entregado, Activo, Inactivo.
class BenefitChip extends StatelessWidget {
  /// Creates the chip with its [text] over [containerColor].
  const BenefitChip({super.key, required this.text, required this.containerColor});

  final String text;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: containerColor, borderRadius: AppShapes.pill),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurface)),
    );
  }
}

/// Round avatar with the initials of an employee (MA-62).
class InitialsAvatar extends StatelessWidget {
  /// Creates the avatar for [name].
  const InitialsAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.avatarContainer),
        child: Text(
          BenefitsFormatters.initials(name),
          style: const TextStyle(color: AppColors.onAvatarContainer, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

/// Glass card of a list: icon or avatar, title, detail and optional content at the end.
class BenefitListItem extends StatelessWidget {
  /// Creates the item; [onTap] null makes it read-only.
  const BenefitListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.subtitleMaxLines = 2,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget? end = trailing;
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.only(left: 16, right: end != null ? 12 : 16, top: 14, bottom: 14),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                Text(
                  subtitle,
                  maxLines: subtitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ?end,
        ],
      ),
    );
  }
}

/// Banner with an icon and an optional action: offline (MA-57) or warning (MA-61).
class BenefitsBanner extends StatelessWidget {
  /// Creates the banner.
  const BenefitsBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.containerColor,
    required this.contentColor,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final Color containerColor;
  final Color contentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final String? label = actionLabel;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(color: containerColor, borderRadius: AppShapes.extraSmall),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          Icon(icon, size: 20, color: contentColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: contentColor)),
            ),
          ),
          if (label != null)
            TextButton(
              onPressed: onAction,
              child: Text(label, style: TextStyle(color: contentColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

/// Title of a section: "Movimientos", "Entregados recientemente".
class BenefitsSectionHeader extends StatelessWidget {
  /// Creates the title.
  const BenefitsSectionHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Centered glass card for errors and empty lists, with an optional action.
class BenefitsMessageState extends StatelessWidget {
  /// Creates the state; [actionLabel] null hides the button.
  const BenefitsMessageState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.topPadding = 48,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? label = actionLabel;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, topPadding, AppSpacing.screenHorizontal, 0),
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
class BenefitsButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const BenefitsButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
