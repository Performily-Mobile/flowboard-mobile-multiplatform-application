import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/state/request_types_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_cards.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_dialogs.dart';
import 'package:flowboard/features/request/presentation/ui/navigation/request_navigation.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_types_view_model.dart';

/// Catalog of request types for HR, where types can be created, activated, deactivated or deleted.
class RequestTypesScreen extends StatefulWidget {
  /// Creates the screen.
  const RequestTypesScreen({super.key});

  @override
  State<RequestTypesScreen> createState() => _RequestTypesScreenState();
}

class _RequestTypesScreenState extends State<RequestTypesScreen> {
  late final RequestTypesViewModel _viewModel = getIt<RequestTypesViewModel>();
  late final ModalSync<int> _deleteDialog =
      ModalSync<int>(open: _openDeleteDialog, onDismissed: _viewModel.dismissDelete);

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final RequestTypesUiState state = _viewModel.state;
    _deleteDialog.sync(context, state.typeToDelete?.id);
    final RequestTypesSnackbar? snackbar = state.snackbar;
    if (snackbar != null) {
      final RequestType? typeToDeactivate = snackbar.typeToDeactivate;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbar.message),
          duration: typeToDeactivate == null ? const Duration(seconds: 4) : const Duration(seconds: 8),
          action: typeToDeactivate == null
              ? null
              : SnackBarAction(label: 'Desactivar', onPressed: () => _viewModel.toggleStatus(typeToDeactivate)),
        ),
      );
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openDeleteDialog(BuildContext context, int typeId) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final RequestType? type = _viewModel.state.typeToDelete;
          if (type == null) return const SizedBox.shrink();
          return DeleteRequestTypeDialog(
            typeName: type.name,
            isDeleting: _viewModel.state.isWorking,
            onConfirm: _viewModel.confirmDelete,
            onDismiss: _viewModel.dismissDelete,
          );
        },
      ),
    );
  }

  Future<void> _openNewType() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(RequestRoutes.newRequestType);
    if (mounted && result is String) _viewModel.onCreated(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewType,
        tooltip: 'Nuevo tipo',
        icon: const Icon(FlowboardIcons.add),
        label: const Text('Nuevo tipo'),
      ),
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Tipos de solicitud', onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (BuildContext context, Widget? child) => _buildBody(context, _viewModel.state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, RequestTypesUiState state) {
    if (state.isLoading && state.types.isEmpty) {
      return const SkeletonList(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, 0),
        showAvatar: false,
      );
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.types.isEmpty) {
      return RequestMessageState(
        title: 'No se pudieron cargar los tipos',
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
        topPadding: AppSpacing.xl,
      );
    }
    if (state.types.isEmpty) {
      return const RequestMessageState(
        title: 'Aún no hay tipos de solicitud',
        message: 'Crea el primero con el botón "Nuevo tipo".',
        topPadding: AppSpacing.xl,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8,
        AppSpacing.screenHorizontal,
        AppSpacing.fabClearance + bottomInset,
      ),
      itemCount: state.types.length,
      itemBuilder: (BuildContext context, int index) {
        final RequestType type = state.types[index];
        return Padding(
          key: ValueKey<int>(type.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          child: RequestTypeRow(
            type: type,
            onToggleStatus: () => _viewModel.toggleStatus(type),
            onDelete: () => _viewModel.requestDelete(type),
          ),
        );
      },
    );
  }
}
