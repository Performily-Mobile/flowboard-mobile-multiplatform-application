import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_area_view.dart';

/// Attendance report of the areas opened from the HR dashboard, with a back arrow.
class AttendanceAreaReportScreen extends StatelessWidget {
  /// Creates the screen.
  const AttendanceAreaReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Asistencia por área', onBack: () => Navigator.of(context).maybePop()),
          const Expanded(child: AttendanceAreaView()),
        ],
      ),
    );
  }
}
