import 'package:flowboard/features/benefits/domain/valueobject/adjustment_operation.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/domain/valueobject/vacation_movement_type.dart';

/// Converts the texts of the backend to enums and dates without breaking the app when an
/// unknown value arrives.
class BenefitsEnumMapper {
  const BenefitsEnumMapper._();

  /// UPPER_SNAKE_CASE name used by the API, for example `manualAdjustment` becomes `MANUAL_ADJUSTMENT`.
  static String toApi(Enum value) => value.name
      .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (Match match) => '${match[1]}_${match[2]}')
      .toUpperCase();

  /// Unit of [value]; unknown values are read as units.
  static BenefitUnit unit(String value) => _fromApi(BenefitUnit.values, value, BenefitUnit.units);

  /// Status of [value]; unknown values are read as assigned.
  static AssignmentStatus status(String value) =>
      _fromApi(AssignmentStatus.values, value, AssignmentStatus.assigned);

  /// Movement type of [value]; unknown values are read as a manual adjustment.
  static VacationMovementType movementType(String value) =>
      _fromApi(VacationMovementType.values, value, VacationMovementType.manualAdjustment);

  /// API name of an adjustment operation.
  static String operation(AdjustmentOperation value) => toApi(value);

  /// Date of an ISO `yyyy-MM-dd` text, or null when it is missing or invalid.
  static DateTime? date(String? value) {
    final DateTime? parsed = value == null ? null : DateTime.tryParse(value);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Date and time of an ISO text, or null when it is missing or invalid.
  static DateTime? dateTime(String? value) => value == null ? null : DateTime.tryParse(value);

  /// ISO `yyyy-MM-dd` text of [date], as the API expects it.
  static String isoDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static T _fromApi<T extends Enum>(List<T> values, String raw, T fallback) {
    for (final T value in values) {
      if (toApi(value) == raw) return value;
    }
    return fallback;
  }
}
