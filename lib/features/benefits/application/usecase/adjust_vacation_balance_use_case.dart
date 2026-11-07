import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/benefits/application/usecase/decimal_rules.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/repository/vacation_balance_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';

/// Field of the adjustment form a validation error belongs to.
enum AdjustmentField { days, reason }

/// Validation error of an adjustment, with the affected [field] so the screen flags it.
class AdjustmentValidationError extends ArgumentError {
  /// Creates the error with its Spanish [message].
  AdjustmentValidationError(this.field, String message) : super(message);

  final AdjustmentField field;
}

/// Manual adjustment of a vacation balance (MA-63, US42).
///
/// Requires a reason, records who performed it and can never leave the balance negative.
class AdjustVacationBalanceUseCase {
  /// Creates the use case.
  const AdjustVacationBalanceUseCase({required this.repository, required this.currentEmployeeProvider});

  final VacationBalanceRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  static const int _maxReason = 250;
  static const int _maxDecimals = 2;
  static const int _maxIntegerDigits = 4;

  /// Adjusts [balance]; throws [AdjustmentValidationError] when a rule fails.
  Future<VacationBalance> execute(
    VacationBalance balance,
    AdjustmentOperation operation,
    double days,
    String reason,
  ) {
    final String cleanReason = reason.trim();
    final AdjustmentValidationError? error = switch (true) {
      _ when days <= 0 => AdjustmentValidationError(AdjustmentField.days, 'Ingresa una cantidad mayor que cero.'),
      _ when DecimalRules.decimals(days) > _maxDecimals =>
        AdjustmentValidationError(AdjustmentField.days, 'Usa como máximo 2 decimales.'),
      _ when DecimalRules.integerDigits(days) > _maxIntegerDigits =>
        AdjustmentValidationError(AdjustmentField.days, 'La cantidad admite hasta 4 dígitos enteros.'),
      _ when cleanReason.isEmpty => AdjustmentValidationError(AdjustmentField.reason, 'Ingresa el motivo del ajuste.'),
      _ when cleanReason.length > _maxReason =>
        AdjustmentValidationError(AdjustmentField.reason, 'El motivo admite hasta $_maxReason caracteres.'),
      _ when operation == AdjustmentOperation.deduct && days > balance.availableDays =>
        AdjustmentValidationError(AdjustmentField.days, 'No puede descontar más de los días disponibles.'),
      _ => null,
    };
    if (error != null) throw error;
    return repository.adjust(
      balance.employeeId,
      operation,
      days,
      cleanReason,
      currentEmployeeProvider.currentEmployeeId().value,
    );
  }
}
