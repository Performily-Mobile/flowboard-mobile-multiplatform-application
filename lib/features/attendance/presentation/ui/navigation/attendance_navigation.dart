import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_home_screen.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_area_screen.dart';

class AttendanceNavigation {
  static Widget? pageFor(RouteSettings settings) => switch (settings.name) {
        AppRoutes.attendance => const AttendanceHomeScreen(),
        AppRoutes.attendanceAreaReport => const AttendanceAreaScreen(),
        _ => null,
      };
}