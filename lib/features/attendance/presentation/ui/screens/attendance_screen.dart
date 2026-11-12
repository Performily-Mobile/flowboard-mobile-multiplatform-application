import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/my_attendance_view.dart';

/// "Asistencia" tab: the attendance of the signed-in employee, with today's punch and their records.
class AttendanceScreen extends StatelessWidget {
  /// Creates the screen.
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Asistencia'),
          Expanded(child: MyAttendanceView()),
        ],
      ),
    );
  }
}
