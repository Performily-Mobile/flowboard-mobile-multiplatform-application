import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_formatters.dart';

/// Text field whose value is kept by the view model.
class AttendanceTextField extends StatefulWidget {
  /// Creates the field; [minLines] above one makes it multiline.
  const AttendanceTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.error,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.minLines = 1,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;
  final String? helperText;
  final TextInputType keyboardType;
  final int? maxLength;
  final int minLines;
  final bool enabled;

  @override
  State<AttendanceTextField> createState() => _AttendanceTextFieldState();
}

class _AttendanceTextFieldState extends State<AttendanceTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(AttendanceTextField oldWidget) {
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
      textCapitalization: multiline ? TextCapitalization.sentences : TextCapitalization.none,
      inputFormatters: <TextInputFormatter>[
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      minLines: widget.minLines,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.error,
        helperText: widget.helperText,
        errorMaxLines: 2,
        helperMaxLines: 2,
      ),
    );
  }
}

/// Read-only field that opens a menu with [options] and shows the [selected] one.
class AttendanceSelectField<T> extends StatelessWidget {
  /// Creates the field.
  const AttendanceSelectField({
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

/// Horizontal row of chips that scrolls when they do not fit.
class AttendanceChipRow extends StatelessWidget {
  /// Creates the row.
  const AttendanceChipRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(spacing: AppSpacing.s, children: children),
    );
  }
}

/// Chip that shows the period and opens the date range picker.
class AttendancePeriodChip extends StatelessWidget {
  /// Creates the chip.
  const AttendancePeriodChip({super.key, required this.period, required this.onSelect});

  final AttendancePeriod period;
  final ValueChanged<AttendancePeriod> onSelect;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: DateTimeRange(
        start: period.from.isAfter(today) ? today : period.from,
        end: period.to.isAfter(today) ? today : period.to,
      ),
      helpText: 'Periodo',
      saveText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onSelect(AttendancePeriod(from: picked.start, to: picked.end));
  }

  @override
  Widget build(BuildContext context) {
    final String label = AttendanceFormatters.period(period);
    return FilterChip(
      selected: true,
      showCheckmark: false,
      avatar: const Icon(FlowboardIcons.calendar, size: 18),
      label: Text(label),
      tooltip: 'Cambiar periodo: $label',
      onSelected: (bool _) => _pick(context),
    );
  }
}

/// Filter chip that opens a menu to pick one of [options].
class AttendanceMenuChip<T> extends StatelessWidget {
  /// Creates the chip.
  const AttendanceMenuChip({
    super.key,
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.onSelect,
    this.selected = true,
  });

  final String label;
  final List<T> options;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        for (final T option in options)
          MenuItemButton(onPressed: () => onSelect(option), child: Text(optionLabel(option))),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        void toggle() => controller.isOpen ? controller.close() : controller.open();
        return FilterChip(
          selected: selected,
          showCheckmark: false,
          label: Text(label),
          onSelected: (bool _) => toggle(),
          deleteIcon: const Icon(FlowboardIcons.arrowDropDown, size: 18),
          deleteButtonTooltipMessage: label,
          onDeleted: toggle,
        );
      },
    );
  }
}

/// Chips to filter the records by status.
class AttendanceStatusFilterChips extends StatelessWidget {
  /// Creates the chips.
  const AttendanceStatusFilterChips({super.key, required this.selected, required this.onSelect});

  final AttendanceStatusFilter selected;
  final ValueChanged<AttendanceStatusFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return AttendanceChipRow(
      children: <Widget>[
        for (final AttendanceStatusFilter filter in AttendanceStatusFilter.values)
          FilterChip(
            label: Text(filter.label),
            selected: selected == filter,
            onSelected: (bool _) => onSelect(filter),
          ),
      ],
    );
  }
}
