import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';

/// Read-only field that opens a menu with [options]; used for the type, area, employee and unit.
class BenefitsSelectField<T> extends StatelessWidget {
  /// Creates the field.
  const BenefitsSelectField({
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
                trailingIcon: option == current ? const Icon(FlowboardIcons.check, size: 18) : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width - 72),
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
                  child: Text(text ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Read-only field that opens the date picker and shows the date as dd/MM/yyyy.
///
/// With [lastDate] later days cannot be picked (a delivery cannot be in the future) and with
/// [firstDate] earlier days cannot be picked.
class BenefitsDateField extends StatelessWidget {
  /// Creates the field.
  const BenefitsDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.firstDate,
    this.lastDate,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onValueChange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isError;
  final String? supportingText;

  Future<void> _pick(BuildContext context) async {
    final DateTime first = firstDate ?? DateTime(2000);
    final DateTime last = lastDate ?? DateTime(2100);
    final DateTime initial = value.isBefore(first) ? first : (value.isAfter(last) ? last : value);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onValueChange(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final String text = BenefitsFormatters.date(value);
    return Semantics(
      button: true,
      label: label,
      value: text,
      child: InkWell(
        borderRadius: AppShapes.extraSmall,
        onTap: () => _pick(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(FlowboardIcons.calendar),
            errorText: isError ? (supportingText ?? '') : null,
            helperText: isError ? null : supportingText,
            errorMaxLines: 2,
          ),
          child: Text(text, maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

/// Text field whose value lives in the view model.
///
/// [numeric] opens the decimal keyboard (or the integer one with [integerOnly]); [prefix] and
/// [suffix] show the unit, such as "S/" or "días".
class BenefitsTextField extends StatefulWidget {
  /// Creates the field.
  const BenefitsTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.error,
    this.prefix,
    this.suffix,
    this.numeric = false,
    this.integerOnly = false,
    this.minLines = 1,
    this.maxLength,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;
  final String? prefix;
  final String? suffix;
  final bool numeric;
  final bool integerOnly;
  final int minLines;
  final int? maxLength;

  @override
  State<BenefitsTextField> createState() => _BenefitsTextFieldState();
}

class _BenefitsTextFieldState extends State<BenefitsTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(BenefitsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
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
    final bool multiline = widget.minLines > 1;
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      minLines: widget.minLines,
      maxLines: multiline ? null : 1,
      maxLength: widget.maxLength,
      keyboardType: widget.numeric
          ? TextInputType.numberWithOptions(decimal: !widget.integerOnly)
          : (multiline ? TextInputType.multiline : TextInputType.text),
      inputFormatters: widget.numeric
          ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(widget.integerOnly ? r'[0-9]' : r'[0-9.]'))]
          : null,
      textCapitalization: widget.numeric ? TextCapitalization.none : TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.error,
        errorMaxLines: 2,
        prefixText: widget.prefix == null ? null : '${widget.prefix} ',
        suffixText: widget.suffix,
        alignLabelWithHint: multiline,
      ),
    );
  }
}

/// Choice between two or more options: "Colaborador / Área completa", "Agregar / Descontar días".
class BenefitsSegmented<T> extends StatelessWidget {
  /// Creates the selector.
  const BenefitsSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.optionLabel,
    required this.onSelect,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return FlowboardTabs<T>(options: options, selected: selected, onSelect: onSelect, labelOf: optionLabel);
  }
}
