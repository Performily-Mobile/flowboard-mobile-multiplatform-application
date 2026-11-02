import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';

const Object _keep = Object();

DateTime _today() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Sheet or dialog open on the employee record.
enum EmployeeAction { none, reassignJob, terminate, terminationBlocked, reinstate, uploadDocument }

/// Values and errors of the job reassignment form.
class ReassignJobForm {
  /// Creates the form; the effective date defaults to today.
  ReassignJobForm({
    this.areaId,
    this.positionId,
    this.directManagerId,
    DateTime? effectiveDate,
    this.positionError,
    this.directManagerError,
  }) : effectiveDate = effectiveDate ?? _today();

  final int? areaId;
  final int? positionId;
  final EmployeeId? directManagerId;
  final DateTime effectiveDate;
  final String? positionError;
  final String? directManagerError;

  /// Copy with the given values replaced.
  ReassignJobForm copyWith({
    Object? areaId = _keep,
    Object? positionId = _keep,
    Object? directManagerId = _keep,
    DateTime? effectiveDate,
    Object? positionError = _keep,
    Object? directManagerError = _keep,
  }) {
    return ReassignJobForm(
      areaId: identical(areaId, _keep) ? this.areaId : areaId as int?,
      positionId: identical(positionId, _keep) ? this.positionId : positionId as int?,
      directManagerId: identical(directManagerId, _keep) ? this.directManagerId : directManagerId as EmployeeId?,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      positionError: identical(positionError, _keep) ? this.positionError : positionError as String?,
      directManagerError:
          identical(directManagerError, _keep) ? this.directManagerError : directManagerError as String?,
    );
  }
}

/// Values and errors of the termination form.
class TerminationForm {
  /// Creates the form.
  const TerminationForm({this.reason, this.terminationDate, this.reasonError, this.dateError});

  final String? reason;
  final DateTime? terminationDate;
  final String? reasonError;
  final String? dateError;

  /// Copy with the given values replaced.
  TerminationForm copyWith({
    Object? reason = _keep,
    Object? terminationDate = _keep,
    Object? reasonError = _keep,
    Object? dateError = _keep,
  }) {
    return TerminationForm(
      reason: identical(reason, _keep) ? this.reason : reason as String?,
      terminationDate: identical(terminationDate, _keep) ? this.terminationDate : terminationDate as DateTime?,
      reasonError: identical(reasonError, _keep) ? this.reasonError : reasonError as String?,
      dateError: identical(dateError, _keep) ? this.dateError : dateError as String?,
    );
  }
}

/// Values and errors of the reinstatement form.
class ReinstateForm {
  /// Creates the form; the reinstatement date defaults to today.
  ReinstateForm({this.areaId, this.positionId, DateTime? reinstatementDate, this.areaError, this.positionError})
      : reinstatementDate = reinstatementDate ?? _today();

  final int? areaId;
  final int? positionId;
  final DateTime reinstatementDate;
  final String? areaError;
  final String? positionError;

  /// Copy with the given values replaced.
  ReinstateForm copyWith({
    Object? areaId = _keep,
    Object? positionId = _keep,
    DateTime? reinstatementDate,
    Object? areaError = _keep,
    Object? positionError = _keep,
  }) {
    return ReinstateForm(
      areaId: identical(areaId, _keep) ? this.areaId : areaId as int?,
      positionId: identical(positionId, _keep) ? this.positionId : positionId as int?,
      reinstatementDate: reinstatementDate ?? this.reinstatementDate,
      areaError: identical(areaError, _keep) ? this.areaError : areaError as String?,
      positionError: identical(positionError, _keep) ? this.positionError : positionError as String?,
    );
  }
}

/// File picked in the system file picker, as the phone describes it.
class SelectedFile {
  /// Creates the description of the file.
  const SelectedFile({required this.uri, required this.name, required this.contentType, required this.sizeInBytes});

  final String uri;
  final String name;
  final String contentType;
  final int sizeInBytes;
}

/// Values and errors of the document upload form.
class UploadDocumentForm {
  /// Creates the form.
  const UploadDocumentForm({this.documentType, this.file, this.documentTypeError, this.fileError});

  final DocumentType? documentType;
  final SelectedFile? file;
  final String? documentTypeError;
  final String? fileError;

