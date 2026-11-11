import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/domain/repository/hr_dashboard_repository.dart';
import 'package:flowboard/features/dashboard/infrastructure/mapper/dashboard_mapper.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_attendance_service.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_vacation_service.dart';
import 'package:flowboard/features/request/application/usecase/get_pending_approvals_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_page.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_current_employee_use_case.dart';

/// Reads from Workspace and Request through their use cases, and from Attendance and Benefits
/// through small services of its own.
class HrDashboardRepositoryImpl implements HrDashboardRepository {
  /// Creates the repository.
  const HrDashboardRepositoryImpl({
    required this.getCurrentEmployee,
    required this.getAreas,
    required this.getPendingApprovals,
    required this.attendanceService,
    required this.vacationService,
  });

  final GetCurrentEmployeeUseCase getCurrentEmployee;
  final GetAreasUseCase getAreas;
  final GetPendingApprovalsUseCase getPendingApprovals;
  final DashboardAttendanceService attendanceService;
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
  Future<PendingRequests> getRequestsToAttend() async {
    final RequestPage page = await getPendingApprovals.execute();
    final List<Request> oldestFirst = <Request>[...page.items]
      ..sort((Request a, Request b) => a.submittedAt.compareTo(b.submittedAt));
    return PendingRequests(
      total: page.totalItems,
      oldest: oldestFirst.map(DashboardMapper.toRequestToAttend).toList(),
    );
  }

  @override
  Future<List<double>> getAvailableVacationDays() => vacationService.getAvailableDays();
}
