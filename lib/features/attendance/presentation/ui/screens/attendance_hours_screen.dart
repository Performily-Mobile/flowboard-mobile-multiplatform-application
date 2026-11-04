import 'package:flutter/material.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';

class AttendanceHoursScreen extends StatelessWidget {
  const AttendanceHoursScreen({super.key});

  @override
  Widget build(BuildContext context) => const AttendanceScreen(reportOnly: true);
}