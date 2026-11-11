import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';

/// Type of request defined by HR: its fields, whether it needs an attachment and the balance it
/// discounts.
class RequestType {
  /// Creates the type.
  const RequestType({
    required this.id,
    required this.name,
    required this.description,
    required this.requiresAttachment,
    required this.balanceDeduction,
    required this.active,
    required this.fields,
  });

  final int id;
  final String name;
  final String? description;
  final bool requiresAttachment;
  final BalanceDeduction balanceDeduction;
  final bool active;
  final List<RequestField> fields;

  /// True when it discounts vacation days.
  bool get deductsVacationDays => balanceDeduction == BalanceDeduction.vacationDays;

  /// True when it discounts any balance; those requests need whole days.
  bool get deductsBalance => balanceDeduction != BalanceDeduction.none;

  /// Field with [key], or null.
  RequestField? fieldOf(String key) {
    for (final RequestField field in fields) {
      if (field.key == key) return field;
    }
    return null;
  }

  /// Label of the field [key], or the key itself.
  String fieldLabel(String key) => fieldOf(key)?.label ?? key;
}

/// Dynamic field of the form of a request type.
class RequestField {
  /// Creates the field.
  const RequestField({
    required this.id,
    required this.key,
    required this.label,
    required this.dataType,
    required this.isRequired,
    required this.displayOrder,
  });

  final int id;
  final String key;
  final String label;
  final FieldDataType dataType;
  final bool isRequired;
  final int displayOrder;
}

/// Field added by HR to a request type that is being created.
class NewRequestField {
  /// Creates the field.
  const NewRequestField({
    required this.key,
    required this.label,
    required this.dataType,
    required this.isRequired,
  });

  final String key;
  final String label;
  final FieldDataType dataType;
  final bool isRequired;
}
