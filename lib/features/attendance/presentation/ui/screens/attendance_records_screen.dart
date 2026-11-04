import 'package:flutter/material.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';

class AttendanceRecordsScreen extends StatelessWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AttendanceScreen(reportOnly: false);
}