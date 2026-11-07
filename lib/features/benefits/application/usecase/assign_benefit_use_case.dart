import 'package:flowboard/features/benefits/application/usecase/decimal_rules.dart';
import 'package:flowboard/features/benefits/domain/entity/assignment_batch.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_target.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

/// Part of the assignment form a validation error belongs to.
enum AssignmentField { type, quantity, dates }

/// First problem found in an assignment, with its [field].
class AssignmentValidationError {
  /// Creates the error.
  const AssignmentValidationError(this.field, this.message);

  final AssignmentField field;
  final String message;
}

/// Assigns a benefit to one employee or to a whole area (MA-61, US38).
///
/// Mirrors the backend validation: active type, positive quantity with up to 2 decimals and
/// 10 integer digits (a whole number when measured in units) and an end date not before the start.
class AssignBenefitUseCase {
  /// Creates the use case.
  const AssignBenefitUseCase({required this.repository});

  final BenefitAssignmentRepository repository;

  static const int _maxDecimals = 2;
  static const int _maxIntegerDigits = 10;

  /// Assigns the benefit; throws [ArgumentError] when a rule fails.
  Future<AssignmentBatch> execute(
    BenefitType benefitType,
    AssignmentTarget target,
    double quantity,
    DateTime startDate,
    DateTime endDate,
  ) {
    final AssignmentValidationError? error = validate(benefitType, quantity, startDate, endDate);
    if (error != null) throw ArgumentError(error.message);
    return repository.assign(benefitType.id, target, quantity, startDate, endDate);
  }

  /// First problem of the assignment together with its field, or null when it is valid.
  static AssignmentValidationError? validate(
    BenefitType benefitType,
    double quantity,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!benefitType.active) {
      return const AssignmentValidationError(AssignmentField.type, 'Este beneficio está inactivo y no se puede asignar.');
    }
    if (quantity <= 0) {
      return const AssignmentValidationError(AssignmentField.quantity, 'La cantidad debe ser mayor que cero.');
    }
    final int decimals = DecimalRules.decimals(quantity);
    if (decimals > _maxDecimals) {
      return const AssignmentValidationError(AssignmentField.quantity, 'Usa como máximo 2 decimales.');
    }
    if (DecimalRules.integerDigits(quantity) > _maxIntegerDigits) {
      return const AssignmentValidationError(AssignmentField.quantity, 'La cantidad admite hasta 10 dígitos enteros.');
    }
    if (benefitType.unit == BenefitUnit.units && decimals > 0) {
      return const AssignmentValidationError(AssignmentField.quantity, 'Las unidades deben ser un número entero.');
    }
    if (endDate.isBefore(startDate)) {
      return const AssignmentValidationError(AssignmentField.dates, 'La fecha final no puede ser anterior a la inicial.');
    }
    return null;
  }
}
