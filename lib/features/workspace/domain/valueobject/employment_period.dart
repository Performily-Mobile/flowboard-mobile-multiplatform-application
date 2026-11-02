import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';

/// Hire date and, for fixed-term contracts, the end date of the contract.
class EmploymentPeriod {
  /// Creates the period; throws [ArgumentError] when the end date is before the hire date.
  EmploymentPeriod({required this.hireDate, this.contractEndDate}) {
    if (contractEndDate != null && contractEndDate!.isBefore(hireDate)) {
      throw ArgumentError('La fecha de fin de contrato no puede ser anterior a la fecha de ingreso.');
    }
  }

  /// Creates the period checking the rules of the [contractType]; a fixed-term contract needs an
  /// end date.
  factory EmploymentPeriod.of(ContractType contractType, DateTime hireDate, DateTime? contractEndDate) {
    if (contractType == ContractType.fixedTerm && contractEndDate == null) {
      throw ArgumentError('Un contrato a plazo fijo requiere fecha de fin.');
    }
    return EmploymentPeriod(hireDate: hireDate, contractEndDate: contractEndDate);
  }

  final DateTime hireDate;
  final DateTime? contractEndDate;

  /// True when the contract has no end date.
  bool get isOpenEnded => contractEndDate == null;
}
