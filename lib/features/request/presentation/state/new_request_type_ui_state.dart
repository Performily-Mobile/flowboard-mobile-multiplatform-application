import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';

const Object _keep = Object();

/// Values of the sheet to add a field.
class FieldForm {
  /// Creates the form.
  const FieldForm({this.label = '', this.dataType = FieldDataType.text, this.isRequired = false, this.error});

  final String label;
  final FieldDataType dataType;
  final bool isRequired;
  final String? error;

  /// Copy with the given values replaced.
  FieldForm copyWith({String? label, FieldDataType? dataType, bool? isRequired, Object? error = _keep}) {
    return FieldForm(
      label: label ?? this.label,
      dataType: dataType ?? this.dataType,
      isRequired: isRequired ?? this.isRequired,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }
}

/// State of the form to create a request type.
class NewRequestTypeUiState {
  /// Creates the state.
  const NewRequestTypeUiState({
    this.name = '',
    this.description = '',
    this.requiresAttachment = false,
    this.balanceDeduction = BalanceDeduction.none,
    this.fields = const <NewRequestField>[],
    this.fieldForm,
    this.nameError,
    this.errorMessage,
    this.isSaving = false,
    this.resultMessage,
  });

  final String name;
  final String description;
  final bool requiresAttachment;
  final BalanceDeduction balanceDeduction;
  final List<NewRequestField> fields;

  /// Values of the field sheet while it is open.
  final FieldForm? fieldForm;
  final String? nameError;
  final String? errorMessage;
  final bool isSaving;

  /// When set, the type was created and the screen closes with this message.
  final String? resultMessage;

  /// True when the type can be saved.
  bool get canSave => !isSaving && name.trim().isNotEmpty;

  /// Copy with the given values replaced.
  NewRequestTypeUiState copyWith({
    String? name,
    String? description,
    bool? requiresAttachment,
    BalanceDeduction? balanceDeduction,
    List<NewRequestField>? fields,
    Object? fieldForm = _keep,
    Object? nameError = _keep,
    Object? errorMessage = _keep,
    bool? isSaving,
    Object? resultMessage = _keep,
  }) {
    return NewRequestTypeUiState(
      name: name ?? this.name,
      description: description ?? this.description,
      requiresAttachment: requiresAttachment ?? this.requiresAttachment,
      balanceDeduction: balanceDeduction ?? this.balanceDeduction,
      fields: fields ?? this.fields,
      fieldForm: identical(fieldForm, _keep) ? this.fieldForm : fieldForm as FieldForm?,
      nameError: identical(nameError, _keep) ? this.nameError : nameError as String?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isSaving: isSaving ?? this.isSaving,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
