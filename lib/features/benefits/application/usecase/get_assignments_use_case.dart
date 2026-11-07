import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';

/// Assignments to deliver or already delivered (MA-62).
///
/// Delivered ones go from the most recent delivery; the rest are sorted by employee and benefit.
class GetAssignmentsUseCase {
  /// Creates the use case.
  const GetAssignmentsUseCase({required this.repository});

  final BenefitAssignmentRepository repository;

  /// Assignments with the [status], sorted for the list.
  Future<List<BenefitAssignment>> execute(AssignmentStatus status) async {
    final List<BenefitAssignment> assignments = await repository.getAssignments(status);
    if (status == AssignmentStatus.delivered) {
      final DateTime oldest = DateTime(1970);
      return assignments
        ..sort((BenefitAssignment a, BenefitAssignment b) =>
            (b.delivery?.deliveredOn ?? oldest).compareTo(a.delivery?.deliveredOn ?? oldest));
    }
    return assignments
      ..sort((BenefitAssignment a, BenefitAssignment b) {
        final int byEmployee = a.employeeName.toLowerCase().compareTo(b.employeeName.toLowerCase());
        return byEmployee != 0 ? byEmployee : a.benefitTypeName.toLowerCase().compareTo(b.benefitTypeName.toLowerCase());
      });
  }
}
