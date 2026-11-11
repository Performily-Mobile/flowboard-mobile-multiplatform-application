import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/get_approver_preview_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_request_types_use_case.dart';
import 'package:flowboard/features/request/application/usecase/get_vacation_availability_use_case.dart';
import 'package:flowboard/features/request/application/usecase/store_attachment_use_case.dart';
import 'package:flowboard/features/request/application/usecase/submit_request_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_person.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_time.dart';
import 'package:flowboard/features/request/presentation/state/new_request_ui_state.dart';
import 'package:flowboard/features/request/presentation/state/picked_attachment.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the three-step form to send a new request.
class NewRequestViewModel extends ViewModel<NewRequestUiState> {
  /// Creates the view model.
  NewRequestViewModel({
    required this.getRequestTypes,
    required this.getVacationAvailability,
    required this.getApproverPreview,
    required this.storeAttachment,
    required this.submitRequest,
  }) : super(const NewRequestUiState());

  final GetRequestTypesUseCase getRequestTypes;
  final GetVacationAvailabilityUseCase getVacationAvailability;
  final GetApproverPreviewUseCase getApproverPreview;
  final StoreAttachmentUseCase storeAttachment;
  final SubmitRequestUseCase submitRequest;

  /// Loads the active types, the vacation balance and who will receive the request.
  Future<void> load() async {
    if (state.types.isNotEmpty || state.isLoading) return;
    update((NewRequestUiState s) => s.copyWith(isLoading: true, loadError: null));
    final Future<VacationAvailability?> availability = attemptOrNull(() => getVacationAvailability.execute());
    final Future<RequestPerson?> approver = attemptOrNull(() => getApproverPreview.execute());
    try {
      final List<RequestType> types = await getRequestTypes.execute(activeOnly: true);
      final VacationAvailability? balance = await availability;
      final RequestPerson? manager = await approver;
      update((NewRequestUiState s) => s.copyWith(
            isLoading: false,
            types: types,
            selectedType: s.selectedType ?? (types.isEmpty ? null : types.first),
            availability: balance,
            approver: manager,
          ));
    } catch (error) {
      update((NewRequestUiState s) => s.copyWith(
            isLoading: false,
            loadError: requestErrorMessage(error, RequestAction.load, 'No se pudieron cargar los tipos de solicitud.'),
          ));
    }
  }

  /// Chooses the type of request.
  void onTypeSelected(RequestType type) => update((NewRequestUiState s) => s.copyWith(selectedType: type));

  /// Goes to the detail step; the values of another type are cleared.
  void continueToDetail() {
    final RequestType? type = state.selectedType;
    if (type == null) return;
    update((NewRequestUiState s) {
      final bool sameFields = s.values.keys.every((String key) => type.fieldOf(key) != null);
      return s.copyWith(
        step: NewRequestStep.detail,
        values: sameFields ? s.values : const <String, String>{},
        fieldErrors: const <String, String>{},
        byHours: s.byHours && !type.deductsBalance,
        errorMessage: null,
      );
    });
  }

  /// Changes the first day; an end before it moves to the same day.
  void onStartDateChange(DateTime date) {
    update((NewRequestUiState s) {
      final DateTime? end = s.endDate;
      return s.copyWith(startDate: date, endDate: end == null || end.isBefore(date) ? date : end, periodError: null);
    });
  }

  /// Changes the last day.
  void onEndDateChange(DateTime date) => update((NewRequestUiState s) => s.copyWith(endDate: date, periodError: null));

  /// Switches between whole days and a range of hours.
  void onByHoursChange(bool value) => update((NewRequestUiState s) => s.copyWith(byHours: value, periodError: null));

  /// Changes the start time.
  void onStartTimeChange(RequestTime time) =>
      update((NewRequestUiState s) => s.copyWith(startTime: time, periodError: null));

  /// Changes the end time.
  void onEndTimeChange(RequestTime time) => update((NewRequestUiState s) => s.copyWith(endTime: time, periodError: null));

  /// Changes the value of the dynamic field [key].
  void onFieldChange(String key, String value) {
    update((NewRequestUiState s) => s.copyWith(
          values: <String, String>{...s.values, key: value},
          fieldErrors: <String, String>{...s.fieldErrors}..remove(key),
        ));
  }

