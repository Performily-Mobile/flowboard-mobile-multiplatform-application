import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/create_area_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/create_position_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/deactivate_area_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_positions_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the areas and positions of the organization.
class OrganizationViewModel extends ViewModel<OrganizationUiState> {
  /// Creates the view model and loads areas and positions.
  OrganizationViewModel({
    required this.getAreas,
    required this.getPositions,
    required this.createArea,
    required this.createPosition,
    required this.deactivateArea,
  }) : super(const OrganizationUiState()) {
    load();
  }

  final GetAreasUseCase getAreas;
  final GetPositionsUseCase getPositions;
  final CreateAreaUseCase createArea;
  final CreatePositionUseCase createPosition;
  final DeactivateAreaUseCase deactivateArea;

  /// Loads areas and positions at the same time.
  Future<void> load() async {
    update((OrganizationUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    final Future<List<Area>> areasRequest = getAreas.execute();
    final Future<List<Position>> positionsRequest = getPositions.execute();
    Object? failure;
    List<Area>? areas;
    List<Position>? positions;
    try {
      areas = await areasRequest;
    } catch (error) {
      failure = error;
    }
    try {
      positions = await positionsRequest;
    } catch (error) {
      failure ??= error;
    }
    update((OrganizationUiState s) => s.copyWith(
          isLoading: false,
          areas: areas ?? s.areas,
          positions: positions ?? s.positions,
          errorMessage: failure == null ? null : workspaceErrorMessage(failure),
        ));
  }

  /// Selects the tab [index] (0 areas, 1 positions).
  void onTabSelected(int index) => update((OrganizationUiState s) => s.copyWith(selectedTab: index));

  /// Opens an empty new area form.
  void showAreaSheet() =>
      update((OrganizationUiState s) => s.copyWith(isAreaSheetVisible: true, areaForm: const AreaForm()));

  /// Opens an empty new position form.
  void showPositionSheet() =>
      update((OrganizationUiState s) => s.copyWith(isPositionSheetVisible: true, positionForm: const PositionForm()));

  /// Closes both forms.
  void dismissSheets() =>
      update((OrganizationUiState s) => s.copyWith(isAreaSheetVisible: false, isPositionSheetVisible: false));

  /// Changes the name of the new area.
  void onAreaNameChange(String value) =>
      update((OrganizationUiState s) => s.copyWith(areaForm: s.areaForm.copyWith(name: value, nameError: null)));

  /// Changes the description of the new area.
  void onAreaDescriptionChange(String value) =>
      update((OrganizationUiState s) => s.copyWith(areaForm: s.areaForm.copyWith(description: value)));

  /// Changes the area of the new position.
  void onPositionAreaChange(int areaId) => update((OrganizationUiState s) =>
      s.copyWith(positionForm: s.positionForm.copyWith(areaId: areaId, areaError: null)));

  /// Changes the title of the new position.
  void onPositionTitleChange(String value) => update((OrganizationUiState s) =>
      s.copyWith(positionForm: s.positionForm.copyWith(title: value, titleError: null)));

  /// Changes the reference salary of the new position.
  void onPositionSalaryChange(String value) => update((OrganizationUiState s) =>
      s.copyWith(positionForm: s.positionForm.copyWith(referenceSalary: value, salaryError: null)));

  /// Creates the area, rejecting a name that already exists.
  Future<void> saveArea() async {
    final AreaForm form = state.areaForm;
    final bool duplicated =
        state.areas.any((Area area) => area.name.toLowerCase() == form.name.trim().toLowerCase());
    if (duplicated) {
      update((OrganizationUiState s) =>
          s.copyWith(areaForm: form.copyWith(nameError: 'Ya existe un área con este nombre.')));
      return;
    }
    update((OrganizationUiState s) => s.copyWith(isSaving: true));
    try {
      await createArea.execute(form.name, form.description);
      update((OrganizationUiState s) => s.copyWith(isSaving: false, isAreaSheetVisible: false));
      load();
    } catch (error) {
      update((OrganizationUiState s) => s.copyWith(
            isSaving: false,
            areaForm: s.areaForm.copyWith(nameError: workspaceErrorMessage(error, fallback: 'No se pudo guardar.')),
          ));
    }
  }

  /// Creates the position after checking the area and the amount.
  Future<void> savePosition() async {
    final PositionForm form = state.positionForm;
    final int? areaId = form.areaId;
    final double? amount = _parseAmount(form.referenceSalary);
    if (areaId == null || amount == null) {
      update((OrganizationUiState s) => s.copyWith(
            positionForm: form.copyWith(
              areaError: areaId == null ? 'Selecciona un área.' : null,
              salaryError: amount == null ? 'Ingresa un monto válido.' : null,
            ),
          ));
      return;
    }
    update((OrganizationUiState s) => s.copyWith(isSaving: true));
    final Money money;
    try {
      money = Money(amount: amount);
    } on ArgumentError catch (error) {
      update((OrganizationUiState s) => s.copyWith(
            isSaving: false,
            positionForm: s.positionForm.copyWith(salaryError: error.message?.toString()),
          ));
      return;
    }
    try {
      await createPosition.execute(form.title, areaId, money);
      update((OrganizationUiState s) => s.copyWith(isSaving: false, isPositionSheetVisible: false));
      load();
    } catch (error) {
      update((OrganizationUiState s) => s.copyWith(
            isSaving: false,
            positionForm:
                s.positionForm.copyWith(titleError: workspaceErrorMessage(error, fallback: 'No se pudo guardar.')),
          ));
    }
  }

  /// Opens the confirmation to deactivate [area].
  void requestDeactivateArea(Area area) => update((OrganizationUiState s) =>
      s.copyWith(areaToDeactivate: area, deactivationConfirmed: false, deactivationError: null));

  /// Marks or unmarks the confirmation checkbox.
  void onDeactivationConfirmedChange(bool confirmed) =>
      update((OrganizationUiState s) => s.copyWith(deactivationConfirmed: confirmed));

  /// Closes the deactivation dialog.
  void dismissDeactivateArea() =>
      update((OrganizationUiState s) => s.copyWith(areaToDeactivate: null, deactivationError: null));

  /// Deactivates the area once the user confirmed.
  Future<void> confirmDeactivateArea() async {
    final Area? area = state.areaToDeactivate;
    if (area == null || !state.deactivationConfirmed) return;
    update((OrganizationUiState s) => s.copyWith(isSaving: true, deactivationError: null));
    try {
      await deactivateArea.execute(area);
      update((OrganizationUiState s) => s.copyWith(isSaving: false, areaToDeactivate: null));
      load();
    } catch (error) {
      update((OrganizationUiState s) => s.copyWith(
            isSaving: false,
            deactivationError: workspaceErrorMessage(error, fallback: 'No se pudo guardar.'),
          ));
    }
  }

  double? _parseAmount(String raw) => double.tryParse(raw.replaceAll('S/', '').replaceAll(',', '').trim());
}
