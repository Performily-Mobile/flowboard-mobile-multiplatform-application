import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';

const Object _keep = Object();

/// Values and errors of the new area form.
class AreaForm {
  /// Creates the form.
  const AreaForm({this.name = '', this.description = '', this.nameError});

  final String name;
  final String description;
  final String? nameError;

  /// Copy with the given values replaced.
  AreaForm copyWith({String? name, String? description, Object? nameError = _keep}) {
    return AreaForm(
      name: name ?? this.name,
      description: description ?? this.description,
      nameError: identical(nameError, _keep) ? this.nameError : nameError as String?,
    );
  }
}

/// Values and errors of the new position form.
class PositionForm {
  /// Creates the form.
  const PositionForm({
    this.areaId,
    this.title = '',
    this.referenceSalary = '',
    this.areaError,
    this.titleError,
    this.salaryError,
  });

  final int? areaId;
  final String title;
  final String referenceSalary;
  final String? areaError;
  final String? titleError;
  final String? salaryError;

  /// Copy with the given values replaced.
  PositionForm copyWith({
    Object? areaId = _keep,
    String? title,
    String? referenceSalary,
    Object? areaError = _keep,
    Object? titleError = _keep,
    Object? salaryError = _keep,
  }) {
    return PositionForm(
      areaId: identical(areaId, _keep) ? this.areaId : areaId as int?,
      title: title ?? this.title,
      referenceSalary: referenceSalary ?? this.referenceSalary,
      areaError: identical(areaError, _keep) ? this.areaError : areaError as String?,
      titleError: identical(titleError, _keep) ? this.titleError : titleError as String?,
      salaryError: identical(salaryError, _keep) ? this.salaryError : salaryError as String?,
    );
  }
}

/// State of the areas and positions screen.
class OrganizationUiState {
  /// Creates the state.
  const OrganizationUiState({
    this.selectedTab = 0,
    this.isLoading = false,
    this.areas = const <Area>[],
    this.positions = const <Position>[],
    this.errorMessage,
    this.isAreaSheetVisible = false,
    this.isPositionSheetVisible = false,
    this.areaForm = const AreaForm(),
    this.positionForm = const PositionForm(),
    this.isSaving = false,
    this.areaToDeactivate,
    this.deactivationConfirmed = false,
    this.deactivationError,
  });

  final int selectedTab;
  final bool isLoading;
  final List<Area> areas;
  final List<Position> positions;
  final String? errorMessage;
  final bool isAreaSheetVisible;
  final bool isPositionSheetVisible;
  final AreaForm areaForm;
  final PositionForm positionForm;
  final bool isSaving;
  final Area? areaToDeactivate;
  final bool deactivationConfirmed;
  final String? deactivationError;

  /// Active areas, offered when creating a position.
  List<Area> get activeAreas => areas.where((Area area) => area.active).toList();

  /// Copy with the given values replaced.
  OrganizationUiState copyWith({
    int? selectedTab,
    bool? isLoading,
    List<Area>? areas,
    List<Position>? positions,
    Object? errorMessage = _keep,
    bool? isAreaSheetVisible,
    bool? isPositionSheetVisible,
    AreaForm? areaForm,
    PositionForm? positionForm,
    bool? isSaving,
    Object? areaToDeactivate = _keep,
    bool? deactivationConfirmed,
    Object? deactivationError = _keep,
  }) {
    return OrganizationUiState(
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      areas: areas ?? this.areas,
      positions: positions ?? this.positions,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      isAreaSheetVisible: isAreaSheetVisible ?? this.isAreaSheetVisible,
      isPositionSheetVisible: isPositionSheetVisible ?? this.isPositionSheetVisible,
      areaForm: areaForm ?? this.areaForm,
      positionForm: positionForm ?? this.positionForm,
      isSaving: isSaving ?? this.isSaving,
      areaToDeactivate: identical(areaToDeactivate, _keep) ? this.areaToDeactivate : areaToDeactivate as Area?,
      deactivationConfirmed: deactivationConfirmed ?? this.deactivationConfirmed,
      deactivationError: identical(deactivationError, _keep) ? this.deactivationError : deactivationError as String?,
    );
  }
}
