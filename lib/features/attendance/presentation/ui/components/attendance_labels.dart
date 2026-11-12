import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';
import 'package:flowboard/features/attendance/domain/valueobject/punch_type.dart';

/// Spanish label of the attendance status.
extension AttendanceStatusLabel on AttendanceStatus {
  /// Text shown to the user.
  String get label => switch (this) {
        AttendanceStatus.onTime => 'Puntual',
        AttendanceStatus.late => 'Tardanza',
        AttendanceStatus.incomplete => 'Incompleto',
        AttendanceStatus.absent => 'Falta',
        AttendanceStatus.justified => 'Justificado',
      };
}

/// Spanish labels of the punch type.
extension PunchTypeLabel on PunchType {
  /// Text of the button that registers the punch.
  String get actionLabel => switch (this) {
        PunchType.checkIn => 'Marcar entrada',
        PunchType.checkOut => 'Marcar salida',
      };
}
