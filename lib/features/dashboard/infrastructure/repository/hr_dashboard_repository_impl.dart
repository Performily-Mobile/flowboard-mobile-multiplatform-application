import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/domain/repository/hr_dashboard_repository.dart';
import 'package:flowboard/features/dashboard/infrastructure/mapper/dashboard_mapper.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_request_dto.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_request_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_vacation_service.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_current_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';

/// Reads from Workspace through its use cases, and from Attendance, Request and Benefits through
/// small services of its own, because those contexts are not part of this app yet.
class HrDashboardRepositoryImpl implements HrDashboardRepository {
  /// Creates the repository.
  const HrDashboardRepositoryImpl({
    required this.getCurrentEmployee,
    required this.getAreas,
    required this.getEmployees,
    required this.currentEmployeeProvider,
    required this.attendanceService,
    required this.requestService,
    required this.vacationService,
  });

  final GetCurrentEmployeeUseCase getCurrentEmployee;
  final GetAreasUseCase getAreas;
  final GetEmployeesUseCase getEmployees;
  final CurrentEmployeeProvider currentEmployeeProvider;
  final DashboardAttendanceService attendanceService;
  final DashboardRequestService requestService;
  final DashboardVacationService vacationService;

  @override
  Future<String> getCurrentUserFirstName() async => (await getCurrentEmployee.execute()).name.firstName;

  @override
  Future<List<DashboardArea>> getActiveAreas() async {
    final areas = await getAreas.execute(onlyActive: true);
    return areas.map(DashboardMapper.toArea).toList();
  }

  @override
  Future<AttendanceSummary> getAttendanceSummary(int areaId, DateTime from, DateTime to) async {
    return DashboardMapper.toSummary(
      await attendanceService.getAreaSummary(areaId, DashboardMapper.formatDate(from), DashboardMapper.formatDate(to)),
    );
  }

  @override
  Future<List<RequestToAttend>> getRequestsToAttend() async {
    final List<DashboardRequestDto> pending = switch (currentEmployeeProvider.currentRole()) {
      UserRole.humanResources => await requestService.getPendingForHrStaff(),
      UserRole.employee => await requestService.getPendingForApprover(currentEmployeeProvider.currentEmployeeId().value),
    };
    final Map<int, Employee> people = await _people();
    final List<DashboardRequestDto> oldestFirst = <DashboardRequestDto>[...pending]
      ..sort((DashboardRequestDto a, DashboardRequestDto b) =>
          DashboardMapper.submittedAt(a).compareTo(DashboardMapper.submittedAt(b)));
    return oldestFirst
        .map((DashboardRequestDto dto) => DashboardMapper.toRequestToAttend(dto, people[dto.requesterId]))
        .toList();
  }

  @override
  Future<List<double>> getAvailableVacationDays() => vacationService.getAvailableDays();

  /// Employees by identifier, to name the requesters; empty when Workspace fails.
  Future<Map<int, Employee>> _people() async {
    try {
      final List<Employee> employees = await getEmployees.execute();
      return <int, Employee>{for (final Employee employee in employees) employee.id.value: employee};
    } catch (_) {
      return <int, Employee>{};
    }
  }
}
