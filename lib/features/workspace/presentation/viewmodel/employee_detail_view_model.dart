import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/assign_direct_manager_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/assign_job_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/attach_employee_document_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_areas_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_by_id_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_documents_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employees_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_job_assignments_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_positions_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/get_subordinates_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/reinstate_employee_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/remove_direct_manager_use_case.dart';
import 'package:flowboard/features/workspace/application/usecase/terminate_employee_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_upload.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/termination_details.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

DateTime _today() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// View model of the employee record and its actions.
class EmployeeDetailViewModel extends ViewModel<EmployeeDetailUiState> {
  /// Creates the view model.
  EmployeeDetailViewModel({
    required this.getEmployeeById,
    required this.getJobAssignments,
    required this.getEmployeeDocuments,
    required this.getAreas,
    required this.getPositions,
    required this.getEmployees,
    required this.getSubordinates,
    required this.assignJob,
    required this.assignDirectManager,
    required this.removeDirectManager,
    required this.terminateEmployee,
    required this.reinstateEmployee,
    required this.attachEmployeeDocument,
  }) : super(EmployeeDetailUiState());

  final GetEmployeeByIdUseCase getEmployeeById;
  final GetJobAssignmentsUseCase getJobAssignments;
  final GetEmployeeDocumentsUseCase getEmployeeDocuments;
  final GetAreasUseCase getAreas;
  final GetPositionsUseCase getPositions;
  final GetEmployeesUseCase getEmployees;
  final GetSubordinatesUseCase getSubordinates;
  final AssignJobUseCase assignJob;
  final AssignDirectManagerUseCase assignDirectManager;
  final RemoveDirectManagerUseCase removeDirectManager;
  final TerminateEmployeeUseCase terminateEmployee;
  final ReinstateEmployeeUseCase reinstateEmployee;
  final AttachEmployeeDocumentUseCase attachEmployeeDocument;

