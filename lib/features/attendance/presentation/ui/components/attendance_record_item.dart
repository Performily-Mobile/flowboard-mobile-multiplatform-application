import 'package:flutter/material.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'attendance_status_chip.dart';

class AttendanceRecordItem extends StatelessWidget {
  const AttendanceRecordItem({
    super.key,
    required this.record,
    this.onTap,
  });

  final AttendanceRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          title: Text(record.employeeName ?? record.workDate),
          subtitle: Text(
            '${record.workDate} · ${record.checkInTime ?? "--"} / ${record.checkOutTime ?? "--"}',
          ),
          trailing: AttendanceStatusChip(label: record.statusLabel),
        ),
      );
}