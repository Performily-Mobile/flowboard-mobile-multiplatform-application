import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/my_attendance_view.dart';

/// Own attendance of an HR staff member, opened from "Más". HR staff are also employees, so they
/// punch and justify their days here.
class MyAttendanceScreen extends StatelessWidget {
  /// Creates the screen.
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Mi asistencia', onBack: () => Navigator.of(context).maybePop()),
          const Expanded(child: MyAttendanceView()),
        ],
      ),
    );
  }
}
