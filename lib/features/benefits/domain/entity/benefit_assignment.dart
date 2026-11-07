import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

/// A benefit assigned to an employee (US38), with its delivery once it was made (US39).
class BenefitAssignment {
  /// Creates the assignment.
  const BenefitAssignment({
    required this.id,
    required this.benefitTypeId,
    required this.benefitTypeName,
    required this.unit,
    required this.employeeId,
    required this.employeeName,
    required this.sourceAreaId,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.delivery,
  });

  final int id;
  final int benefitTypeId;
  final String benefitTypeName;
  final BenefitUnit unit;
  final int employeeId;
  final String employeeName;
  final int? sourceAreaId;
  final double quantity;
  final DateTime startDate;
  final DateTime endDate;
  final AssignmentStatus status;
  final BenefitDelivery? delivery;

  /// Only a pending assignment accepts its delivery, and only once.
  bool get canBeDelivered => status == AssignmentStatus.assigned;

  @override
  bool operator ==(Object other) => other is BenefitAssignment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Delivery of an assigned benefit (US39).
class BenefitDelivery {
  /// Creates the delivery.
  const BenefitDelivery({required this.deliveredOn, required this.registeredById, required this.notes});

  final DateTime deliveredOn;
  final int? registeredById;
  final String? notes;
}
