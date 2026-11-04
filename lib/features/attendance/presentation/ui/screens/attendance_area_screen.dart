import 'package:flutter/material.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';

class AttendanceAreaScreen extends StatelessWidget {
  const AttendanceAreaScreen({super.key});

  @override
  Widget build(BuildContext context) => const AttendanceScreen(reportOnly: true);
}