import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';

/// Sends a new request of the current employee.
class SubmitRequestUseCase {
  /// Creates the use case.
  const SubmitRequestUseCase({required this.repository, required this.currentEmployeeProvider});

  final RequestRepository repository;
  final CurrentEmployeeProvider currentEmployeeProvider;

  static const int _maxValue = 500;

  /// Sends the request; throws [ArgumentError] when it breaks a rule of its [type].
  Future<Request> execute({
    required RequestType type,
    required RequestPeriod? period,
    required List<RequestFieldValue> fieldValues,
    required List<FileReference> attachments,
  }) {
    final String? problem = validate(type, period, fieldValues, attachments);
    if (problem != null) throw ArgumentError(problem);
    return repository.submit(
      requesterId: currentEmployeeProvider.currentEmployeeId().value,
      requestTypeId: type.id,
      period: period,
      fieldValues: fieldValues
          .where((RequestFieldValue item) => item.value.trim().isNotEmpty)
          .map((RequestFieldValue item) => RequestFieldValue(key: item.key, value: item.value.trim()))
          .toList(),
      attachments: attachments,
    );
  }

  /// Message of the first rule of [type] that the request breaks, or null when it is valid.
  static String? validate(
    RequestType type,
    RequestPeriod? period,
    List<RequestFieldValue> fieldValues,
    List<FileReference> attachments,
  ) {
    if (type.deductsBalance && (period == null || period.hasHours)) {
      return 'Este tipo de solicitud necesita un periodo de días completos.';
    }
    for (final RequestField field in type.fields) {
      final String value = _valueOf(fieldValues, field.key);
      if (field.isRequired && value.isEmpty) return 'Completa el campo "${field.label}".';
      if (value.isNotEmpty && !field.dataType.isValid(value)) return 'Revisa el formato de "${field.label}".';
      if (value.length > _maxValue) return '"${field.label}" admite hasta $_maxValue caracteres.';
    }
    if (type.requiresAttachment && attachments.isEmpty) return 'Adjunta el documento de sustento.';
    return null;
  }

  static String _valueOf(List<RequestFieldValue> fieldValues, String key) {
    for (final RequestFieldValue item in fieldValues) {
      if (item.key == key) return item.value.trim();
    }
    return '';
  }
}
