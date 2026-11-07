import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/assign_benefit_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_assignment_targets_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/get_benefit_types_use_case.dart';
import 'package:flowboard/features/benefits/application/usecase/preview_area_assignment_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/assignment_batch.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_target.dart';
import 'package:flowboard/features/benefits/presentation/state/assign_benefit_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the assign benefit screen (MA-61, US38).
///
/// When "Área completa" is chosen it asks the backend for the preview, to show how many employees
/// will receive the benefit and how many will be skipped.
class AssignBenefitViewModel extends ViewModel<AssignBenefitUiState> {
  /// Creates the view model and loads the options of the form.
  AssignBenefitViewModel({
    required this.getBenefitTypes,
    required this.getTargets,
    required this.previewAreaAssignment,
    required this.assignBenefit,
  }) : super(AssignBenefitUiState.initial()) {
    load();
  }

  final GetBenefitTypesUseCase getBenefitTypes;
  final GetAssignmentTargetsUseCase getTargets;
  final PreviewAreaAssignmentUseCase previewAreaAssignment;
  final AssignBenefitUseCase assignBenefit;

  int _previewRequest = 0;

  /// Loads the active types, the areas and the employees at the same time.
  Future<void> load() async {
    update((AssignBenefitUiState s) => s.copyWith(isLoading: true, loadError: null));
    final Future<List<BenefitType>> typesRequest = getBenefitTypes.execute(activeOnly: true);
    final Future<List<AreaOption>> areasRequest = getTargets.areas();
    final Future<List<EmployeeOption>> employeesRequest = getTargets.employees();
    Object? failure;
    List<BenefitType>? types;
    List<AreaOption>? areas;
    List<EmployeeOption>? employees;
    try {
      types = await typesRequest;
    } catch (error) {
      failure = error;
    }
    try {
      areas = await areasRequest;
    } catch (error) {
      failure ??= error;
    }
    try {
      employees = await employeesRequest;
    } catch (error) {
      failure ??= error;
    }
    update((AssignBenefitUiState s) => s.copyWith(
          isLoading: false,
          benefitTypes: types ?? const <BenefitType>[],
          areas: areas ?? const <AreaOption>[],
          employees: employees ?? const <EmployeeOption>[],
          loadError: failure == null
              ? null
              : benefitsMessage(failure, BenefitsAction.load, 'No se pudieron cargar los datos del formulario.'),
        ));
  }

  /// Selects the benefit type.
  void onTypeSelected(BenefitType type) {
    update((AssignBenefitUiState s) => s.copyWith(selectedType: type, quantityError: null, errorMessage: null));
    _refreshPreview();
  }

  /// Chooses between one employee and a whole area.
  void onModeSelected(AssignTargetMode mode) {
    update((AssignBenefitUiState s) => s.copyWith(mode: mode, preview: null, previewError: null, errorMessage: null));
    _refreshPreview();
  }

  /// Selects the area.
  void onAreaSelected(AreaOption area) {
    update((AssignBenefitUiState s) =>
        s.copyWith(selectedArea: area, preview: null, previewError: null, errorMessage: null));
    _refreshPreview();
  }

  /// Selects the employee.
  void onEmployeeSelected(EmployeeOption employee) =>
      update((AssignBenefitUiState s) => s.copyWith(selectedEmployee: employee, errorMessage: null));

  /// Updates the quantity keeping only digits and a single decimal point.
  void onQuantityChange(String value) {
    final String clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if ('.'.allMatches(clean).length > 1) return;
    update((AssignBenefitUiState s) => s.copyWith(quantity: clean, quantityError: null, errorMessage: null));
  }

  /// Updates the start date; when it moves past the end date, the end date moves with it.
  void onStartDateChange(DateTime date) {
    update((AssignBenefitUiState s) => s.copyWith(
          startDate: date,
          endDate: s.endDate.isBefore(date) ? date : s.endDate,
          dateError: null,
          errorMessage: null,
        ));
    _refreshPreview();
  }

