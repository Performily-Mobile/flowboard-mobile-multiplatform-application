import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';

const Object _keep = Object();

/// Options of the "Asignar a" selector: one employee or a whole area.
enum AssignTargetMode {
  employee('Colaborador'),
  area('Área completa');

  const AssignTargetMode(this.label);

  /// Text of the option.
  final String label;
}

/// State of the assign benefit screen (MA-61). The validity period defaults to the current month.
class AssignBenefitUiState {
  /// Creates the state.
  const AssignBenefitUiState({
    required this.startDate,
    required this.endDate,
    this.isLoading = false,
    this.loadError,
    this.benefitTypes = const <BenefitType>[],
    this.areas = const <AreaOption>[],
    this.employees = const <EmployeeOption>[],
    this.selectedType,
    this.mode = AssignTargetMode.employee,
    this.selectedArea,
    this.selectedEmployee,
    this.quantity = '',
    this.preview,
    this.isLoadingPreview = false,
    this.previewError,
    this.quantityError,
    this.dateError,
    this.errorMessage,
    this.isSubmitting = false,
    this.resultMessage,
  });

  /// Initial state with the current month as the validity period.
  factory AssignBenefitUiState.initial({DateTime? today}) {
    final DateTime now = today ?? DateTime.now();
    return AssignBenefitUiState(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
    );
  }

  final bool isLoading;
  final String? loadError;
  final List<BenefitType> benefitTypes;
  final List<AreaOption> areas;
  final List<EmployeeOption> employees;
  final BenefitType? selectedType;
  final AssignTargetMode mode;
  final AreaOption? selectedArea;
  final EmployeeOption? selectedEmployee;
  final String quantity;
  final DateTime startDate;
  final DateTime endDate;
  final AreaAssignmentPreview? preview;
  final bool isLoadingPreview;

  /// While set, assigning to an area is blocked until the preview is computed successfully.
  final String? previewError;
  final String? quantityError;
  final String? dateError;
  final String? errorMessage;
  final bool isSubmitting;

  /// When set, the assignment was made and the screen returns with this message.
  final String? resultMessage;

  /// True when the employee or the area was chosen.
  bool get hasTarget => mode == AssignTargetMode.area ? selectedArea != null : selectedEmployee != null;

  /// True when assigning to an area where every employee already has the benefit.
  bool get nothingToAssign => mode == AssignTargetMode.area && preview != null && preview!.toAssign == 0;

  /// True when the form can be sent.
  bool get canSubmit =>
      !isSubmitting &&
      selectedType != null &&
      hasTarget &&
      quantity.trim().isNotEmpty &&
      !nothingToAssign &&
      !(mode == AssignTargetMode.area && previewError != null);

  /// "Asignar a 46 colaboradores" when the area preview is available, otherwise "Asignar beneficio".
  String get submitLabel {
    final int? count = preview?.toAssign;
    if (mode == AssignTargetMode.area && count != null && count > 0) {
      return 'Asignar a $count ${count == 1 ? 'colaborador' : 'colaboradores'}';
    }
    return 'Asignar beneficio';
  }

  /// Copy with the given values replaced.
  AssignBenefitUiState copyWith({
    bool? isLoading,
    Object? loadError = _keep,
    List<BenefitType>? benefitTypes,
    List<AreaOption>? areas,
    List<EmployeeOption>? employees,
    Object? selectedType = _keep,
    AssignTargetMode? mode,
    Object? selectedArea = _keep,
    Object? selectedEmployee = _keep,
    String? quantity,
    DateTime? startDate,
    DateTime? endDate,
    Object? preview = _keep,
    bool? isLoadingPreview,
    Object? previewError = _keep,
    Object? quantityError = _keep,
    Object? dateError = _keep,
    Object? errorMessage = _keep,
    bool? isSubmitting,
    Object? resultMessage = _keep,
  }) {
    return AssignBenefitUiState(
      isLoading: isLoading ?? this.isLoading,
      loadError: identical(loadError, _keep) ? this.loadError : loadError as String?,
      benefitTypes: benefitTypes ?? this.benefitTypes,
      areas: areas ?? this.areas,
      employees: employees ?? this.employees,
      selectedType: identical(selectedType, _keep) ? this.selectedType : selectedType as BenefitType?,
      mode: mode ?? this.mode,
      selectedArea: identical(selectedArea, _keep) ? this.selectedArea : selectedArea as AreaOption?,
      selectedEmployee:
          identical(selectedEmployee, _keep) ? this.selectedEmployee : selectedEmployee as EmployeeOption?,
      quantity: quantity ?? this.quantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      preview: identical(preview, _keep) ? this.preview : preview as AreaAssignmentPreview?,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      previewError: identical(previewError, _keep) ? this.previewError : previewError as String?,
      quantityError: identical(quantityError, _keep) ? this.quantityError : quantityError as String?,
      dateError: identical(dateError, _keep) ? this.dateError : dateError as String?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resultMessage: identical(resultMessage, _keep) ? this.resultMessage : resultMessage as String?,
    );
  }
}
