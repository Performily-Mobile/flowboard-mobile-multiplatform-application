import 'package:flowboard/core/domain/email_address.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_positions_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/register_employee_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/address.dart';
import 'package:flowboard/features/workspace/domain/valueobject/birth_date.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_period.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/person_name.dart';
import 'package:flowboard/features/workspace/domain/valueobject/phone_number.dart';
import 'package:flowboard/features/workspace/presentation/state/register_employee_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the two-step employee registration.
class RegisterEmployeeViewModel extends ViewModel<RegisterEmployeeUiState> {
  /// Creates the view model and loads the active areas and the candidate managers.
  RegisterEmployeeViewModel({
    required this.registerEmployee,
    required this.getAreas,
    required this.getPositions,
    required this.getEmployees,
  }) : super(RegisterEmployeeUiState()) {
    _loadCatalogs();
  }

  final RegisterEmployeeUseCase registerEmployee;
  final GetAreasUseCase getAreas;
  final GetPositionsUseCase getPositions;
  final GetEmployeesUseCase getEmployees;

  static const String _required = 'Este campo es obligatorio.';

  static const Set<RegisterField> _personalFields = <RegisterField>{
    RegisterField.firstName,
    RegisterField.lastName,
    RegisterField.documentNumber,
    RegisterField.birthDate,
    RegisterField.email,
    RegisterField.phone,
  };

  Future<void> _loadCatalogs() async {
    final List<Area>? areas = await attemptOrNull(() => getAreas.execute(onlyActive: true));
    if (areas != null) update((RegisterEmployeeUiState s) => s.copyWith(areas: areas));
    final List<Employee>? managers =
        await attemptOrNull(() => getEmployees.execute(status: EmploymentStatus.active));
    if (managers != null) update((RegisterEmployeeUiState s) => s.copyWith(managers: managers));
  }

  /// Changes the first name.
  void onFirstNameChange(String value) => _updateField(RegisterField.firstName, (s) => s.copyWith(firstName: value));

  /// Changes the last name.
  void onLastNameChange(String value) => _updateField(RegisterField.lastName, (s) => s.copyWith(lastName: value));

  /// Changes the type of identity document.
  void onDocumentTypeChange(IdentityDocumentType value) =>
      _updateField(RegisterField.documentNumber, (s) => s.copyWith(documentType: value));

  /// Changes the number of the identity document.
  void onDocumentNumberChange(String value) =>
      _updateField(RegisterField.documentNumber, (s) => s.copyWith(documentNumber: value.trim()));

  /// Changes the birth date.
  void onBirthDateChange(DateTime value) => _updateField(RegisterField.birthDate, (s) => s.copyWith(birthDate: value));

  /// Changes the corporate email.
  void onEmailChange(String value) => _updateField(RegisterField.email, (s) => s.copyWith(email: value.trim()));

  /// Changes the phone.
  void onPhoneChange(String value) => _updateField(RegisterField.phone, (s) => s.copyWith(phoneNumber: value));

  /// Changes the contract type; the end date is kept only for fixed-term contracts.
  void onContractTypeChange(ContractType value) => _updateField(
        RegisterField.contractEndDate,
        (s) => s.copyWith(
          contractType: value,
          contractEndDate: value == ContractType.fixedTerm ? s.contractEndDate : null,
        ),
      );

  /// Changes the hire date.
  void onHireDateChange(DateTime value) => _updateField(RegisterField.hireDate, (s) => s.copyWith(hireDate: value));

  /// Changes the contract end date.
  void onContractEndDateChange(DateTime value) =>
      _updateField(RegisterField.contractEndDate, (s) => s.copyWith(contractEndDate: value));

  /// Changes the area and loads its active positions.
  Future<void> onAreaChange(int areaId) async {
    _updateField(
      RegisterField.area,
      (s) => s.copyWith(areaId: areaId, positionId: null, positions: const <Position>[]),
    );
    final List<Position>? positions =
        await attemptOrNull(() => getPositions.execute(areaId: areaId, onlyActive: true));
    if (positions != null) update((RegisterEmployeeUiState s) => s.copyWith(positions: positions));
  }

  /// Changes the position.
  void onPositionChange(int positionId) =>
      _updateField(RegisterField.position, (s) => s.copyWith(positionId: positionId));

