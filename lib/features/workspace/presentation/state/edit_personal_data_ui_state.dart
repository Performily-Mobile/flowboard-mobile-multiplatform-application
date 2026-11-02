/// Fields of the personal data form that can show an error.
enum PersonalDataField { firstName, lastName, birthDate, email, phone, address }

const Object _keep = Object();

/// State of the personal data form.
class EditPersonalDataUiState {
  /// Creates the state.
  const EditPersonalDataUiState({
    this.isLoading = false,
    this.identityDocumentLabel = '',
    this.firstName = '',
    this.lastName = '',
    this.birthDate,
    this.email = '',
    this.phoneNumber = '',
    this.street = '',
    this.district = '',
    this.province = '',
    this.department = '',
    this.fieldErrors = const <PersonalDataField, String>{},
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String identityDocumentLabel;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String email;
  final String phoneNumber;
  final String street;
  final String district;
  final String province;
  final String department;
  final Map<PersonalDataField, String> fieldErrors;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;

  /// Error of [field], if any.
  String? errorOf(PersonalDataField field) => fieldErrors[field];

  /// Copy with the given values replaced.
  EditPersonalDataUiState copyWith({
    bool? isLoading,
    String? identityDocumentLabel,
    String? firstName,
    String? lastName,
    Object? birthDate = _keep,
    String? email,
    String? phoneNumber,
    String? street,
    String? district,
    String? province,
    String? department,
    Map<PersonalDataField, String>? fieldErrors,
    bool? isSaving,
    bool? isSaved,
    Object? errorMessage = _keep,
  }) {
    return EditPersonalDataUiState(
      isLoading: isLoading ?? this.isLoading,
      identityDocumentLabel: identityDocumentLabel ?? this.identityDocumentLabel,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: identical(birthDate, _keep) ? this.birthDate : birthDate as DateTime?,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      district: district ?? this.district,
      province: province ?? this.province,
      department: department ?? this.department,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
