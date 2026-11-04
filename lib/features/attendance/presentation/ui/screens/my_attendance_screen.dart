import 'package:flutter/material.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';

class MyAttendanceScreen extends StatelessWidget {
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const AttendanceScreen(reportOnly: false);
}