  /// Changes the direct manager, or removes it with null.
  void onDirectManagerChange(EmployeeId? managerId) =>
      update((RegisterEmployeeUiState s) => s.copyWith(directManagerId: managerId));

  /// Validates the personal data and moves to the second step.
  void onContinue() {
    final Map<RegisterField, String> errors = _validatePersonalData();
    update((RegisterEmployeeUiState s) =>
        s.copyWith(fieldErrors: errors, errorMessage: null, step: errors.isEmpty ? 2 : 1));
  }

  /// Goes back to the first step.
  void onBack() => update((RegisterEmployeeUiState s) => s.copyWith(step: 1, errorMessage: null));

  /// Validates both steps and registers the employee.
  Future<void> onSubmit() async {
    final RegisterEmployeeUiState current = state;
    final Map<RegisterField, String> errors = <RegisterField, String>{
      ..._validatePersonalData(),
      ..._validateContract(),
    };
    if (errors.isNotEmpty) {
      final bool personal = errors.keys.any(_personalFields.contains);
      update((RegisterEmployeeUiState s) => s.copyWith(fieldErrors: errors, step: personal ? 1 : 2));
      return;
    }
    update((RegisterEmployeeUiState s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final Employee employee = await registerEmployee.execute(
        name: PersonName(current.firstName.trim(), current.lastName.trim()),
        identityDocument: IdentityDocument(current.documentType, current.documentNumber),
        birthDate: BirthDate(current.birthDate!),
        email: EmailAddress(current.email),
        phoneNumber: PhoneNumber.of(current.phoneNumber),
        address: const Address(),
        contractType: current.contractType,
        employmentPeriod: EmploymentPeriod.of(current.contractType, current.hireDate!, current.contractEndDate),
        areaId: current.areaId!,
        positionId: current.positionId!,
        directManagerId: current.directManagerId,
      );
      update((RegisterEmployeeUiState s) => s.copyWith(isSubmitting: false, registeredEmployeeId: employee.id.value));
    } catch (error) {
      update((RegisterEmployeeUiState s) =>
          s.copyWith(isSubmitting: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  Map<RegisterField, String> _validatePersonalData() {
    final RegisterEmployeeUiState current = state;
    final Map<RegisterField, String> errors = <RegisterField, String>{};
    _validate(errors, RegisterField.firstName, () => PersonName(current.firstName.trim(), 'Apellido'));
    _validate(errors, RegisterField.lastName, () => PersonName('Nombre', current.lastName.trim()));
    _validate(errors, RegisterField.documentNumber, () => IdentityDocument(current.documentType, current.documentNumber));
    _validate(errors, RegisterField.birthDate, () {
      final DateTime? birthDate = current.birthDate;
      if (birthDate == null) throw ArgumentError(_required);
      BirthDate(birthDate);
    });
    _validate(errors, RegisterField.email, () => EmailAddress(current.email));
    _validate(errors, RegisterField.phone, () => PhoneNumber.of(current.phoneNumber));
    return errors;
  }

  Map<RegisterField, String> _validateContract() {
    final RegisterEmployeeUiState current = state;
    final Map<RegisterField, String> errors = <RegisterField, String>{};
    final DateTime? hireDate = current.hireDate;
    if (hireDate == null) errors[RegisterField.hireDate] = _required;
    _validate(errors, RegisterField.contractEndDate, () {
      if (hireDate != null) EmploymentPeriod.of(current.contractType, hireDate, current.contractEndDate);
    });
    if (current.areaId == null) errors[RegisterField.area] = _required;
    if (current.positionId == null) errors[RegisterField.position] = _required;
    return errors;
  }

  void _validate(Map<RegisterField, String> errors, RegisterField field, void Function() block) {
    try {
      block();
    } on ArgumentError catch (error) {
      errors[field] = error.message?.toString() ?? _required;
    }
  }

  void _updateField(RegisterField field, RegisterEmployeeUiState Function(RegisterEmployeeUiState) transform) {
    update((RegisterEmployeeUiState s) {
      final Map<RegisterField, String> errors = Map<RegisterField, String>.of(s.fieldErrors)..remove(field);
      return transform(s).copyWith(fieldErrors: errors);
    });
  }
}
