import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

const Object _keep = Object();

/// Values of the "Nuevo tipo de beneficio" sheet (MA-60).
class BenefitTypeForm {
  /// Creates the form.
  const BenefitTypeForm({
    this.name = '',
    this.unit = BenefitUnit.money,
    this.hasBalance = false,
    this.nameError,
    this.isSaving = false,
  });

  final String name;
  final BenefitUnit unit;
  final bool hasBalance;
  final String? nameError;
  final bool isSaving;

  /// Copy with the given values replaced.
  BenefitTypeForm copyWith({String? name, BenefitUnit? unit, bool? hasBalance, Object? nameError = _keep, bool? isSaving}) {
    return BenefitTypeForm(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      hasBalance: hasBalance ?? this.hasBalance,
      nameError: identical(nameError, _keep) ? this.nameError : nameError as String?,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Values of the "Registrar entrega" dialog (MA-62).
class DeliveryForm {
  /// Creates the form.
  const DeliveryForm({
    required this.assignment,
    required this.deliveredOn,
    this.notes = '',
    this.error,
    this.isSaving = false,
  });

  final BenefitAssignment assignment;
  final DateTime deliveredOn;
  final String notes;
  final String? error;
  final bool isSaving;

  /// Copy with the given values replaced.
  DeliveryForm copyWith({DateTime? deliveredOn, String? notes, Object? error = _keep, bool? isSaving}) {
    return DeliveryForm(
      assignment: assignment,
      deliveredOn: deliveredOn ?? this.deliveredOn,
      notes: notes ?? this.notes,
      error: identical(error, _keep) ? this.error : error as String?,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// State of the HR benefits screen (MA-60, MA-62). Tab 0: catalog; 1: assignments.
class BenefitsAdminUiState {
  /// Creates the state.
  const BenefitsAdminUiState({
    this.selectedTab = 0,
    this.isLoadingCatalog = false,
    this.benefitTypes = const <BenefitType>[],
    this.catalogError,
    this.assignmentFilter = AssignmentStatus.assigned,
    this.isLoadingAssignments = false,
    this.assignments = const <BenefitAssignment>[],
    this.assignmentsError,
    this.isTypeSheetVisible = false,
    this.typeForm = const BenefitTypeForm(),
    this.typeToToggle,
    this.isTogglingType = false,
    this.deliveryForm,
    this.snackbarMessage,
  });

  final int selectedTab;
  final bool isLoadingCatalog;
  final List<BenefitType> benefitTypes;
  final String? catalogError;
  final AssignmentStatus assignmentFilter;
  final bool isLoadingAssignments;
  final List<BenefitAssignment> assignments;
  final String? assignmentsError;
  final bool isTypeSheetVisible;
  final BenefitTypeForm typeForm;
  final BenefitType? typeToToggle;
  final bool isTogglingType;
  final DeliveryForm? deliveryForm;
  final String? snackbarMessage;

  /// Copy with the given values replaced.
  BenefitsAdminUiState copyWith({
    int? selectedTab,
    bool? isLoadingCatalog,
    List<BenefitType>? benefitTypes,
    Object? catalogError = _keep,
    AssignmentStatus? assignmentFilter,
    bool? isLoadingAssignments,
    List<BenefitAssignment>? assignments,
    Object? assignmentsError = _keep,
    bool? isTypeSheetVisible,
    BenefitTypeForm? typeForm,
    Object? typeToToggle = _keep,
    bool? isTogglingType,
    Object? deliveryForm = _keep,
    Object? snackbarMessage = _keep,
  }) {
    return BenefitsAdminUiState(
      selectedTab: selectedTab ?? this.selectedTab,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      benefitTypes: benefitTypes ?? this.benefitTypes,
      catalogError: identical(catalogError, _keep) ? this.catalogError : catalogError as String?,
      assignmentFilter: assignmentFilter ?? this.assignmentFilter,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      assignments: assignments ?? this.assignments,
      assignmentsError: identical(assignmentsError, _keep) ? this.assignmentsError : assignmentsError as String?,
      isTypeSheetVisible: isTypeSheetVisible ?? this.isTypeSheetVisible,
      typeForm: typeForm ?? this.typeForm,
      typeToToggle: identical(typeToToggle, _keep) ? this.typeToToggle : typeToToggle as BenefitType?,
      isTogglingType: isTogglingType ?? this.isTogglingType,
      deliveryForm: identical(deliveryForm, _keep) ? this.deliveryForm : deliveryForm as DeliveryForm?,
      snackbarMessage: identical(snackbarMessage, _keep) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }
}