  /// Stores the chosen file and adds it to the attachments.
  Future<void> onFilePicked(PickedAttachment file) async {
    update((NewRequestUiState s) => s.copyWith(isUploading: true, attachmentError: null));
    try {
      final FileReference stored = await storeAttachment.execute(
        sourceUri: file.uri,
        fileName: file.name,
        contentType: file.contentType,
        sizeInBytes: file.sizeInBytes,
      );
      update((NewRequestUiState s) => s.copyWith(isUploading: false, attachments: <FileReference>[...s.attachments, stored]));
    } catch (error) {
      update((NewRequestUiState s) => s.copyWith(
            isUploading: false,
            attachmentError: requestErrorMessage(error, RequestAction.submit, 'No se pudo adjuntar el archivo.'),
          ));
    }
  }

  /// Removes [file] from the attachments.
  void removeAttachment(FileReference file) {
    update((NewRequestUiState s) =>
        s.copyWith(attachments: s.attachments.where((FileReference item) => !identical(item, file)).toList()));
  }

  /// Checks the detail and goes to the confirmation step.
  void continueToConfirmation() {
    final NewRequestUiState current = state;
    final RequestType? type = current.selectedType;
    if (type == null) return;
    final RequestPeriod? period = current.period;
    if (period == null) {
      update((NewRequestUiState s) => s.copyWith(periodError: _periodProblem(s)));
      return;
    }
    final Map<String, String> fieldErrors = <String, String>{};
    for (final RequestField field in type.fields) {
      final String value = (current.values[field.key] ?? '').trim();
      if (field.isRequired && value.isEmpty) {
        fieldErrors[field.key] = 'Este campo es obligatorio.';
      } else if (value.isNotEmpty && !field.dataType.isValid(value)) {
        fieldErrors[field.key] = 'Revisa el formato.';
      }
    }
    final String? attachmentError = type.requiresAttachment && current.attachments.isEmpty
        ? 'Este tipo de solicitud requiere un documento adjunto.'
        : null;
    if (fieldErrors.isNotEmpty || attachmentError != null) {
      update((NewRequestUiState s) => s.copyWith(fieldErrors: fieldErrors, attachmentError: attachmentError));
      return;
    }
    update((NewRequestUiState s) => s.copyWith(step: NewRequestStep.confirmation, errorMessage: null));
  }

  String _periodProblem(NewRequestUiState s) {
    final bool hourly = s.byHours && s.canUseHours;
    if (s.startDate == null) return 'Elige la fecha de inicio.';
    if (hourly && (s.startTime == null || s.endTime == null)) return 'Indica la hora de inicio y la de fin.';
    if (hourly) return 'La hora de fin debe ser posterior a la de inicio.';
    if (s.endDate == null) return 'Elige la fecha de fin.';
    return 'La fecha de fin no puede ser anterior a la de inicio.';
  }

  /// Sends the request.
  Future<void> submit() async {
    final NewRequestUiState current = state;
    final RequestType? type = current.selectedType;
    if (type == null || current.isSubmitting) return;
    update((NewRequestUiState s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final Request request = await submitRequest.execute(
        type: type,
        period: current.period,
        fieldValues: current.fieldValues,
        attachments: current.attachments,
      );
      update((NewRequestUiState s) => s.copyWith(
            isSubmitting: false,
            resultMessage: 'Solicitud ${RequestFormatters.code(request.id)} enviada a '
                '${RequestFormatters.shortName(current.approverName)}.',
          ));
    } catch (error) {
      update((NewRequestUiState s) => s.copyWith(
            isSubmitting: false,
            errorMessage: requestErrorMessage(error, RequestAction.submit, 'No se pudo enviar la solicitud.'),
          ));
    }
  }

  /// Goes back one step; returns false on the first step, where the screen closes.
  bool goBack() {
    final NewRequestStep? previous = switch (state.step) {
      NewRequestStep.type => null,
      NewRequestStep.detail => NewRequestStep.type,
      NewRequestStep.confirmation => NewRequestStep.detail,
    };
    if (previous == null) return false;
    update((NewRequestUiState s) => s.copyWith(step: previous, errorMessage: null));
    return true;
  }
}
