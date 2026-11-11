import 'package:flowboard/features/request/domain/valueobject/request_time.dart';

/// Data type of a dynamic field of a request type.
enum FieldDataType {
  text,
  number,
  date,
  time,
  money,
  boolean;

  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp _moneyPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  /// True when [value] has the format of this data type.
  bool isValid(String value) {
    final String text = value.trim();
    return switch (this) {
      FieldDataType.text => true,
      FieldDataType.number => double.tryParse(text) != null,
      FieldDataType.date => _datePattern.hasMatch(text) && DateTime.tryParse(text) != null,
      FieldDataType.time => RequestTime.tryParse(text) != null,
      FieldDataType.money => _moneyPattern.hasMatch(text),
      FieldDataType.boolean => text.toLowerCase() == 'true' || text.toLowerCase() == 'false',
    };
  }
}
