import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_time.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';

/// Text field whose value is kept by the view model.
class RequestTextField extends StatefulWidget {
  /// Creates the field; [minLines] above one makes it multiline.
  const RequestTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.error,
    this.helperText,
    this.prefixText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.minLines = 1,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;
  final String? helperText;
  final String? prefixText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int minLines;
  final bool enabled;

  @override
  State<RequestTextField> createState() => _RequestTextFieldState();
}

class _RequestTextFieldState extends State<RequestTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(RequestTextField oldWidget) {
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
      enabled: widget.enabled,
      keyboardType: multiline ? TextInputType.multiline : widget.keyboardType,
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: <TextInputFormatter>[
        ...?widget.inputFormatters,
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      minLines: widget.minLines,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: widget.prefixText,
        errorText: widget.error,
        helperText: widget.helperText,
        errorMaxLines: 2,
        helperMaxLines: 2,
      ),
    );
  }
}

/// Read-only field that opens a menu with [options] and shows the [selected] one.
class RequestSelectField<T> extends StatelessWidget {
  /// Creates the field.
  const RequestSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.optionLabel,
    required this.onSelect,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final T? current = selected;
    final String? text = current == null ? null : optionLabel(current);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite ? constraints.maxWidth : 240;
        return MenuAnchor(
          style: MenuStyle(minimumSize: WidgetStatePropertyAll<Size>(Size(width, 0))),
          menuChildren: <Widget>[
            for (final T option in options)
              MenuItemButton(
                onPressed: () => onSelect(option),
                trailingIcon: option == current ? const Icon(FlowboardIcons.check, size: 18) : null,
                child: Text(optionLabel(option)),
              ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return Semantics(
              button: true,
              label: label,
              value: text,
              child: InkWell(
                borderRadius: AppShapes.extraSmall,
                onTap: () => controller.isOpen ? controller.close() : controller.open(),
                child: InputDecorator(
                  isEmpty: text == null,
                  isFocused: controller.isOpen,
                  decoration: InputDecoration(labelText: label, suffixIcon: const Icon(FlowboardIcons.arrowDropDown)),
                  child: Text(
                    text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
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

/// Read-only field that opens the date picker; dates before [minDate] cannot be picked.
class RequestDateField extends StatelessWidget {
  /// Creates the field.
  const RequestDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.minDate,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onValueChange;
  final DateTime? minDate;
  final bool isError;
  final String? supportingText;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime first = minDate ?? DateTime(2000);
    DateTime initial = value ?? minDate ?? DateTime(now.year, now.month, now.day);
    if (initial.isBefore(first)) initial = first;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onValueChange(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? current = value;
    return _PickerField(
      label: label,
      text: current == null ? '' : RequestFormatters.date(current),
      icon: FlowboardIcons.calendar,
      isError: isError,
      supportingText: supportingText,
      onTap: () => _pick(context),
    );
  }
}

/// Read-only field that opens a 24-hour time picker.
class RequestTimeField extends StatelessWidget {
  /// Creates the field.
  const RequestTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final RequestTime? value;
  final ValueChanged<RequestTime> onValueChange;
  final bool isError;
  final String? supportingText;

  Future<void> _pick(BuildContext context) async {
    final RequestTime current = value ?? RequestTime(9, 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      helpText: label,
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) onValueChange(RequestTime(picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final RequestTime? current = value;
    return _PickerField(
      label: label,
      text: current == null ? '' : RequestFormatters.time(current),
      icon: FlowboardIcons.schedule,
      isError: isError,
      supportingText: supportingText,
      onTap: () => _pick(context),
    );
  }
}

/// Read-only field with a trailing icon that opens a picker when tapped.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.text,
    required this.icon,
    required this.isError,
    required this.supportingText,
    required this.onTap,
  });

  final String label;
  final String text;
  final IconData icon;
  final bool isError;
  final String? supportingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      value: text,
      child: InkWell(
        borderRadius: AppShapes.extraSmall,
        onTap: onTap,
        child: InputDecorator(
          isEmpty: text.isEmpty,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(icon),
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

/// Row with a title, an optional description and a switch.
class RequestSwitchRow extends StatelessWidget {
  /// Creates the row.
  const RequestSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return MergeSemantics(
      child: Row(
        spacing: AppSpacing.l,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(title, style: theme.textTheme.bodyLarge),
                if (description != null)
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Input for one dynamic field of a request type, chosen by the data type of the field.
class DynamicFieldInput extends StatelessWidget {
  /// Creates the input; [value] is the text kept by the view model.
  const DynamicFieldInput({
    super.key,
    required this.field,
    required this.value,
    required this.onValueChange,
    this.error,
  });

  final RequestField field;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;

  static const int _maxText = 500;

  @override
  Widget build(BuildContext context) {
    final String label = field.isRequired ? field.label : '${field.label} (opcional)';
    switch (field.dataType) {
      case FieldDataType.date:
        final DateTime? day = DateTime.tryParse(value);
        return RequestDateField(
          label: label,
          value: day,
          onValueChange: (DateTime date) => onValueChange(_isoDate(date)),
          isError: error != null,
          supportingText: error,
        );
      case FieldDataType.time:
        return RequestTimeField(
          label: label,
          value: RequestTime.tryParse(value),
          onValueChange: (RequestTime time) => onValueChange(time.format()),
          isError: error != null,
          supportingText: error,
        );
      case FieldDataType.boolean:
        return RequestSwitchRow(
          title: label,
          description: error,
          value: value.toLowerCase() == 'true',
          onChanged: (bool checked) => onValueChange(checked.toString()),
        );
      case FieldDataType.number:
      case FieldDataType.money:
        return RequestTextField(
          label: label,
          value: value,
          onValueChange: onValueChange,
          error: error,
          prefixText: field.dataType == FieldDataType.money ? 'S/ ' : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
        );
      case FieldDataType.text:
        return RequestTextField(
          label: label,
          value: value,
          onValueChange: onValueChange,
          error: error,
          maxLength: _maxText,
          minLines: 3,
        );
    }
  }

  static String _isoDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}
