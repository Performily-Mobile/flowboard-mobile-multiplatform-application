import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';

/// Read-only field that opens a glass menu with [options] and shows the [selected] one.
class SelectField<T> extends StatelessWidget {
  /// Creates the field.
  ///
  /// [optionLabel] returns the text of each option, [enabled] false ignores taps, [isError] colors
  /// the field as an error and [supportingText] is shown below it (as the error when [isError]).
  const SelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.optionLabel,
    required this.onSelect,
    this.enabled = true,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;
  final bool enabled;
  final bool isError;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final T? current = selected;
    final String? text = current == null ? null : optionLabel(current);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite ? constraints.maxWidth : 240;
        return MenuAnchor(
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll<Size>(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll<Size>(Size(width, 320)),
          ),
          menuChildren: <Widget>[
            for (final T option in options)
              MenuItemButton(
                onPressed: () => onSelect(option),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width - 48),
                  child: Text(optionLabel(option), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return Semantics(
              button: true,
              enabled: enabled,
              label: label,
              value: text,
              child: InkWell(
                borderRadius: AppShapes.extraSmall,
                onTap: enabled ? () => controller.isOpen ? controller.close() : controller.open() : null,
                child: InputDecorator(
                  isEmpty: text == null,
                  isFocused: controller.isOpen,
                  decoration: InputDecoration(
                    labelText: label,
                    enabled: enabled,
                    suffixIcon: const Icon(FlowboardIcons.arrowDropDown),
                    errorText: isError ? (supportingText ?? '') : null,
                    helperText: isError ? null : supportingText,
                    helperMaxLines: 2,
                    errorMaxLines: 2,
                  ),
                  child: Text(
                    text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
