import 'package:flutter/material.dart';

class AttendanceDatePickerField extends StatelessWidget {
  const AttendanceDatePickerField({
    super.key,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  final DateTime from, to;
  final void Function(DateTime, DateTime) onChanged;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () async {
          final r = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDateRange: DateTimeRange(start: from, end: to),
          );
          if (r != null) onChanged(r.start, r.end);
        },
        icon: const Icon(Icons.date_range),
        label: Text(
          '${from.day}/${from.month}/${from.year} —${to.day}/${to.month}/${to.year}',
        ),
      );
}