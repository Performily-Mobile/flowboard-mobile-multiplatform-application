import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';

/// Benefits of an employee (US40).
///
/// [current] holds the assigned ones that are not delivered and still valid; [delivered] the ones
/// already delivered, from the most recent to the oldest.
class EmployeeBenefits {
  /// Creates the benefits.
  const EmployeeBenefits({required this.employeeId, required this.current, required this.delivered});

  final int employeeId;
  final List<BenefitAssignment> current;
  final List<BenefitAssignment> delivered;
}
