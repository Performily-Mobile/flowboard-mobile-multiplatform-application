import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';

/// Pill-shaped search box shared by every list of the app.
class FlowboardSearchField extends StatefulWidget {
  /// Creates the search box.
  ///
  /// [query] is the current text, [onQueryChange] is called on every change (with an empty text
  /// when the clear button is tapped) and [placeholder] is the hint shown while it is empty.
  const FlowboardSearchField({
    super.key,
    required this.query,
    required this.onQueryChange,
    required this.placeholder,
  });

  final String query;
  final ValueChanged<String> onQueryChange;
  final String placeholder;

  @override
  State<FlowboardSearchField> createState() => _FlowboardSearchFieldState();
}

class _FlowboardSearchFieldState extends State<FlowboardSearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(FlowboardSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    const InputBorder noBorder = OutlineInputBorder(
      borderRadius: AppShapes.pill,
      borderSide: BorderSide.none,
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        return TextField(
          controller: _controller,
          onChanged: widget.onQueryChange,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            filled: true,
            fillColor: scheme.surfaceContainerHigh,
            prefixIcon: const Icon(FlowboardIcons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    icon: const Icon(FlowboardIcons.close),
                    onPressed: () {
                      _controller.clear();
                      widget.onQueryChange('');
                    },
                  ),
            constraints: const BoxConstraints(minHeight: 52),
            border: noBorder,
            enabledBorder: noBorder,
            focusedBorder: noBorder,
            disabledBorder: noBorder,
          ),
        );
      },
    );
  }
}
