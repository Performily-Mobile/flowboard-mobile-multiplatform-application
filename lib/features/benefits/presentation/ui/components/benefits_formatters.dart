import 'package:intl/intl.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/domain/valueobject/vacation_movement_type.dart';

/// Texts and formats of Benefits exactly as they appear in the prototype (MA-57 to MA-63).
class BenefitsFormatters {
  const BenefitsFormatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _number = NumberFormat('#,##0.##', 'en_US');
  static const List<String> _monthNames = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Plain number: 1240 becomes "1,240" and 2.50 becomes "2.5".
  static String number(double value) => _number.format(value);

  /// Quantity with its unit: "S/ 1,240.00", "1 día", "2.5 días", "1 unidad".
  static String quantity(double value, BenefitUnit unit) => switch (unit) {
        BenefitUnit.money => 'S/ ${_money.format(value)}',
        BenefitUnit.days => '${number(value)} ${_isOne(value) ? 'día' : 'días'}',
        BenefitUnit.units => '${number(value)} ${_isOne(value) ? 'unidad' : 'unidades'}',
      };

  /// Signed number of days with the typographic minus of the prototype: "+2.5 días", "−3 días".
  static String signedDays(double value) {
    final String sign = value < 0 ? '−' : '+';
    final double abs = value.abs();
    return '$sign${number(abs)} ${_isOne(abs) ? 'día' : 'días'}';
  }

  /// Date as dd/MM/yyyy.
  static String date(DateTime date) => '${_two(date.day)}/${_two(date.month)}/${date.year}';

  /// Date as dd/MM.
  static String shortDate(DateTime date) => '${_two(date.day)}/${_two(date.month)}';

  /// Sync time of the offline copy: "el 26/09 a las 08:10".
  static String syncedAt(DateTime dateTime) =>
      'el ${shortDate(dateTime)} a las ${_two(dateTime.hour)}:${_two(dateTime.minute)}';

  /// Validity of an assignment: "diciembre 2026" for one month, otherwise "01/10/2026 – 15/11/2026".
  static String period(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) return '${_monthNames[start.month - 1]} ${start.year}';
    return '${date(start)} – ${date(end)}';
  }

  /// Request code as the Request context shows it: 142 becomes "S-0142".
  static String requestCode(int requestId) => 'S-${requestId.toString().padLeft(4, '0')}';

  /// Initials of a full name: "María Quispe Rojas" becomes "MQ".
  static String initials(String name) => name
      .split(' ')
      .where((String part) => part.trim().isNotEmpty)
      .take(2)
      .map((String part) => String.fromCharCode(part.runes.first).toUpperCase())
      .join();

  /// Title of a vacation movement (MA-57, MA-63).
  static String movementTitle(VacationMovement movement) {
    final int? requestId = movement.requestId;
    return switch (movement.type) {
      VacationMovementType.accrual => movement.reason ?? 'Acumulación',
      VacationMovementType.usage => requestId == null ? 'Uso de vacaciones' : 'Uso · Solicitud ${requestCode(requestId)}',
      VacationMovementType.reversal => requestId == null ? 'Reversión' : 'Reversión · Solicitud ${requestCode(requestId)}',
      VacationMovementType.manualAdjustment => 'Ajuste manual',
    };
  }

  /// Line below a movement title: the date and, for an adjustment, who made it and why.
  static String movementDetail(VacationMovement movement) {
    final DateTime day = movement.occurredAt;
    return switch (movement.type) {
      VacationMovementType.manualAdjustment => <String?>[
          shortDate(day),
          movement.authorName == null ? null : '${movement.authorName} (RR.HH.)',
          movement.reason == null ? null : 'Motivo: ${movement.reason}',
        ].whereType<String>().join(' · '),
      VacationMovementType.reversal => '${shortDate(day)} · Solicitud aprobada anulada',
      _ => date(day),
    };
  }

  static bool _isOne(double value) => value == 1;

  static String _two(int value) => value.toString().padLeft(2, '0');
}