  /// Updates the end date, which can never be before the start date.
  void onEndDateChange(DateTime date) {
    update((AssignBenefitUiState s) => s.copyWith(
          endDate: date.isBefore(s.startDate) ? s.startDate : date,
          dateError: null,
          errorMessage: null,
        ));
    _refreshPreview();
  }

  /// Asks again for the area preview; answers of older requests are ignored.
  Future<void> _refreshPreview() async {
    final int request = ++_previewRequest;
    final AssignBenefitUiState current = state;
    final BenefitType? type = current.selectedType;
    final AreaOption? area = current.selectedArea;
    if (current.mode != AssignTargetMode.area ||
        type == null ||
        area == null ||
        current.endDate.isBefore(current.startDate)) {
      update((AssignBenefitUiState s) => s.copyWith(preview: null, previewError: null, isLoadingPreview: false));
      return;
    }
    update((AssignBenefitUiState s) => s.copyWith(isLoadingPreview: true, previewError: null));
    try {
      final AreaAssignmentPreview preview =
          await previewAreaAssignment.execute(type.id, area.id, current.startDate, current.endDate);
      if (request != _previewRequest) return;
      update((AssignBenefitUiState s) => s.copyWith(isLoadingPreview: false, preview: preview, previewError: null));
    } catch (error) {
      if (request != _previewRequest) return;
      update((AssignBenefitUiState s) => s.copyWith(
            isLoadingPreview: false,
            preview: null,
            previewError: benefitsMessage(error, BenefitsAction.load, 'No se pudo calcular cuántos colaboradores lo recibirán.'),
          ));
    }
  }

  /// Validates the form and assigns the benefit.
  Future<void> onSubmit() async {
    final AssignBenefitUiState current = state;
    final BenefitType? type = current.selectedType;
    if (current.isSubmitting || type == null) return;
    final double? quantity = double.tryParse(current.quantity);
    if (quantity == null) {
      update((AssignBenefitUiState s) => s.copyWith(quantityError: 'Ingresa una cantidad válida.'));
      return;
    }
    final AssignmentValidationError? validation =
        AssignBenefitUseCase.validate(type, quantity, current.startDate, current.endDate);
    if (validation != null) {
      update((AssignBenefitUiState s) => switch (validation.field) {
            AssignmentField.dates => s.copyWith(dateError: validation.message),
            AssignmentField.quantity => s.copyWith(quantityError: validation.message),
            AssignmentField.type => s.copyWith(errorMessage: validation.message),
          });
      return;
    }
    final AssignmentTarget? target = switch (current.mode) {
      AssignTargetMode.employee => current.selectedEmployee == null ? null : EmployeeTarget(current.selectedEmployee!.id),
      AssignTargetMode.area => current.selectedArea == null ? null : AreaTarget(current.selectedArea!.id),
    };
    if (target == null) return;
    final BenefitsAction action =
        current.mode == AssignTargetMode.area ? BenefitsAction.assignToArea : BenefitsAction.assignToEmployee;

    update((AssignBenefitUiState s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final AssignmentBatch batch =
          await assignBenefit.execute(type, target, quantity, current.startDate, current.endDate);
      update((AssignBenefitUiState s) => s.copyWith(isSubmitting: false, resultMessage: _resultMessage(type, batch, current)));
    } catch (error) {
      update((AssignBenefitUiState s) => s.copyWith(
            isSubmitting: false,
            errorMessage: benefitsMessage(error, action, 'No se pudo asignar el beneficio.'),
          ));
    }
  }

  String _resultMessage(BenefitType type, AssignmentBatch batch, AssignBenefitUiState state) {
    if (state.mode == AssignTargetMode.employee) {
      return '${type.name} asignado a ${state.selectedEmployee?.name ?? 'el colaborador'}.';
    }
    final String assigned =
        '${type.name} asignado a ${batch.assignedCount} ${batch.assignedCount == 1 ? 'colaborador.' : 'colaboradores.'}';
    return batch.skippedCount > 0 ? '$assigned ${batch.skippedCount} omitido(s) por ya tenerlo.' : assigned;
  }
}
