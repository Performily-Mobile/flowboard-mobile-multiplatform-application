import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/presentation/state/review_request_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_attachments.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_dialogs.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_history_timeline.dart';
import 'package:flowboard/features/request/presentation/viewmodel/review_request_view_model.dart';

/// Detail of a request for its approver, with the return, reject and approve actions in a bottom
/// bar. Once resolved, it shows the history instead.
///
/// It closes with a message once the request is resolved.
class ReviewRequestScreen extends StatefulWidget {
  /// Creates the screen for [requestId].
  const ReviewRequestScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<ReviewRequestScreen> createState() => _ReviewRequestScreenState();
}

class _ReviewRequestScreenState extends State<ReviewRequestScreen> {
  late final ReviewRequestViewModel _viewModel = getIt<ReviewRequestViewModel>();
  late final ModalSync<ReviewAction> _modal =
      ModalSync<ReviewAction>(open: _openAction, onDismissed: _viewModel.dismissAction);
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
    final ReviewRequestUiState state = _viewModel.state;
    final String? result = state.resultMessage;
    if (result != null) {
      _closed = true;
      _modal.sync(context, null);
      Navigator.of(context).pop(result);
      return;
    }
    _modal.sync(context, state.activeAction == ReviewAction.none ? null : state.activeAction);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Widget _watch(Widget Function(ReviewRequestUiState state, Request request) builder) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final ReviewRequestUiState state = _viewModel.state;
        final Request? request = state.request;
        if (request == null) return const SizedBox.shrink();
        return builder(state, request);
      },
    );
  }

  Future<void> _openAction(BuildContext context, ReviewAction action) async {
    switch (action) {
      case ReviewAction.reject:
        await showGlassDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => _watch((ReviewRequestUiState state, Request request) {
            return RejectRequestDialog(
              requesterName: RequestFormatters.shortName(request.requesterName),
              reason: state.rejectReason,
              error: state.rejectError,
              isSaving: state.isProcessing,
              onReasonChange: _viewModel.onRejectReasonChange,
              onConfirm: _viewModel.confirmReject,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case ReviewAction.returnForReview:
        await showGlassBottomSheet<void>(
          context: context,
          builder: (BuildContext sheetContext) => _watch((ReviewRequestUiState state, Request request) {
            return ReturnForReviewSheet(
              requesterFirstName: RequestFormatters.firstName(request.requesterName),
              comment: state.returnComment,
              error: state.returnError,
              isSaving: state.isProcessing,
              onCommentChange: _viewModel.onReturnCommentChange,
              onConfirm: _viewModel.confirmReturn,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case ReviewAction.none:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final ReviewRequestUiState state = _viewModel.state;
        final Request? request = state.request;
        final bool showActions = !state.isLoading && request != null && state.canResolve;
        return Scaffold(
          bottomNavigationBar: showActions ? _ReviewActions(state: state, viewModel: _viewModel) : null,
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: request == null || state.canResolve
                    ? 'Revisar solicitud'
                    : 'Solicitud ${RequestFormatters.code(widget.requestId)}',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(child: _buildBody(state, request)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ReviewRequestUiState state, Request? request) {
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
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          _RequesterCard(request: request),
          KeyValueCard(items: _detailItems(state, request)),
          for (final FileReference file in request.attachments) AttachmentRow(file: file),
          Text(
            'Enviada el ${RequestFormatters.dateTime(request.submittedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (!state.canResolve) ...<Widget>[
            const RequestSectionHeader(text: 'Historial'),
            RequestHistoryTimeline(items: timelineOf(request, state.viewerId)),
          ],
        ],
      ),
    );
  }

  List<KeyValue> _detailItems(ReviewRequestUiState state, Request request) {
    final VacationAvailability? availability = state.availability;
    return <KeyValue>[
      KeyValue('Tipo', request.requestTypeName),
      KeyValue('Periodo', RequestFormatters.longPeriod(request.period)),
      KeyValue(request.period?.hasHours == true ? 'Horas' : 'Días', RequestFormatters.amount(request.period)),
      if (availability != null)
        KeyValue(
          'Saldo del colaborador',
          '${RequestFormatters.balanceDays(availability.availableDays)} → '
              '${RequestFormatters.number(availability.afterUsing(request.requestedDays))} tras aprobar',
        ),
      for (final RequestFieldValue value in request.fieldValues)
        KeyValue(
          state.type?.fieldLabel(value.key) ?? value.key,
          RequestFormatters.fieldValue(state.type?.fieldOf(value.key), value.value),
        ),
      KeyValue('Aprobador', request.approverName),
    ];
  }
}

/// Bottom bar with the decisions an approver can take.
class _ReviewActions extends StatelessWidget {
  const _ReviewActions({required this.state, required this.viewModel});

  final ReviewRequestUiState state;
  final ReviewRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool busy = state.isProcessing;
    return FlowboardBottomActionBar(
      children: <Widget>[
        TextButton(onPressed: busy ? null : viewModel.showReturnSheet, child: const Text('Devolver')),
        Expanded(
          child: OutlinedButton(onPressed: busy ? null : viewModel.showRejectDialog, child: const Text('Rechazar')),
        ),
        Expanded(
          child: FilledButton(
            onPressed: busy ? null : viewModel.approve,
            child: busy && state.activeAction == ReviewAction.none
                ? const RequestButtonProgress()
                : const Text('Aprobar'),
          ),
        ),
      ],
    );
  }
}

/// Card with the avatar, name and job of the requester, and the status of the request.
class _RequesterCard extends StatelessWidget {
  const _RequesterCard({required this.request});

  final Request request;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? job = request.requester?.jobDescription;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          RequestAvatar(name: request.requesterName, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  RequestFormatters.shortName(request.requesterName),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (job != null)
                  Text(job, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          RequestStatusChip(status: request.status),
        ],
      ),
    );
  }
}
