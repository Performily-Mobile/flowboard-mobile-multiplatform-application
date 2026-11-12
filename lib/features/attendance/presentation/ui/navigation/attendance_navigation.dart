import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/justify_attendance_screen.dart';

/// Routes of the Attendance bounded context.
///
/// The "Asistencia" tab reuses the name of the core navigation. The justification is a full-screen
/// form pushed on the root navigator, so the bottom bar is hidden while it is open; it closes with a
/// message for the snackbar of the previous screen.
class AttendanceRoutes {
  const AttendanceRoutes._();

  static const String attendance = AppRoutes.attendance;

  /// Form to justify a day; receives the [AttendanceRecord].
  static const String justify = '/justify-attendance';
}

/// Page builder of the Attendance routes, registered in the core route registry.
class AttendanceNavigation {
  const AttendanceNavigation._();

  /// Page of [settings], or null when the route does not belong to Attendance.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case AttendanceRoutes.attendance:
        return const AttendanceScreen();
      case AttendanceRoutes.justify:
        return JustifyAttendanceScreen(record: settings.arguments as AttendanceRecord);
    }
    return null;
  }
}
