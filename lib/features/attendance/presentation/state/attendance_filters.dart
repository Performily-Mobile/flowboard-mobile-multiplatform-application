import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/valueobject/attendance_status.dart';

/// Filter of the attendance records by status.
enum AttendanceStatusFilter {
  all('Todos', null),
  onTime('Puntual', AttendanceStatus.onTime),
  late('Tardanza', AttendanceStatus.late),
  incomplete('Incompleto', AttendanceStatus.incomplete),
  absent('Falta', AttendanceStatus.absent),
  justified('Justificado', AttendanceStatus.justified);

  const AttendanceStatusFilter(this.label, this.status);

  final String label;

  /// Status kept by the filter; null keeps every status.
  final AttendanceStatus? status;

  /// Records of [records] that pass the filter.
  List<AttendanceRecord> apply(List<AttendanceRecord> records) {
    final AttendanceStatus? kept = status;
    if (kept == null) return records;
    return records.where((AttendanceRecord record) => record.status == kept).toList();
  }
}

/// Sections of the attendance tab for the HR staff.
enum AttendanceSection {
  records('Registros'),
  areas('Por área'),
  hours('Horas');

  const AttendanceSection(this.label);

  final String label;
}

/// Order of the hours report.
enum AttendanceHoursOrder {
  overtime('Más sobretiempo'),
  worked('Más horas trabajadas'),
  name('Nombre');

  const AttendanceHoursOrder(this.label);

  final String label;
}

/// Kind of justification, written before the reason sent to the backend.
enum JustificationType {
  medicalRest('Descanso médico'),
  personalLeave('Permiso personal'),
  other('Otro');

  const JustificationType(this.label);

  final String label;
}
