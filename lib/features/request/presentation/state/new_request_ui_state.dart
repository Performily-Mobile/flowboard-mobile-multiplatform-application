import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_time.dart';

const Object _keep = Object();

/// Steps of the new request form.
enum NewRequestStep {
  type(1, 'Tipo de solicitud'),
  detail(2, 'Detalle'),
  confirmation(3, 'Confirmación');

  const NewRequestStep(this.number, this.label);

  final int number;
  final String label;
}

/// State of the new request form.
class NewRequestUiState {
  /// Creates the state.
  const NewRequestUiState({
    this.step = NewRequestStep.type,
    this.isLoading = false,
    this.loadError,
    this.types = const <RequestType>[],
    this.selectedType,
    this.availability,
    this.approver,
    this.startDate,
    this.endDate,
    this.byHours = false,
    this.startTime,
    this.endTime,
    this.values = const <String, String>{},
    this.fieldErrors = const <String, String>{},
    this.attachments = const <FileReference>[],
    this.isUploading = false,
    this.attachmentError,
    this.periodError,
    this.errorMessage,
    this.isSubmitting = false,
    this.resultMessage,
  });

  final NewRequestStep step;
  final bool isLoading;
  final String? loadError;
  final List<RequestType> types;
  final RequestType? selectedType;
  final VacationAvailability? availability;
  final RequestPerson? approver;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool byHours;
  final RequestTime? startTime;
  final RequestTime? endTime;
  final Map<String, String> values;
  final Map<String, String> fieldErrors;
  final List<FileReference> attachments;
  final bool isUploading;
  final String? attachmentError;
  final String? periodError;
  final String? errorMessage;
  final bool isSubmitting;

  /// When set, the request was sent and the screen closes with this message.
  final String? resultMessage;

  /// True when the selected type allows a range of hours (it discounts no balance).
  bool get canUseHours => selectedType?.deductsBalance == false;

  /// Period built with what was chosen, or null when something is missing or not valid.
  RequestPeriod? get period {
    final DateTime? start = startDate;
    if (start == null) return null;
    try {
      if (byHours && canUseHours) {
        return RequestPeriod(startDate: start, endDate: start, startTime: startTime, endTime: endTime);
      }
      final DateTime? end = endDate;
      if (end == null) return null;
      return RequestPeriod(startDate: start, endDate: end);
    } on ArgumentError {
      return null;
    }
  }

  /// Days asked for.
  int get requestedDays => period?.days ?? 0;

  /// True when a vacation request asks for more days than the balance.
  bool get exceedsBalance {
    final VacationAvailability? current = availability;
    final int days = requestedDays;
    return selectedType?.deductsVacationDays == true && current != null && days > 0 && !current.isEnoughFor(days);
  }

  /// Values written in the dynamic fields, without the blank ones.
  List<RequestFieldValue> get fieldValues => values.entries
      .where((MapEntry<String, String> entry) => entry.value.trim().isNotEmpty)
      .map((MapEntry<String, String> entry) => RequestFieldValue(key: entry.key, value: entry.value))
      .toList();

  /// True when the detail step can go to the confirmation.
  bool get canReview => period != null && !exceedsBalance && !isUploading;

  /// Name of who will receive the request.
  String get approverName => approver?.name ?? 'Recursos Humanos';

  /// Copy with the given values replaced.
  NewRequestUiState copyWith({
    NewRequestStep? step,
    bool? isLoading,
    Object? loadError = _keep,
    List<RequestType>? types,
    Object? selectedType = _keep,
    Object? availability = _keep,
    Object? approver = _keep,
    Object? startDate = _keep,
    Object? endDate = _keep,
    bool? byHours,
    Object? startTime = _keep,
    Object? endTime = _keep,
    Map<String, String>? values,
    Map<String, String>? fieldErrors,
    List<FileReference>? attachments,
    bool? isUploading,
    Object? attachmentError = _keep,
    Object? periodError = _keep,
    Object? errorMessage = _keep,
    bool? isSubmitting,
    Object? resultMessage = _keep,
  }) {
    return NewRequestUiState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      loadError: identical(loadError, _keep) ? this.loadError : loadError as String?,
      types: types ?? this.types,
      selectedType: identical(selectedType, _keep) ? this.selectedType : selectedType as RequestType?,
      availability: identical(availability, _keep) ? this.availability : availability as VacationAvailability?,
      approver: identical(approver, _keep) ? this.approver : approver as RequestPerson?,
      startDate: identical(startDate, _keep) ? this.startDate : startDate as DateTime?,
      endDate: identical(endDate, _keep) ? this.endDate : endDate as DateTime?,
      byHours: byHours ?? this.byHours,
      startTime: identical(startTime, _keep) ? this.startTime : startTime as RequestTime?,
      endTime: identical(endTime, _keep) ? this.endTime : endTime as RequestTime?,
      values: values ?? this.values,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      attachments: attachments ?? this.attachments,
      isUploading: isUploading ?? this.isUploading,
      attachmentError: identical(attachmentError, _keep) ? this.attachmentError : attachmentError as String?,
      periodError: identical(periodError, _keep) ? this.periodError : periodError as String?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
