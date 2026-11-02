import 'package:flowboard/features/workspace/domain/valueobject/assignment_change_type.dart';

/// Entry of the job assignment history of an employee.
class JobAssignment {
  /// Creates the entry.
  const JobAssignment({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.positionId,
    required this.positionTitle,
    required this.changeType,
    required this.startDate,
    required this.endDate,
    required this.current,
  });

  final int id;
  final int areaId;
  final String areaName;
  final int positionId;
  final String positionTitle;
  final AssignmentChangeType changeType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
}
