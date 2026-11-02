import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// Read-only field that opens the date picker and shows the chosen date as dd/MM/yyyy.
class DatePickerField extends StatelessWidget {
  /// Creates the field.
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onValueChange;
  final bool isError;
  final String? supportingText;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onValueChange(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? current = value;
    final String text = current == null ? '' : formatDisplayDate(current);
    return Semantics(
      button: true,
      label: label,
      value: text,
      child: InkWell(
        borderRadius: AppShapes.extraSmall,
        onTap: () => _pick(context),
        child: InputDecorator(
          isEmpty: current == null,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(FlowboardIcons.calendar),
            errorText: isError ? (supportingText ?? '') : null,
            helperText: isError ? null : supportingText,
            errorMaxLines: 2,
          ),
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
