import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';

/// Read-only outlined field that opens a menu with [options]: "Periodo" of MA-67.
class PayrollSelectField<T> extends StatelessWidget {
  /// Creates the field.
  const PayrollSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.optionLabel,
    required this.onSelect,
    this.enabled = true,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;
  final bool enabled;

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
                child: Text(optionLabel(option), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) {
            final bool canOpen = enabled && options.isNotEmpty;
            return Semantics(
              button: true,
              enabled: canOpen,
              label: label,
              value: text,
              child: InkWell(
                borderRadius: AppShapes.extraSmall,
                onTap: canOpen ? () => controller.isOpen ? controller.close() : controller.open() : null,
                child: InputDecorator(
                  isEmpty: text == null,
                  isFocused: controller.isOpen,
                  decoration: InputDecoration(
                    labelText: label,
                    enabled: enabled,
                    suffixIcon: const Icon(FlowboardIcons.arrowDropDown),
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

/// Filter chip that opens a menu, with the same glass style as the filters of Workspace:
/// "Septiembre 2026 ▾", "Área: Almacén ✕", "Estado: Pendiente ✕" (MA-69).
///
/// When it is selected and [onClear] is given, tapping it clears the filter instead of opening the
/// menu.
class PayrollFilterChip<T> extends StatelessWidget {
  /// Creates the chip.
  const PayrollFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.options,
    required this.optionLabel,
    required this.onSelect,
    this.onClear,
  });

  final String label;
  final bool selected;
  final List<T> options;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool clearable = selected && onClear != null;
    return MenuAnchor(
      menuChildren: <Widget>[
        for (final T option in options)
          MenuItemButton(onPressed: () => onSelect(option), child: Text(optionLabel(option))),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        void openMenu() => controller.isOpen ? controller.close() : controller.open();
        return FilterChip(
          selected: selected,
          showCheckmark: true,
          label: Text(label),
          onSelected: (bool _) => clearable ? onClear!() : openMenu(),
          deleteIcon: Icon(clearable ? FlowboardIcons.close : FlowboardIcons.arrowDropDown, size: 18),
          deleteButtonTooltipMessage: clearable ? 'Quitar filtro' : label,
          onDeleted: clearable ? onClear : openMenu,
        );
      },
    );
  }
}

/// Read-only field that opens the date picker: "Fecha de depósito" of MA-69.
class PayrollDateField extends StatelessWidget {
  /// Creates the field; days after [lastDate] cannot be picked.
  const PayrollDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    required this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onValueChange;
  final DateTime lastDate;

  Future<void> _pick(BuildContext context) async {
    final DateTime current = value ?? lastDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current.isAfter(lastDate) ? lastDate : current,
      firstDate: DateTime(2000),
      lastDate: lastDate,
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onValueChange(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? date = value;
    final String text = date == null ? '' : PayrollFormatters.date(date);
    return Semantics(
      button: true,
      label: label,
      value: text,
      child: InkWell(
        borderRadius: AppShapes.extraSmall,
        onTap: () => _pick(context),
        child: InputDecorator(
          isEmpty: date == null,
          decoration: InputDecoration(labelText: label, suffixIcon: const Icon(FlowboardIcons.calendar)),
          child: Text(text, maxLines: 1, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

/// Multiline text field kept in sync with the view model: "Motivo de la observación" of MA-69.
class PayrollTextField extends StatefulWidget {
  /// Creates the field.
  const PayrollTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.minLines = 3,
    this.maxLength,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final int minLines;
  final int? maxLength;

  @override
  State<PayrollTextField> createState() => _PayrollTextFieldState();
}

class _PayrollTextFieldState extends State<PayrollTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(PayrollTextField oldWidget) {
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
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      minLines: widget.minLines,
      maxLines: null,
      maxLength: widget.maxLength,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: widget.label, alignLabelWithHint: true),
    );
  }
}
