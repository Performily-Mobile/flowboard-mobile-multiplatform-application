import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';

/// Registers the delivery of a benefit (MA-62, US39).
///
/// Only once per assignment and with a date between the start of the validity and today. The one
/// who registers it is the HR user using the app.
class RegisterDeliveryUseCase {
  /// Creates the use case.
  const RegisterDeliveryUseCase({required this.repository, required this.currentEmployeeProvider});

  final BenefitAssignmentRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  /// Registers the delivery; throws [StateError] or [ArgumentError] when a rule fails.
  Future<BenefitAssignment> execute(BenefitAssignment assignment, DateTime deliveredOn, String? notes, {DateTime? today}) {
    final DateTime now = today ?? DateTime.now();
    final DateTime currentDay = DateTime(now.year, now.month, now.day);
    if (!assignment.canBeDelivered) throw StateError('Este beneficio ya fue entregado o anulado.');
    if (deliveredOn.isAfter(currentDay)) throw ArgumentError('La fecha de entrega no puede ser futura.');
    if (deliveredOn.isBefore(assignment.startDate)) {
      throw ArgumentError('La fecha de entrega no puede ser anterior al inicio de la vigencia.');
    }
    final String? cleanNotes = notes?.trim();
    return repository.registerDelivery(
      assignment.id,
      deliveredOn,
      currentEmployeeProvider.currentEmployeeId().value,
      cleanNotes == null || cleanNotes.isEmpty ? null : cleanNotes,
    );
  }
}
