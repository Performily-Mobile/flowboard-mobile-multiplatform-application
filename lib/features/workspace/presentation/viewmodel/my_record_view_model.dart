import 'package:flowboard/core/session/current_employee_provider.dart';
import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/workspace/application/usecase/get_employee_documents_use_case.dart';
import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/presentation/state/my_record_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/workspace_error_messages.dart';

/// View model of the documents of the signed-in employee.
class MyRecordViewModel extends ViewModel<MyRecordUiState> {
  /// Creates the view model and loads the documents.
  MyRecordViewModel({required this.currentEmployeeProvider, required this.getEmployeeDocuments})
      : super(const MyRecordUiState()) {
    load();
  }

  final CurrentEmployeeProvider currentEmployeeProvider;
  final GetEmployeeDocumentsUseCase getEmployeeDocuments;

  /// Loads the documents of the record.
  Future<void> load() async {
    update((MyRecordUiState s) => s.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<EmployeeDocument> documents =
          await getEmployeeDocuments.execute(currentEmployeeProvider.currentEmployeeId());
      update((MyRecordUiState s) => s.copyWith(isLoading: false, documents: documents));
    } catch (error) {
      update((MyRecordUiState s) => s.copyWith(isLoading: false, errorMessage: workspaceErrorMessage(error)));
    }
  }

  /// Filters by [category], or shows every document when it is null.
  void onDocumentFilterChange(DocumentCategory? category) =>
      update((MyRecordUiState s) => s.copyWith(documentFilter: category));
}
