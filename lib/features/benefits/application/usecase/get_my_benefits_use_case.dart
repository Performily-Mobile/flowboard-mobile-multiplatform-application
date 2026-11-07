import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';

/// Current and delivered benefits of the employee using the app (MA-58, MA-59, US40).
class GetMyBenefitsUseCase {
  /// Creates the use case.
  const GetMyBenefitsUseCase({required this.repository, required this.currentEmployeeProvider});

  final BenefitAssignmentRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Benefits of the signed-in employee.
  Future<EmployeeBenefits> execute() =>
      repository.getEmployeeBenefits(currentEmployeeProvider.currentEmployeeId().value);
}
