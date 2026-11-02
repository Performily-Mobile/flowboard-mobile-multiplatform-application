import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/update_employee_personal_data_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';
import 'package:flowboard/features/workspace/presentation/state/edit_personal_data_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the personal data form.
class EditPersonalDataViewModel extends ViewModel<EditPersonalDataUiState> {
  /// Creates the view model.
  EditPersonalDataViewModel({required this.getEmployeeById, required this.updatePersonalData})
      : super(const EditPersonalDataUiState());

  final GetEmployeeByIdUseCase getEmployeeById;
  final UpdateEmployeePersonalDataUseCase updatePersonalData;

  EmployeeId? _employeeId;

  /// Loads the current data of the employee [id] into the form.
  Future<void> load(int id) async {
    if (_employeeId?.value == id) return;
    _employeeId = EmployeeId(id);
    update((EditPersonalDataUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final Employee employee = await getEmployeeById.execute(EmployeeId(id));
      update((EditPersonalDataUiState s) => s.copyWith(
            isLoading: false,
            identityDocumentLabel: '${employee.identityDocument.type.label} ${employee.identityDocument.number}',
            firstName: employee.name.firstName,
            lastName: employee.name.lastName,
            birthDate: employee.birthDate.value,
            email: employee.email.value,
            phoneNumber: employee.phoneNumber.value,
            street: employee.address.street ?? '',
            district: employee.address.district ?? '',
            province: employee.address.province ?? '',
            department: employee.address.department ?? '',
          ));
    } catch (error) {
      update((EditPersonalDataUiState s) => s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  /// Changes the first name.
  void onFirstNameChange(String value) => _updateField(PersonalDataField.firstName, (s) => s.copyWith(firstName: value));

  /// Changes the last name.
  void onLastNameChange(String value) => _updateField(PersonalDataField.lastName, (s) => s.copyWith(lastName: value));

  /// Changes the birth date.
  void onBirthDateChange(DateTime value) =>
      _updateField(PersonalDataField.birthDate, (s) => s.copyWith(birthDate: value));

  /// Changes the email.
  void onEmailChange(String value) => _updateField(PersonalDataField.email, (s) => s.copyWith(email: value.trim()));

  /// Changes the phone.
  void onPhoneChange(String value) => _updateField(PersonalDataField.phone, (s) => s.copyWith(phoneNumber: value));

  /// Changes the street.
  void onStreetChange(String value) => _updateField(PersonalDataField.address, (s) => s.copyWith(street: value));

  /// Changes the district.
  void onDistrictChange(String value) => _updateField(PersonalDataField.address, (s) => s.copyWith(district: value));

  /// Changes the province.
  void onProvinceChange(String value) => _updateField(PersonalDataField.address, (s) => s.copyWith(province: value));

  /// Changes the department.
  void onDepartmentChange(String value) =>
      _updateField(PersonalDataField.address, (s) => s.copyWith(department: value));

  /// Validates the form and saves the personal data.
  ///
  /// PersonName validates first and last name together, so a last-name error is moved to its own
  /// field. The address is optional but cannot be partially filled: either all four parts or none.
  Future<void> onSave() async {
    final EmployeeId? id = _employeeId;
    if (id == null) return;
    final EditPersonalDataUiState current = state;
    final Map<PersonalDataField, String> errors = <PersonalDataField, String>{};

    final PersonName? name = _validate(errors, PersonalDataField.firstName,
        () => PersonName(current.firstName.trim(), current.lastName.trim()));
    final BirthDate? birthDate = _validate(errors, PersonalDataField.birthDate, () {
      final DateTime? value = current.birthDate;
      if (value == null) throw ArgumentError('Selecciona la fecha de nacimiento.');
      return BirthDate(value);
    });
    final EmailAddress? email = _validate(errors, PersonalDataField.email, () => EmailAddress(current.email));
    final PhoneNumber? phone = _validate(errors, PersonalDataField.phone, () => PhoneNumber.of(current.phoneNumber));
    final String? nameError = errors[PersonalDataField.firstName];
    if (nameError != null && nameError.toLowerCase().contains('apellido')) {
      errors.remove(PersonalDataField.firstName);
      errors[PersonalDataField.lastName] = nameError;
    }

    final int filledAddressParts = <String>[current.street, current.district, current.province, current.department]
        .where((String part) => part.trim().isNotEmpty)
        .length;
    if (filledAddressParts >= 1 && filledAddressParts <= 3) {
      errors[PersonalDataField.address] = 'Completa los cuatro campos de la dirección o déjalos todos vacíos.';
    }

    if (errors.isNotEmpty || name == null || birthDate == null || email == null || phone == null) {
      update((EditPersonalDataUiState s) => s.copyWith(fieldErrors: errors));
      return;
    }

    final Address address = Address(
      street: current.street.trim(),
      district: current.district.trim(),
      province: current.province.trim(),
      department: current.department.trim(),
    );
    update((EditPersonalDataUiState s) => s.copyWith(isSaving: true, errorMessage: null));
    try {
      await updatePersonalData.execute(
        id: id,
        name: name,
        birthDate: birthDate,
        email: email,
        phoneNumber: phone,
        address: address,
      );
      update((EditPersonalDataUiState s) => s.copyWith(isSaving: false, isSaved: true));
    } catch (error) {
      update((EditPersonalDataUiState s) =>
          s.copyWith(isSaving: false, errorMessage: workspaceErrorMessage(error, fallback: 'No se pudo guardar.')));
    }
  }

  T? _validate<T>(Map<PersonalDataField, String> errors, PersonalDataField field, T Function() block) {
    try {
      return block();
    } on ArgumentError catch (error) {
      errors[field] = error.message?.toString() ?? 'Dato inválido.';
      return null;
    }
  }

  void _updateField(PersonalDataField field, EditPersonalDataUiState Function(EditPersonalDataUiState) transform) {
    update((EditPersonalDataUiState s) {
      final Map<PersonalDataField, String> errors = Map<PersonalDataField, String>.of(s.fieldErrors)..remove(field);
      return transform(s).copyWith(fieldErrors: errors);
    });
  }
}