  /// Copy with the given values replaced.
  UploadDocumentForm copyWith({
    Object? documentType = _keep,
    Object? file = _keep,
    Object? documentTypeError = _keep,
    Object? fileError = _keep,
  }) {
    return UploadDocumentForm(
      documentType: identical(documentType, _keep) ? this.documentType : documentType as DocumentType?,
      file: identical(file, _keep) ? this.file : file as SelectedFile?,
      documentTypeError: identical(documentTypeError, _keep) ? this.documentTypeError : documentTypeError as String?,
      fileError: identical(fileError, _keep) ? this.fileError : fileError as String?,
    );
  }
}

/// State of the employee record.
class EmployeeDetailUiState {
  /// Creates the state.
  EmployeeDetailUiState({
    this.isLoading = false,
    this.employee,
    this.directManagerName,
    this.jobAssignments = const <JobAssignment>[],
    this.documents = const <EmployeeDocument>[],
    this.documentFilter,
    this.selectedTab = 0,
    this.errorMessage,
    this.activeAction = EmployeeAction.none,
    this.areas = const <Area>[],
    this.positions = const <Position>[],
    this.managerCandidates = const <Employee>[],
    this.subordinates = const <Employee>[],
    ReassignJobForm? reassignJobForm,
    this.terminationForm = const TerminationForm(),
    ReinstateForm? reinstateForm,
    this.uploadDocumentForm = const UploadDocumentForm(),
    this.isSaving = false,
    this.actionError,
    this.message,
  })  : reassignJobForm = reassignJobForm ?? ReassignJobForm(),
        reinstateForm = reinstateForm ?? ReinstateForm();

  final bool isLoading;
  final Employee? employee;
  final String? directManagerName;
  final List<JobAssignment> jobAssignments;
  final List<EmployeeDocument> documents;
  final DocumentCategory? documentFilter;
  final int selectedTab;
  final String? errorMessage;
  final EmployeeAction activeAction;
  final List<Area> areas;
  final List<Position> positions;
  final List<Employee> managerCandidates;
  final List<Employee> subordinates;
  final ReassignJobForm reassignJobForm;
  final TerminationForm terminationForm;
  final ReinstateForm reinstateForm;
  final UploadDocumentForm uploadDocumentForm;
  final bool isSaving;
  final String? actionError;
  final String? message;

  /// Documents of the selected category, or all of them.
  List<EmployeeDocument> get filteredDocuments {
    final DocumentCategory? category = documentFilter;
    if (category == null) return documents;
    return documents.where((EmployeeDocument document) => document.documentType.category == category).toList();
  }

  /// Positions of the area [areaId], or none when no area is selected.
  List<Position> positionsOf(int? areaId) {
    if (areaId == null) return const <Position>[];
    return positions.where((Position position) => position.belongsTo(areaId)).toList();
  }

  /// Copy with the given values replaced.
  EmployeeDetailUiState copyWith({
    bool? isLoading,
    Object? employee = _keep,
    Object? directManagerName = _keep,
    List<JobAssignment>? jobAssignments,
    List<EmployeeDocument>? documents,
    Object? documentFilter = _keep,
    int? selectedTab,
    Object? errorMessage = _keep,
    EmployeeAction? activeAction,
    List<Area>? areas,
    List<Position>? positions,
    List<Employee>? managerCandidates,
    List<Employee>? subordinates,
    ReassignJobForm? reassignJobForm,
    TerminationForm? terminationForm,
    ReinstateForm? reinstateForm,
    UploadDocumentForm? uploadDocumentForm,
    bool? isSaving,
    Object? actionError = _keep,
    Object? message = _keep,
  }) {
    return EmployeeDetailUiState(
      isLoading: isLoading ?? this.isLoading,
      employee: identical(employee, _keep) ? this.employee : employee as Employee?,
      directManagerName: identical(directManagerName, _keep) ? this.directManagerName : directManagerName as String?,
      jobAssignments: jobAssignments ?? this.jobAssignments,
      documents: documents ?? this.documents,
      documentFilter: identical(documentFilter, _keep) ? this.documentFilter : documentFilter as DocumentCategory?,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      activeAction: activeAction ?? this.activeAction,
      areas: areas ?? this.areas,
      positions: positions ?? this.positions,
      managerCandidates: managerCandidates ?? this.managerCandidates,
      subordinates: subordinates ?? this.subordinates,
      reassignJobForm: reassignJobForm ?? this.reassignJobForm,
      terminationForm: terminationForm ?? this.terminationForm,
      reinstateForm: reinstateForm ?? this.reinstateForm,
      uploadDocumentForm: uploadDocumentForm ?? this.uploadDocumentForm,
      isSaving: isSaving ?? this.isSaving,
      actionError: identical(actionError, _keep) ? this.actionError : actionError as String?,
      message: identical(message, _keep) ? this.message : message as String?,
    );
  }
}
