import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_period.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_area_report_screen.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_screen.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/employee_attendance_screen.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/justify_attendance_screen.dart';

/// Routes of the Attendance bounded context.
///
/// The "Asistencia" tab and the area report opened from the dashboard reuse the names of the core
/// navigation. The justification is a full-screen
/// form pushed on the root navigator, so the bottom bar is hidden while it is open; it closes with a
/// message for the snackbar of the previous screen.
class AttendanceRoutes {
  const AttendanceRoutes._();

  static const String attendance = AppRoutes.attendance;

  /// Area report opened from the HR dashboard.
  static const String areaReport = AppRoutes.attendanceAreaReport;

  /// Attendance of one employee; receives an [EmployeeAttendanceArgs].
  static const String employeeAttendance = '/attendance-employee';

  /// Form to justify a day; receives the [AttendanceRecord].
  static const String justify = '/justify-attendance';
}

/// Arguments of the attendance detail of one employee.
class EmployeeAttendanceArgs {
  /// Creates the arguments; [period] is the one shown by the previous screen.
  const EmployeeAttendanceArgs({required this.employeeId, required this.period});

  final int employeeId;
  final AttendancePeriod period;
}

/// Page builder of the Attendance routes, registered in the core route registry.
class AttendanceNavigation {
  const AttendanceNavigation._();

  /// Page of [settings], or null when the route does not belong to Attendance.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case AttendanceRoutes.attendance:
        return const AttendanceScreen();
      case AttendanceRoutes.areaReport:
        return const AttendanceAreaReportScreen();
      case AttendanceRoutes.employeeAttendance:
        final EmployeeAttendanceArgs args = settings.arguments as EmployeeAttendanceArgs;
        return EmployeeAttendanceScreen(employeeId: args.employeeId, period: args.period);
      case AttendanceRoutes.justify:
        return JustifyAttendanceScreen(record: settings.arguments as AttendanceRecord);
    }
    return null;
  }
}
