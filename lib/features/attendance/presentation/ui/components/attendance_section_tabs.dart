import 'package:flutter/material.dart';

class AttendanceSectionTabs extends StatelessWidget {
  const AttendanceSectionTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Mi asistencia')),
          ButtonSegment(value: 1, label: Text('Personal')),
          ButtonSegment(value: 2, label: Text('Áreas')),
        ],
        selected: {selected},
        onSelectionChanged: (v) => onChanged(v.first),
      );
}