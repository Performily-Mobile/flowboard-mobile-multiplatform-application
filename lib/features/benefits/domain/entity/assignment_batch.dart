import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';

/// Result of an assignment: how many employees received the benefit and how many were skipped
/// because they already had it.
class AssignmentBatch {
  /// Creates the result.
  const AssignmentBatch({
    required this.areaId,
    required this.assignedCount,
    required this.skippedCount,
    required this.assignments,
  });

  final int? areaId;
  final int assignedCount;
  final int skippedCount;
  final List<BenefitAssignment> assignments;
}
