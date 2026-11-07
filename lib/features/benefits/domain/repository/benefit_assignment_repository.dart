import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/assignment_batch.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_target.dart';

/// Repository of the benefit assignments and their deliveries.
abstract class BenefitAssignmentRepository {
  /// Assignments with the [status], or all of them when it is null.
  Future<List<BenefitAssignment>> getAssignments(AssignmentStatus? status);

  /// Current and delivered benefits of the employee [employeeId].
  Future<EmployeeBenefits> getEmployeeBenefits(int employeeId);

  /// How many employees of the area [areaId] would receive the benefit in the period.
  Future<AreaAssignmentPreview> previewAreaAssignment(
    int benefitTypeId,
    int areaId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Assigns the benefit [benefitTypeId] to the [target].
  Future<AssignmentBatch> assign(
    int benefitTypeId,
    AssignmentTarget target,
    double quantity,
    DateTime startDate,
    DateTime endDate,
  );

  /// Registers the delivery of the assignment [assignmentId].
  Future<BenefitAssignment> registerDelivery(int assignmentId, DateTime deliveredOn, int registeredById, String? notes);
}
