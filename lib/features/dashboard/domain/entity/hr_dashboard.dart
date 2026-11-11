/// HR dashboard indicators (MA-18).
///
/// Every section is loaded independently: a null value means that section could not be obtained.
class HrDashboard {
  /// Creates the dashboard.
  const HrDashboard({
    required this.userFirstName,
    required this.activeEmployees,
    required this.pendingRequests,
    required this.monthlyLateness,
    required this.expiringVacations,
    required this.todayAttendance,
    required this.requestsToAttend,
    required this.loadedAt,
  });

  /// First name of the signed-in user, used in the greeting.
  final String? userFirstName;

  /// Total of active employees across all active areas.
  final int? activeEmployees;

  /// Number of requests waiting in the HR inbox.
  final int? pendingRequests;

  /// Late check-ins of the current month against all check-ins.
  final MonthlyLateness? monthlyLateness;

  /// Number of employees with a full year of unused vacation.
  final int? expiringVacations;

  /// Share of active employees per area that checked in today.
  final List<AreaAttendance>? todayAttendance;

  /// Oldest pending requests shown in the dashboard.
  final List<RequestToAttend>? requestsToAttend;

  /// Moment the dashboard was assembled.
  final DateTime loadedAt;

  /// True when every section failed to load, so there is nothing to show.
  bool get hasNoData =>
      activeEmployees == null &&
      pendingRequests == null &&
      monthlyLateness == null &&
      expiringVacations == null &&
      todayAttendance == null &&
      requestsToAttend == null;
}

/// Late check-ins of the month against the total of check-ins.
class MonthlyLateness {
  /// Creates the value.
  const MonthlyLateness({required this.lateCount, required this.checkInCount});

  /// Check-ins registered after the scheduled time.
  final int lateCount;

  /// All check-ins in the period.
  final int checkInCount;

  /// Late check-ins as a percentage of all check-ins, or 0 when there are none.
  double get percentage => checkInCount == 0 ? 0 : lateCount * 100.0 / checkInCount;
}

/// Share of the active employees of an area that checked in today.
class AreaAttendance {
  /// Creates the value; [percentage] goes from 0 to 100.
  const AreaAttendance({required this.areaId, required this.areaName, required this.percentage});

  final int areaId;
  final String areaName;
  final int percentage;
}

/// Pending requests of the inbox: how many there are in total and the oldest ones.
class PendingRequests {
  /// Creates the value.
  const PendingRequests({required this.total, required this.oldest});

  /// Number of pending requests in the inbox.
  final int total;

  /// First pending requests, oldest first.
  final List<RequestToAttend> oldest;
}

/// Pending request in the HR inbox.
class RequestToAttend {
  /// Creates the request.
  const RequestToAttend({
    required this.requestId,
    required this.requesterName,
    required this.requestTypeName,
    required this.startDate,
    required this.endDate,
    required this.hours,
    required this.withoutDirectManager,
  });

  final int requestId;

  /// Full name of the employee who submitted it.
  final String requesterName;

  /// Name of the request type, for example "Vacaciones".
  final String requestTypeName;

  /// First day covered by the request, if it has a period.
  final DateTime? startDate;

  /// Last day covered by the request, if it has a period.
  final DateTime? endDate;

  /// Duration in hours for hourly permissions, null otherwise.
  final double? hours;

  /// True when the requester has no direct manager assigned.
  final bool withoutDirectManager;
}
