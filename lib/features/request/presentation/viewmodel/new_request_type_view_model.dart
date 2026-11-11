import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/request/application/usecase/create_request_type_use_case.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/presentation/state/new_request_type_ui_state.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_error_messages.dart';

/// View model of the form to create a request type.
class NewRequestTypeViewModel extends ViewModel<NewRequestTypeUiState> {
  /// Creates the view model.
  NewRequestTypeViewModel({required this.createRequestType}) : super(const NewRequestTypeUiState());

  final CreateRequestTypeUseCase createRequestType;

  static const int _maxLabel = 80;

  /// Changes the name.
  void onNameChange(String value) {
    update((NewRequestTypeUiState s) =>
        s.copyWith(name: _limit(value, CreateRequestTypeUseCase.maxName), nameError: null));
  }

  /// Changes the description.
  void onDescriptionChange(String value) {
    update((NewRequestTypeUiState s) =>
        s.copyWith(description: _limit(value, CreateRequestTypeUseCase.maxDescription)));
  }

  /// Changes whether the type needs an attachment.
  void onRequiresAttachmentChange(bool value) {
    update((NewRequestTypeUiState s) => s.copyWith(requiresAttachment: value));
  }

  /// Changes the balance the type discounts.
  void onBalanceDeductionChange(BalanceDeduction value) {
    update((NewRequestTypeUiState s) => s.copyWith(balanceDeduction: value));
  }

  /// Opens the sheet to add a field.
  void showFieldSheet() => update((NewRequestTypeUiState s) => s.copyWith(fieldForm: const FieldForm()));

  /// Closes the sheet to add a field.
  void dismissFieldSheet() => update((NewRequestTypeUiState s) => s.copyWith(fieldForm: null));

  /// Changes the name of the new field.
  void onFieldLabelChange(String value) {
    update((NewRequestTypeUiState s) =>
        s.copyWith(fieldForm: s.fieldForm?.copyWith(label: _limit(value, _maxLabel), error: null)));
  }

  /// Changes the data type of the new field.
  void onFieldDataTypeChange(FieldDataType value) {
    update((NewRequestTypeUiState s) => s.copyWith(fieldForm: s.fieldForm?.copyWith(dataType: value)));
  }

  /// Changes whether the new field is required.
  void onFieldRequiredChange(bool value) {
    update((NewRequestTypeUiState s) => s.copyWith(fieldForm: s.fieldForm?.copyWith(isRequired: value)));
  }

  /// Adds the field of the sheet; its key is built from its name ("Motivo del viaje" -> "motivoDelViaje").
  void addField() {
    final NewRequestTypeUiState current = state;
    final FieldForm? form = current.fieldForm;
    if (form == null) return;
    final String label = form.label.trim();
    String? error;
    if (label.isEmpty) {
      error = 'Ingresa el nombre del campo.';
    } else if (current.fields.any((NewRequestField field) => field.label.toLowerCase() == label.toLowerCase())) {
      error = 'Ya hay un campo con este nombre.';
    }
    if (error != null) {
      update((NewRequestTypeUiState s) => s.copyWith(fieldForm: form.copyWith(error: error)));
      return;
    }
    final String key = CreateRequestTypeUseCase.keyFor(label, current.fields.map((NewRequestField field) => field.key));
    final NewRequestField field =
        NewRequestField(key: key, label: label, dataType: form.dataType, isRequired: form.isRequired);
    update((NewRequestTypeUiState s) => s.copyWith(fields: <NewRequestField>[...s.fields, field], fieldForm: null));
  }

  /// Removes [field] from the form.
  void removeField(NewRequestField field) {
    update((NewRequestTypeUiState s) =>
        s.copyWith(fields: s.fields.where((NewRequestField item) => item.key != field.key).toList()));
  }

  /// Creates the type.
  Future<void> save() async {
    final NewRequestTypeUiState current = state;
    if (current.isSaving) return;
    if (current.name.trim().isEmpty) {
      update((NewRequestTypeUiState s) => s.copyWith(nameError: 'Ingresa el nombre del tipo de solicitud.'));
      return;
    }
    update((NewRequestTypeUiState s) => s.copyWith(isSaving: true, errorMessage: null));
    try {
      final RequestType type = await createRequestType.execute(
        name: current.name,
        description: current.description,
        requiresAttachment: current.requiresAttachment,
        balanceDeduction: current.balanceDeduction,
        fields: current.fields,
      );
      update((NewRequestTypeUiState s) => s.copyWith(isSaving: false, resultMessage: 'Tipo "${type.name}" creado.'));
    } catch (error) {
      final String message =
          requestErrorMessage(error, RequestAction.createType, 'No se pudo crear el tipo de solicitud.');
      update((NewRequestTypeUiState s) => message.contains('nombre')
          ? s.copyWith(isSaving: false, nameError: message)
          : s.copyWith(isSaving: false, errorMessage: message));
    }
  }

  String _limit(String value, int max) => value.length > max ? value.substring(0, max) : value;
}
