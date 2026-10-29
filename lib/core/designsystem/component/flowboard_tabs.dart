import 'package:flutter/material.dart';

/// Pill-shaped tab selector used for every set of tabs and single-choice switch of the app.
///
/// Up to three short options share the width equally; with more options or longer labels the
/// row scrolls horizontally so no label gets cut.
class FlowboardTabs<T> extends StatelessWidget {
  /// Creates the selector with its [options], the [selected] one, the [onSelect] callback and
  /// [labelOf], which returns the text of each option. [enabled] false ignores taps.
  const FlowboardTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.labelOf,
    this.enabled = true,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelect;
  final String Function(T option) labelOf;
  final bool enabled;

  static const int _maxEqualWidthOptions = 3;
  static const int _maxEqualWidthLabel = 12;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> labels = options.map(labelOf).toList();
    final bool fillWidth = options.length <= _maxEqualWidthOptions &&
        labels.every((String label) => label.length <= _maxEqualWidthLabel);

    final Row row = Row(
      mainAxisSize: fillWidth ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 4),
          if (fillWidth)
            Expanded(child: _buildPill(labels[i], options[i]))
          else
            _buildPill(labels[i], options[i]),
        ],
      ],
    );

    return DecoratedBox(
      decoration: ShapeDecoration(color: scheme.surfaceContainerHigh, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: fillWidth
            ? row
            : SingleChildScrollView(scrollDirection: Axis.horizontal, child: row),
      ),
    );
  }

  Widget _buildPill(String text, T option) {
    return _TabPill(
      text: text,
      selected: option == selected,
      enabled: enabled,
      onTap: () => onSelect(option),
    );
  }
}

/// Index-based version of [FlowboardTabs] for screens that keep the selected tab as a number.
class FlowboardIndexTabs extends StatelessWidget {
  /// Creates the selector with the [labels] of each tab, the [selectedIndex] and [onSelect].
  const FlowboardIndexTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return FlowboardTabs<int>(
      options: List<int>.generate(labels.length, (int index) => index),
      selected: selectedIndex,
      onSelect: onSelect,
      labelOf: (int index) => labels[index],
    );
  }
}

/// One option of the selector: a pill that turns into a raised chip when selected.
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.text,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected ? scheme.surface : scheme.surfaceContainerHigh,
            shape: const StadiumBorder(),
            shadows: selected
                ? const <BoxShadow>[
                    BoxShadow(color: Color(0x1F000000), blurRadius: 2, offset: Offset(0, 1)),
                  ]
                : null,
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
