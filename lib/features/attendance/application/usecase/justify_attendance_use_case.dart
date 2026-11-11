import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';

/// Sends the justification of a late, absent or incomplete day.
class JustifyAttendanceUseCase {
  /// Creates the use case.
  const JustifyAttendanceUseCase({required this.repository});

  final AttendanceRepository repository;

  /// Longest reason accepted.
  static const int maxReason = 500;

  /// Justifies [record]; throws [ArgumentError] when the day, the [reason] or the [evidenceUrl] is not valid.
  Future<AttendanceRecord> execute(AttendanceRecord record, {required String reason, String? evidenceUrl}) {
    final int? recordId = record.id;
    if (recordId == null || !record.canBeJustified) {
      throw ArgumentError('Este día no se puede justificar.');
    }
    final String cleanReason = reason.trim();
    if (cleanReason.isEmpty) throw ArgumentError('Ingresa el motivo de la justificación.');
    if (cleanReason.length > maxReason) throw ArgumentError('El motivo admite hasta $maxReason caracteres.');
    final String cleanUrl = evidenceUrl?.trim() ?? '';
    if (cleanUrl.isNotEmpty && !_isWebLink(cleanUrl)) {
      throw ArgumentError('Ingresa un enlace válido que empiece con http:// o https://.');
    }
    return repository.justify(recordId: recordId, reason: cleanReason, evidenceUrl: cleanUrl.isEmpty ? null : cleanUrl);
  }

  bool _isWebLink(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }
}