  /// Loads the employee detail, documents and job history.
  Future<void> load(int employeeId) async {
    final EmployeeId id = EmployeeId(employeeId);
    update((EmployeeDetailUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    final Future<List<JobAssignment>?> assignmentsRequest = attemptOrNull(() => getJobAssignments.execute(id));
    final Future<List<EmployeeDocument>?> documentsRequest = attemptOrNull(() => getEmployeeDocuments.execute(id));
    try {
      final Employee employee = await getEmployeeById.execute(id);
      String? managerName;
      final EmployeeId? managerId = employee.directManagerId;
      if (managerId != null) {
        final Employee? manager = await attemptOrNull(() => getEmployeeById.execute(managerId));
        if (manager != null) managerName = '${manager.name.fullName} · ${manager.positionTitle}';
      }
      final List<JobAssignment> assignments = await assignmentsRequest ?? const <JobAssignment>[];
      final List<EmployeeDocument> documents = await documentsRequest ?? const <EmployeeDocument>[];
      update((EmployeeDetailUiState s) => s.copyWith(
            isLoading: false,
            employee: employee,
            directManagerName: managerName,
            jobAssignments: assignments,
            documents: documents,
          ));
    } catch (error) {
      update((EmployeeDetailUiState s) => s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  void _reload() {
    final Employee? employee = state.employee;
    if (employee != null) load(employee.id.value);
  }

  /// Selects the tab [index].
  void onTabSelected(int index) => update((EmployeeDetailUiState s) => s.copyWith(selectedTab: index));

  /// Filters the documents by [category], or shows all of them with null.
  void onDocumentFilterChange(DocumentCategory? category) =>
      update((EmployeeDetailUiState s) => s.copyWith(documentFilter: category));

  /// Closes the open sheet or dialog.
  void dismissAction() =>
      update((EmployeeDetailUiState s) => s.copyWith(activeAction: EmployeeAction.none, actionError: null));

  /// Marks the confirmation message as shown.
  void consumeMessage() => update((EmployeeDetailUiState s) => s.copyWith(message: null));

  /// Loads areas, positions and candidate managers the first time a sheet that needs them is opened.
  Future<void> _loadCatalogs() async {
    if (state.areas.isNotEmpty) return;
    final Future<List<Area>?> areasRequest = attemptOrNull(() => getAreas.execute(onlyActive: true));
    final Future<List<Position>?> positionsRequest = attemptOrNull(() => getPositions.execute(onlyActive: true));
    final Future<List<Employee>?> employeesRequest =
        attemptOrNull(() => getEmployees.execute(status: EmploymentStatus.active));
    final EmployeeId? currentId = state.employee?.id;
    final List<Area> areas = await areasRequest ?? const <Area>[];
    final List<Position> positions = await positionsRequest ?? const <Position>[];
    final List<Employee> candidates = (await employeesRequest ?? const <Employee>[])
        .where((Employee candidate) => candidate.id != currentId)
        .toList();
    update((EmployeeDetailUiState s) => s.copyWith(areas: areas, positions: positions, managerCandidates: candidates));
  }

  /// Opens the job reassignment sheet and loads the catalogs it needs.
  void openReassignJob() {
    final Employee? employee = state.employee;
    if (employee == null) return;
    _loadCatalogs();
    update((EmployeeDetailUiState s) => s.copyWith(
          activeAction: EmployeeAction.reassignJob,
          actionError: null,
          reassignJobForm: ReassignJobForm(
            areaId: employee.areaId,
            positionId: employee.positionId,
            directManagerId: employee.directManagerId,
          ),
        ));
  }

  /// Changes the area of the reassignment; the position must be chosen again.
  void onReassignAreaChange(int areaId) => update((EmployeeDetailUiState s) => s.copyWith(
        reassignJobForm: s.reassignJobForm.copyWith(areaId: areaId, positionId: null, positionError: null),
      ));

  /// Changes the position of the reassignment.
  void onReassignPositionChange(int positionId) => update((EmployeeDetailUiState s) => s.copyWith(
        reassignJobForm: s.reassignJobForm.copyWith(positionId: positionId, positionError: null),
      ));

  /// Changes the direct manager of the reassignment, or removes it with null.
  void onReassignManagerChange(EmployeeId? managerId) => update((EmployeeDetailUiState s) => s.copyWith(
        reassignJobForm: s.reassignJobForm.copyWith(directManagerId: managerId, directManagerError: null),
      ));

  /// Changes the effective date of the reassignment.
  void onReassignDateChange(DateTime date) => update((EmployeeDetailUiState s) =>
      s.copyWith(reassignJobForm: s.reassignJobForm.copyWith(effectiveDate: date)));

  /// Saves the job reassignment.
  ///
  /// The direct manager is updated first because the backend validates that no cycles are created.
  Future<void> saveReassignJob() async {
    final Employee? employee = state.employee;
    if (employee == null) return;
    final ReassignJobForm form = state.reassignJobForm;
    final int? areaId = form.areaId;
    final int? positionId = form.positionId;
    if (areaId == null || positionId == null) {
      update((EmployeeDetailUiState s) =>
          s.copyWith(reassignJobForm: form.copyWith(positionError: 'Selecciona una posición.')));
      return;
    }
    final bool jobChanged = areaId != employee.areaId || positionId != employee.positionId;
    final bool managerChanged = form.directManagerId != employee.directManagerId;
    if (!jobChanged && !managerChanged) {
      dismissAction();
      return;
    }

    update((EmployeeDetailUiState s) => s.copyWith(isSaving: true, actionError: null));
    if (managerChanged) {
      try {
        final EmployeeId? newManager = form.directManagerId;
        if (newManager == null) {
          await removeDirectManager.execute(employee.id);
        } else {
          await assignDirectManager.execute(employee.id, newManager);
        }
      } catch (error) {
        update((EmployeeDetailUiState s) => s.copyWith(
              isSaving: false,
              reassignJobForm: s.reassignJobForm.copyWith(directManagerError: workspaceErrorMessage(error)),
            ));
        return;
      }
    }
    if (jobChanged) {
      try {
        await assignJob.execute(employee.id, areaId, positionId, form.effectiveDate);
      } catch (error) {
        update((EmployeeDetailUiState s) => s.copyWith(isSaving: false, actionError: workspaceErrorMessage(error)));
        return;
      }
    }
    _finishAction('Se actualizó el puesto de ${employee.name.firstName}.');
  }

  /// Opens the termination dialog.
  ///
  /// The direct reports are checked first: if that check fails the dialog is not opened, since
  /// termination cannot proceed without knowing whether the employee has subordinates.
  Future<void> openTerminate() async {
    final Employee? employee = state.employee;
    if (employee == null) return;
    update((EmployeeDetailUiState s) => s.copyWith(isSaving: true, actionError: null));
    final List<Employee> subordinates;
    try {
      subordinates = await getSubordinates.execute(employee.id);
    } catch (error) {
      update((EmployeeDetailUiState s) => s.copyWith(
            isSaving: false,
            message: workspaceErrorMessage(error, fallback: 'No se pudo verificar si tiene subordinados.'),
          ));
      return;
    }
    update((EmployeeDetailUiState s) => s.copyWith(
          isSaving: false,
          subordinates: subordinates,
          activeAction: subordinates.isEmpty ? EmployeeAction.terminate : EmployeeAction.terminationBlocked,
          terminationForm: TerminationForm(terminationDate: _today()),
        ));
  }

  /// Changes the termination reason.
  void onTerminationReasonChange(String reason) => update((EmployeeDetailUiState s) =>
      s.copyWith(terminationForm: s.terminationForm.copyWith(reason: reason, reasonError: null)));

  /// Changes the termination date.
  void onTerminationDateChange(DateTime date) => update((EmployeeDetailUiState s) =>
      s.copyWith(terminationForm: s.terminationForm.copyWith(terminationDate: date, dateError: null)));

  /// Registers the termination of the employee.
  Future<void> saveTermination() async {
    final Employee? employee = state.employee;
    if (employee == null) return;
    final TerminationForm form = state.terminationForm;
    final String? reason = form.reason;
    final DateTime? date = form.terminationDate;
    if (reason == null || reason.trim().isEmpty || date == null) {
      update((EmployeeDetailUiState s) => s.copyWith(
            terminationForm: form.copyWith(
              reasonError: reason == null || reason.trim().isEmpty ? 'Selecciona el motivo de cese.' : null,
              dateError: date == null ? 'Selecciona la fecha de cese.' : null,
            ),
          ));
      return;
    }
    final TerminationDetails details;
    try {
      details = TerminationDetails(reason: reason, terminationDate: date);
    } on ArgumentError catch (error) {
      update((EmployeeDetailUiState s) =>
          s.copyWith(terminationForm: form.copyWith(reasonError: error.message?.toString())));
      return;
    }
    update((EmployeeDetailUiState s) => s.copyWith(isSaving: true, actionError: null));
    try {
      await terminateEmployee.execute(employee.id, details);
      _finishAction('${employee.name.fullName} pasó a estado Cesado.');
    } catch (error) {
      update((EmployeeDetailUiState s) => s.copyWith(isSaving: false, actionError: workspaceErrorMessage(error)));
    }
  }

  /// Opens the reinstatement sheet.
  void openReinstate() {
    final Employee? employee = state.employee;
    if (employee == null) return;
    _loadCatalogs();
    update((EmployeeDetailUiState s) => s.copyWith(
          activeAction: EmployeeAction.reinstate,
          actionError: null,
          reinstateForm: ReinstateForm(areaId: employee.areaId, positionId: employee.positionId),
        ));
  }

  /// Changes the area of the reinstatement; the position must be chosen again.
  void onReinstateAreaChange(int areaId) => update((EmployeeDetailUiState s) => s.copyWith(
        reinstateForm: s.reinstateForm.copyWith(areaId: areaId, positionId: null, areaError: null),
      ));

  /// Changes the position of the reinstatement.
  void onReinstatePositionChange(int positionId) => update((EmployeeDetailUiState s) =>
      s.copyWith(reinstateForm: s.reinstateForm.copyWith(positionId: positionId, positionError: null)));

  /// Changes the reinstatement date.
  void onReinstateDateChange(DateTime date) => update((EmployeeDetailUiState s) =>
      s.copyWith(reinstateForm: s.reinstateForm.copyWith(reinstatementDate: date)));

  /// Reinstates the employee.
  Future<void> saveReinstate() async {
    final Employee? employee = state.employee;
    if (employee == null) return;
    final ReinstateForm form = state.reinstateForm;
    final int? areaId = form.areaId;
    final int? positionId = form.positionId;
    if (areaId == null || positionId == null) {
      update((EmployeeDetailUiState s) => s.copyWith(
            reinstateForm: form.copyWith(
              areaError: areaId == null ? 'Selecciona un área.' : null,
              positionError: positionId == null ? 'Selecciona una posición.' : null,
            ),
          ));
      return;
    }
    update((EmployeeDetailUiState s) => s.copyWith(isSaving: true, actionError: null));
    try {
      await reinstateEmployee.execute(employee.id, areaId, positionId, form.reinstatementDate);
      _finishAction('${employee.name.fullName} fue reincorporado.');
    } catch (error) {
      update((EmployeeDetailUiState s) => s.copyWith(isSaving: false, actionError: workspaceErrorMessage(error)));
    }
  }

  /// Opens the document upload sheet.
  void openUploadDocument() => update((EmployeeDetailUiState s) => s.copyWith(
        activeAction: EmployeeAction.uploadDocument,
        actionError: null,
        uploadDocumentForm: const UploadDocumentForm(),
      ));

  /// Changes the type of the document to upload.
  void onUploadDocumentTypeChange(DocumentType type) => update((EmployeeDetailUiState s) => s.copyWith(
        uploadDocumentForm: s.uploadDocumentForm.copyWith(documentType: type, documentTypeError: null),
      ));

  /// Keeps the picked [file] and shows at once whether it can be uploaded.
  void onFileSelected(SelectedFile file) {
    String? error;
    try {
      _toUpload(file);
    } on ArgumentError catch (exception) {
      error = exception.message?.toString();
    }
    update((EmployeeDetailUiState s) =>
        s.copyWith(uploadDocumentForm: s.uploadDocumentForm.copyWith(file: file, fileError: error)));
  }

  /// Uploads the document to the record.
  Future<void> saveDocument() async {
    final Employee? employee = state.employee;
    if (employee == null) return;
    final UploadDocumentForm form = state.uploadDocumentForm;
    final DocumentType? type = form.documentType;
    final SelectedFile? file = form.file;
    if (type == null || file == null) {
      update((EmployeeDetailUiState s) => s.copyWith(
            uploadDocumentForm: form.copyWith(
              documentTypeError: type == null ? 'Selecciona el tipo de documento.' : null,
              fileError: file == null ? 'Selecciona un archivo.' : form.fileError,
            ),
          ));
      return;
    }
    final DocumentUpload upload;
    try {
      upload = _toUpload(file);
    } on ArgumentError catch (error) {
      update((EmployeeDetailUiState s) =>
          s.copyWith(uploadDocumentForm: form.copyWith(fileError: error.message?.toString())));
      return;
    }
    update((EmployeeDetailUiState s) => s.copyWith(isSaving: true, actionError: null));
    try {
      await attachEmployeeDocument.execute(employee.id, type, upload);
      _finishAction('Documento agregado al expediente.');
    } catch (error) {
      update((EmployeeDetailUiState s) => s.copyWith(isSaving: false, actionError: workspaceErrorMessage(error)));
    }
  }

  void _finishAction(String message) {
    update((EmployeeDetailUiState s) => s.copyWith(
          isSaving: false,
          activeAction: EmployeeAction.none,
          actionError: null,
          message: message,
        ));
    _reload();
  }

  DocumentUpload _toUpload(SelectedFile file) {
    return DocumentUpload(
      sourceUri: file.uri,
      fileName: file.name,
      contentType: file.contentType,
      sizeInBytes: file.sizeInBytes,
    );
  }
}
