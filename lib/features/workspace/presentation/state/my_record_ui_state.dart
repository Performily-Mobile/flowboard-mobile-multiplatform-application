import 'package:flowboard/features/workspace/domain/entity/employee_document.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';

const Object _keep = Object();

/// State of the documents of the signed-in employee.
class MyRecordUiState {
  /// Creates the state.
  const MyRecordUiState({
    this.isLoading = false,
    this.documents = const <EmployeeDocument>[],
    this.documentFilter,
    this.errorMessage,
  });

  final bool isLoading;
  final List<EmployeeDocument> documents;
  final DocumentCategory? documentFilter;
  final String? errorMessage;

  /// Documents of the selected category, or all of them.
  List<EmployeeDocument> get filteredDocuments {
    final DocumentCategory? category = documentFilter;
    if (category == null) return documents;
    return documents.where((EmployeeDocument document) => document.documentType.category == category).toList();
  }

  /// Copy with the given values replaced.
  MyRecordUiState copyWith({
    bool? isLoading,
    List<EmployeeDocument>? documents,
    Object? documentFilter = _keep,
    Object? errorMessage = _keep,
  }) {
    return MyRecordUiState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      documentFilter: identical(documentFilter, _keep) ? this.documentFilter : documentFilter as DocumentCategory?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
