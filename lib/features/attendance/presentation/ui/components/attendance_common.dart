import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_colors.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_formatters.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_labels.dart';

/// Pill with the label of an attendance status, tinted by the status.
class AttendanceStatusChip extends StatelessWidget {
  /// Creates the chip for [status].
  const AttendanceStatusChip({super.key, required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AttendanceColors.status(status), borderRadius: AppShapes.pill),
      child: Text(
        status.label,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}

/// Circle with the initials of an employee.
class AttendanceAvatar extends StatelessWidget {
  /// Creates the avatar of [name] with its [size].
  const AttendanceAvatar({super.key, required this.name, this.size = 40});

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
          AttendanceFormatters.initials(name),
          style: TextStyle(
            color: AppColors.onAvatarContainer,
            fontWeight: FontWeight.w600,
            fontSize: size > 40 ? 17 : 14,
          ),
        ),
      ),
    );
  }
}

/// Icon drawn on a tinted circle.
class AttendanceIconCircle extends StatelessWidget {
  /// Creates the circle with its [icon] and optional colors.
  const AttendanceIconCircle({super.key, required this.icon, this.containerColor, this.contentColor});

  final IconData icon;
  final Color? containerColor;
  final Color? contentColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: containerColor ?? scheme.secondaryContainer),
      child: Icon(icon, size: 20, color: contentColor ?? scheme.onSecondaryContainer),
    );
  }
}

/// Tinted banner with an icon and a message.
class AttendanceBanner extends StatelessWidget {
  /// Creates the banner; the colors default to the info banner.
  const AttendanceBanner({
    super.key,
    required this.message,
    required this.icon,
    this.containerColor = AttendanceColors.infoBanner,
    this.contentColor = AttendanceColors.onInfoBanner,
  });

  final String message;
  final IconData icon;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(color: containerColor, borderRadius: AppShapes.medium),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          Icon(icon, size: 20, color: contentColor),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: contentColor)),
          ),
        ],
      ),
    );
  }
}

/// Title of a block with an optional action on the right.
class AttendanceSectionHeader extends StatelessWidget {
  /// Creates the header.
  const AttendanceSectionHeader({super.key, required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Glass card with a title, a message and an optional action, used for the error and empty states.
class AttendanceMessageState extends StatelessWidget {
  /// Creates the state; [actionLabel] null hides the button.
  const AttendanceMessageState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            AttendanceIconCircle(icon: icon!),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Last item of a list that has more records: asks for the next page when it appears, or shows a
/// retry button if the last attempt failed.
class AttendanceLoadMoreItem extends StatefulWidget {
  /// Creates the item; [itemCount] is the number of records already shown.
  const AttendanceLoadMoreItem({super.key, required this.itemCount, required this.failed, required this.onLoadMore});

  final int itemCount;
  final bool failed;
  final VoidCallback onLoadMore;

  @override
  State<AttendanceLoadMoreItem> createState() => _AttendanceLoadMoreItemState();
}

class _AttendanceLoadMoreItemState extends State<AttendanceLoadMoreItem> {
  @override
  void initState() {
    super.initState();
    _requestNextPage();
  }

  @override
  void didUpdateWidget(AttendanceLoadMoreItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) _requestNextPage();
  }

  void _requestNextPage() {
    if (widget.failed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.failed) widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Center(
        child: widget.failed
            ? TextButton(onPressed: widget.onLoadMore, child: const Text('No se pudieron cargar más. Reintentar'))
            : const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

/// Small progress indicator shown inside a button while its action runs.
class AttendanceButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const AttendanceButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
