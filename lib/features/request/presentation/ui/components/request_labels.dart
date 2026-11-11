import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';

/// Spanish label of the request status.
extension RequestStatusLabel on RequestStatus {
  /// Text shown to the user.
  String get label => switch (this) {
        RequestStatus.inProgress => 'Pendiente',
        RequestStatus.underReview => 'En revisión',
        RequestStatus.approved => 'Aprobada',
        RequestStatus.rejected => 'Rechazada',
        RequestStatus.cancelled => 'Cancelada',
      };
}

/// Spanish labels of the balance deduction.
extension BalanceDeductionLabel on BalanceDeduction {
  /// Short text of the selector.
  String get label => switch (this) {
        BalanceDeduction.none => 'Ninguno',
        BalanceDeduction.vacationDays => 'Vacaciones',
        BalanceDeduction.benefitBalance => 'Beneficio',
      };

  /// Text shown in the catalog of request types.
  String get catalogLabel => switch (this) {
        BalanceDeduction.none => 'Sin descuento de saldo',
        BalanceDeduction.vacationDays => 'Descuenta días de vacaciones',
        BalanceDeduction.benefitBalance => 'Descuenta saldo de beneficio',
      };
}

/// Spanish label of the data type of a field.
extension FieldDataTypeLabel on FieldDataType {
  /// Text shown to the user.
  String get label => switch (this) {
        FieldDataType.text => 'Texto',
        FieldDataType.number => 'Número',
        FieldDataType.date => 'Fecha',
        FieldDataType.time => 'Hora',
        FieldDataType.money => 'Monto',
        FieldDataType.boolean => 'Sí / No',
      };
}
