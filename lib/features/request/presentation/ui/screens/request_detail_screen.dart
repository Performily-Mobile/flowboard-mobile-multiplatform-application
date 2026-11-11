import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/presentation/state/request_detail_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_attachments.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_dialogs.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_history_timeline.dart';
import 'package:flowboard/features/request/presentation/viewmodel/request_detail_view_model.dart';

/// Detail of one of the viewer's requests, with a bottom bar to resubmit or cancel it when allowed.
///
/// It closes with a message once the request is cancelled or resubmitted.
class RequestDetailScreen extends StatefulWidget {
  /// Creates the screen for [requestId].
  const RequestDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late final RequestDetailViewModel _viewModel = getIt<RequestDetailViewModel>();
  late final ModalSync<bool> _cancelDialog =
      ModalSync<bool>(open: _openCancelDialog, onDismissed: _viewModel.dismissCancelDialog);
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load(widget.requestId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted || _closed) return;
    final RequestDetailUiState state = _viewModel.state;
    final String? result = state.resultMessage;
    if (result != null) {
      _closed = true;
      _cancelDialog.sync(context, null);
      Navigator.of(context).pop(result);
      return;
    }
    _cancelDialog.sync(context, state.isCancelDialogVisible ? true : null);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openCancelDialog(BuildContext context, bool visible) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final Request? request = _viewModel.state.request;
          if (request == null) return const SizedBox.shrink();
          final RequestPeriod? period = request.period;
          return CancelRequestDialog(
            message: 'La solicitud de ${request.requestTypeName.toLowerCase()} '
                '${period == null ? '' : 'del ${RequestFormatters.shortRange(period)} '}quedará como cancelada '
                'y se registrará en su historial. Esta acción no se puede deshacer.',
            isCancelling: _viewModel.state.isCancelling,
            onConfirm: _viewModel.confirmCancel,
            onDismiss: _viewModel.dismissCancelDialog,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final RequestDetailUiState state = _viewModel.state;
        final Request? request = state.request;
        final bool showActions = !state.isLoading && request != null && (state.canResubmit || state.canCancel);
        return Scaffold(
          bottomNavigationBar: showActions ? _DetailActions(state: state, viewModel: _viewModel) : null,
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Solicitud ${RequestFormatters.code(widget.requestId)}',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(child: _buildBody(state, request)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(RequestDetailUiState state, Request? request) {
    if (state.isLoading && request == null) return const SkeletonDetail(showTabs: false);
    if (request == null) {
      return RequestMessageState(
        title: 'No se pudo cargar la solicitud',
        message: state.errorMessage ?? 'Inténtalo nuevamente.',
        actionLabel: 'Reintentar',
        onAction: _viewModel.retry,
        topPadding: AppSpacing.xl,
      );
    }
    final List<KeyValue> details = <KeyValue>[
      for (final RequestFieldValue value in request.fieldValues)
        KeyValue(
          state.type?.fieldLabel(value.key) ?? value.key,
          RequestFormatters.fieldValue(state.type?.fieldOf(value.key), value.value),
        ),
      KeyValue('Enviada', RequestFormatters.dateTime(request.submittedAt)),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          _SummaryCard(request: request),
          _ResolutionComment(request: request),
          if (state.canResubmit) ...<Widget>[
            for (final FileReference file in state.attachments)
              AttachmentRow(file: file, onRemove: () => _viewModel.removeAttachment(file)),
            AttachmentZone(
              isRequired: state.type?.requiresAttachment == true,
              isUploading: state.isUploading,
              onPicked: _viewModel.onFilePicked,
              error: state.attachmentError,
            ),
          ] else
            for (final FileReference file in request.attachments) AttachmentRow(file: file),
          KeyValueCard(items: details),
          const RequestSectionHeader(text: 'Historial'),
          RequestHistoryTimeline(items: timelineOf(request, state.viewerId)),
        ],
      ),
    );
  }
}

/// Bottom bar with the action the viewer can take on the request: resubmit it or cancel it.
class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.state, required this.viewModel});

  final RequestDetailUiState state;
  final RequestDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (state.canResubmit) {
      return FlowboardBottomActionBar(
        children: <Widget>[
          Expanded(
            child: FilledButton.icon(
              onPressed: state.isResubmitting || state.isUploading ? null : viewModel.resubmit,
              icon: state.isResubmitting ? const RequestButtonProgress() : const Icon(Icons.sync, size: 18),
              label: const Text('Reenviar solicitud'),
            ),
          ),
        ],
      );
    }
    return FlowboardBottomActionBar(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: viewModel.showCancelDialog,
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error, side: BorderSide(color: scheme.error)),
            child: const Text('Cancelar solicitud'),
          ),
        ),
      ],
    );
  }
}

/// Card with the type, status, period and approver of the request.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.request});

  final Request request;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s,
        children: <Widget>[
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(child: Text(request.requestTypeName, style: theme.textTheme.titleLarge)),
              RequestStatusChip(status: request.status),
            ],
          ),
          Text(
            RequestFormatters.longPeriodWithAmount(request.period),
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          Text('Aprobador: ${request.approverName}', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}

/// Comment left by the approver when the request was returned or rejected; shows nothing otherwise.
class _ResolutionComment extends StatelessWidget {
  const _ResolutionComment({required this.request});

  final Request request;

  @override
  Widget build(BuildContext context) {
    final RequestHistoryEntry? entry = switch (request.status) {
      RequestStatus.underReview => request.reviewComment,
      RequestStatus.rejected => request.lastChange,
      _ => null,
    };
    final String? comment = entry?.comment;
    if (entry == null || comment == null) return const SizedBox.shrink();
    final String? actorName = entry.actorName;
    final String author = actorName == null ? request.approverName : RequestFormatters.shortName(actorName);
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      tint: RequestColors.commentCard,
      borderColor: RequestColors.commentCard,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s,
        children: <Widget>[
          Text(
            request.status == RequestStatus.rejected ? 'Motivo del rechazo · $author' : 'Comentario de $author',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: RequestColors.onCommentCard,
            ),
          ),
          Text('"$comment"', style: theme.textTheme.bodyMedium?.copyWith(color: RequestColors.onCommentCard)),
        ],
      ),
    );
  }
}
