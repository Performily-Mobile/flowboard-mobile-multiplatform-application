import 'package:flowboard/features/dashboard/domain/entity/dashboard_sources.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/domain/repository/hr_dashboard_repository.dart';

/// Assembles the HR dashboard by querying every source in parallel.
///
/// If one source fails, only its section is left empty and the rest is still shown.
class GetHrDashboardUseCase {
  /// Creates the use case.
  const GetHrDashboardUseCase({required this.repository});

  final HrDashboardRepository repository;

  /// Unused vacation days from which an employee is flagged: it must be taken before it expires.
  static const int expiringVacationDays = 30;
  static const int _maxRequestsToAttend = 3;

  /// Builds the dashboard; [today] is the reference date of the daily attendance and the monthly
  /// lateness. Sections that failed are null.
  Future<HrDashboard> execute({DateTime? today}) async {
    final DateTime now = DateTime.now();
    final DateTime day = _dateOnly(today ?? now);

    final Future<String?> firstName = _attempt(repository.getCurrentUserFirstName);
    final Future<PendingRequests?> requests = _attempt(repository.getRequestsToAttend);
    final Future<List<double>?> vacationDays = _attempt(repository.getAvailableVacationDays);
    final List<DashboardArea>? areas = await _attempt(repository.getActiveAreas);

    final Future<List<AreaAttendance>?> todayAttendance =
        areas == null ? Future<List<AreaAttendance>?>.value(null) : _todayAttendance(areas, day);
    final Future<MonthlyLateness?> monthlyLateness =
        areas == null ? Future<MonthlyLateness?>.value(null) : _monthlyLateness(areas, day);

    final PendingRequests? pending = await requests;
    final List<double>? balances = await vacationDays;

    return HrDashboard(
      userFirstName: await firstName,
      activeEmployees: areas?.fold<int>(0, (int total, DashboardArea area) => total + area.activeEmployees),
      pendingRequests: pending?.total,
      monthlyLateness: await monthlyLateness,
      expiringVacations: balances?.where((double days) => days >= expiringVacationDays).length,
      todayAttendance: await todayAttendance,
      requestsToAttend: pending?.oldest.take(_maxRequestsToAttend).toList(),
      loadedAt: DateTime.now(),
    );
  }

  /// Employees who checked in today over the active employees of each area.
  ///
  /// Active employees are the denominator instead of attendance records because absences are
  /// only registered when the day closes, which would inflate the percentage. Returns null when
  /// every area failed to load.
  Future<List<AreaAttendance>?> _todayAttendance(List<DashboardArea> areas, DateTime today) async {
    final List<AreaAttendance?> results = await Future.wait(
      areas.where((DashboardArea area) => area.activeEmployees > 0).map((DashboardArea area) async {
        final AttendanceSummary? summary = await _attempt(() => repository.getAttendanceSummary(area.id, today, today));
        if (summary == null) return null;
        return AreaAttendance(
          areaId: area.id,
          areaName: area.name,
          percentage: (summary.checkIns * 100.0 / area.activeEmployees).round().clamp(0, 100).toInt(),
        );
      }),
    );
    if (results.isNotEmpty && results.every((AreaAttendance? result) => result == null)) return null;
    return results.whereType<AreaAttendance>().toList();
  }

  /// Late check-ins from the first day of the month until today across all areas, or null when
  /// every area failed to load.
  Future<MonthlyLateness?> _monthlyLateness(List<DashboardArea> areas, DateTime today) async {
    final DateTime firstDay = DateTime(today.year, today.month, 1);
    final List<AttendanceSummary?> results = await Future.wait(
      areas.map((DashboardArea area) => _attempt(() => repository.getAttendanceSummary(area.id, firstDay, today))),
    );
    if (results.isNotEmpty && results.every((AttendanceSummary? result) => result == null)) return null;
    final List<AttendanceSummary> summaries = results.whereType<AttendanceSummary>().toList();
    return MonthlyLateness(
      lateCount: summaries.fold<int>(0, (int total, AttendanceSummary summary) => total + summary.late),
      checkInCount: summaries.fold<int>(0, (int total, AttendanceSummary summary) => total + summary.checkIns),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static Future<T?> _attempt<T>(Future<T> Function() block) async {
    try {
      return await block();
    } catch (_) {
      return null;
    }
  }
}
