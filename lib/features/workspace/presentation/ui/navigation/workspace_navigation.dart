import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/edit_personal_data_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/employee_detail_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/employees_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/my_profile_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/my_record_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/organization_chart_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/organization_screen.dart';
import 'package:flowboard/features/workspace/presentation/ui/screens/register_employee_screen.dart';

/// Routes of the Workspace bounded context.
///
/// The tab roots ("Personal" for HR and "Perfil" for employees) and "Organización" reuse the
/// names of the core navigation. Registration and personal data are full-screen forms pushed on
/// the root navigator, so the bottom bar is hidden while they are open.
class WorkspaceRoutes {
  const WorkspaceRoutes._();

  static const String employees = AppRoutes.employees;
  static const String registerEmployee = '/register-employee';
  static const String employeeDetail = '/employee-detail';
  static const String editPersonalData = '/edit-personal-data';
  static const String organization = AppRoutes.organization;
  static const String organizationChart = '/organization-chart';
  static const String myProfile = AppRoutes.myProfile;
  static const String myRecord = '/my-record';
}

/// Arguments of [WorkspaceRoutes.employeeDetail].
class EmployeeDetailArgs {
  /// Creates the arguments; [openReassign] opens the reassign sheet once the record is loaded.
  const EmployeeDetailArgs({required this.employeeId, this.openReassign = false});

  final int employeeId;
  final bool openReassign;
}

/// Arguments of [WorkspaceRoutes.editPersonalData].
class EditPersonalDataArgs {
  /// Creates the arguments.
  const EditPersonalDataArgs({required this.employeeId});

  final int employeeId;
}

/// Arguments of [WorkspaceRoutes.organizationChart].
class OrganizationChartArgs {
  /// Creates the arguments; without an area the whole organization is shown.
  const OrganizationChartArgs({this.areaId, this.highlightedEmployeeId});

  final int? areaId;
  final int? highlightedEmployeeId;
}

/// Page builder of the Workspace routes, registered in the core route registry.
class WorkspaceNavigation {
  const WorkspaceNavigation._();

  /// Page of [settings], or null when the route does not belong to Workspace.
  static Widget? pageFor(RouteSettings settings) {
    final Object? arguments = settings.arguments;
    switch (settings.name) {
      case WorkspaceRoutes.employees:
        return const EmployeesScreen();
      case WorkspaceRoutes.registerEmployee:
        return const RegisterEmployeeScreen();
      case WorkspaceRoutes.employeeDetail:
        final EmployeeDetailArgs detailArgs = arguments as EmployeeDetailArgs;
        return EmployeeDetailScreen(employeeId: detailArgs.employeeId, openReassignOnStart: detailArgs.openReassign);
      case WorkspaceRoutes.editPersonalData:
        final EditPersonalDataArgs editArgs = arguments as EditPersonalDataArgs;
        return EditPersonalDataScreen(employeeId: editArgs.employeeId);
      case WorkspaceRoutes.organization:
        return const OrganizationScreen();
      case WorkspaceRoutes.organizationChart:
        final OrganizationChartArgs chartArgs =
            arguments is OrganizationChartArgs ? arguments : const OrganizationChartArgs();
        return OrganizationChartScreen(areaId: chartArgs.areaId, highlightedEmployeeId: chartArgs.highlightedEmployeeId);
      case WorkspaceRoutes.myProfile:
        return const MyProfileScreen();
      case WorkspaceRoutes.myRecord:
        return const MyRecordScreen();
    }
    return null;
  }
}
