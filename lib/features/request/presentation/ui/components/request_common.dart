import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_labels.dart';

/// Pill with the label of a request status, tinted by the status.
class RequestStatusChip extends StatelessWidget {
  /// Creates the chip for [status].
  const RequestStatusChip({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return RequestChip(text: status.label, containerColor: RequestColors.status(status));
  }
}

/// Small pill-shaped label with a tinted background.
class RequestChip extends StatelessWidget {
  /// Creates the chip with its [text] and [containerColor].
  const RequestChip({super.key, required this.text, required this.containerColor});

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

/// Circle with the initials of a person.
class RequestAvatar extends StatelessWidget {
  /// Creates the avatar of [name] with its [size].
  const RequestAvatar({super.key, required this.name, this.size = 40});

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
          RequestFormatters.initials(name),
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
class RequestIconCircle extends StatelessWidget {
  /// Creates the circle with its [icon] and optional colors.
  const RequestIconCircle({super.key, required this.icon, this.containerColor, this.contentColor});

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

/// Label and value shown as one row of a [KeyValueCard].
class KeyValue {
  /// Creates the row.
  const KeyValue(this.label, this.value);

  final String label;
  final String value;
}

/// Card that lists label and value pairs separated by dividers; shows nothing when [items] is empty.
class KeyValueCard extends StatelessWidget {
  /// Creates the card.
  const KeyValueCard({super.key, required this.items});

  final List<KeyValue> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  Text(
                    items[i].label,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(items[i].value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tinted banner with an icon, a message and an optional text action.
class RequestBanner extends StatelessWidget {
  /// Creates the banner.
  const RequestBanner({
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
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(color: containerColor, borderRadius: AppShapes.medium),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          Icon(icon, size: 20, color: contentColor),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: contentColor))),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: TextStyle(color: contentColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

/// Step label and segmented progress bar of a multi-step form.
class RequestStepHeader extends StatelessWidget {
  /// Creates the header of [step] out of [total].
  const RequestStepHeader({super.key, required this.step, required this.total, required this.label});

  final int step;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s,
      children: <Widget>[
        Text('Paso $step de $total · $label', style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
        Row(
          spacing: 4,
          children: <Widget>[
            for (int index = 1; index <= total; index++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= step ? scheme.primary : scheme.surfaceContainer,
                    borderRadius: AppShapes.pill,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Title of a block with an optional action on the right.
class RequestSectionHeader extends StatelessWidget {
  /// Creates the header.
  const RequestSectionHeader({super.key, required this.text, this.action});

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
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Centered glass card with a title, a message and an optional action, used for the error and
/// empty states of the request screens.
class RequestMessageState extends StatelessWidget {
  /// Creates the state; [actionLabel] null hides the button.
  const RequestMessageState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.topPadding = 48,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, topPadding, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              RequestIconCircle(icon: icon!),
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
      ),
    );
  }
}

/// Last item of a list that has more requests: asks for the next page when it appears, or shows a
/// retry button if the last attempt failed.
class RequestLoadMoreItem extends StatefulWidget {
  /// Creates the item; [itemCount] is the number of requests already shown.
  const RequestLoadMoreItem({super.key, required this.itemCount, required this.failed, required this.onLoadMore});

  final int itemCount;
  final bool failed;
  final VoidCallback onLoadMore;

  @override
  State<RequestLoadMoreItem> createState() => _RequestLoadMoreItemState();
}

class _RequestLoadMoreItemState extends State<RequestLoadMoreItem> {
  @override
  void initState() {
    super.initState();
    _requestNextPage();
  }

  @override
  void didUpdateWidget(RequestLoadMoreItem oldWidget) {
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
class RequestButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const RequestButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
