import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/presentation/state/my_record_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/documents_tab.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/message_state.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/my_record_view_model.dart';

/// Documents of the signed-in employee, filtered by category.
class MyRecordScreen extends StatefulWidget {
  /// Creates the screen.
  const MyRecordScreen({super.key});

  @override
  State<MyRecordScreen> createState() => _MyRecordScreenState();
}

class _MyRecordScreenState extends State<MyRecordScreen> {
  late final MyRecordViewModel _viewModel = getIt<MyRecordViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final MyRecordUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Mi expediente', onBack: () => Navigator.of(context).maybePop()),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyRecordUiState state) {
    if (state.isLoading && state.documents.isEmpty) return const SkeletonList(itemCount: 4, showTrailing: false);
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.documents.isEmpty) {
      return MessageState(
        title: 'Expediente no disponible',
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
        topPadding: AppSpacing.xl,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl + bottomInset),
      child: DocumentsTab(
        documents: state.filteredDocuments,
        selectedCategory: state.documentFilter,
        onCategoryChange: _viewModel.onDocumentFilterChange,
      ),
    );
  }
}
