import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/state/paging_state.dart';
import 'package:flowboard/features/request/presentation/state/requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_cards.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_dialogs.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/ui/navigation/request_navigation.dart';
import 'package:flowboard/features/request/presentation/viewmodel/requests_view_model.dart';

/// Requests tab with the viewer's own requests, the requests to approve, the HR inbox and all the
/// requests. The tabs and the filters live in a header that slides away while the list scrolls.
class RequestsScreen extends StatefulWidget {
  /// Creates the screen.
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late final RequestsViewModel _viewModel = getIt<RequestsViewModel>();
  late final ModalSync<int> _rejectDialog =
      ModalSync<int>(open: _openRejectDialog, onDismissed: _viewModel.dismissRejectDialog);
  bool _fabExpanded = true;

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
    final RequestsUiState state = _viewModel.state;
    _rejectDialog.sync(context, state.rejectForm?.request.id);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openNewRequest() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(RequestRoutes.newRequest);
    if (mounted && result is String) _viewModel.onResult(result);
  }

  Future<void> _openRequest(String route, int requestId) async {
    final Object? result = await Navigator.of(context).pushNamed(route, arguments: requestId);
    if (mounted && result is String) _viewModel.onResult(result);
  }

  Future<void> _openResolved() async {
    await Navigator.of(context).pushNamed(RequestRoutes.resolvedRequests);
  }

  Future<void> _openRejectDialog(BuildContext context, int requestId) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final RejectForm? form = _viewModel.state.rejectForm;
          if (form == null) return const SizedBox.shrink();
          return RejectRequestDialog(
            requesterName: RequestFormatters.shortName(form.request.requesterName),
            reason: form.reason,
            error: form.error,
            isSaving: form.isSaving,
            onReasonChange: _viewModel.onRejectReasonChange,
            onConfirm: _viewModel.confirmReject,
            onDismiss: _viewModel.dismissRejectDialog,
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
        final RequestsUiState state = _viewModel.state;
        return Scaffold(
          floatingActionButton: state.selectedTab == RequestsTab.mine
              ? FloatingActionButton.extended(
                  onPressed: _openNewRequest,
                  isExtended: _fabExpanded,
                  tooltip: 'Nueva solicitud',
                  icon: const Icon(FlowboardIcons.add),
                  label: const Text('Nueva solicitud'),
                )
              : null,
          body: Column(
            children: <Widget>[
              const FlowboardTopBar(title: 'Solicitudes'),
              Expanded(
                child: CollapsingHeaderLayout(
                  showHeaderKey: Object.hash(
                    state.selectedTab,
                    state.myRequests.length,
                    state.pending.length,
                    state.allRequests.length,
                    state.isLoadingMine || state.isLoadingPending || state.isLoadingAll,
                    state.mineError != null || state.pendingError != null || state.allError != null,
                  ),
                  onHeaderVisibilityChanged: (bool visible) => setState(() => _fabExpanded = visible),
                  header: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                          child: FlowboardTabs<RequestsTab>(
                            options: state.tabs,
                            selected: state.selectedTab,
                            onSelect: _viewModel.onTabSelected,
                            labelOf: state.tabLabel,
                          ),
                        ),
                        if (state.selectedTab != RequestsTab.hrInbox) _TabFilters(state: state, viewModel: _viewModel),
                      ],
                    ),
                  ),
                  contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
                      _buildContent(context, state, contentPadding.top),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, RequestsUiState state, double headerHeight) {
    switch (state.selectedTab) {
      case RequestsTab.mine:
        return _RequestListView(
          headerHeight: headerHeight,
          isLoading: state.isLoadingMine,
          error: state.mineError,
          errorTitle: 'No se pudieron cargar tus solicitudes',
          emptyTitle: state.myFilter == MyRequestsFilter.all
              ? 'Aún no tienes solicitudes'
              : 'No hay solicitudes con este estado',
          emptyMessage: state.myFilter == MyRequestsFilter.all
              ? 'Pide vacaciones, permisos o licencias con el botón "Nueva solicitud".'
              : 'Prueba con otro filtro.',
          requests: state.myRequests,
          paging: state.minePaging,
          bottomSpace: AppSpacing.fabClearance,
          onRetry: _viewModel.load,
          onLoadMore: _viewModel.loadMoreMine,
          itemBuilder: (Request request) =>
              MyRequestCard(request: request, onTap: () => _openRequest(RequestRoutes.requestDetail, request.id)),
        );
      case RequestsTab.toApprove:
      case RequestsTab.hrInbox:
        final bool isHrInbox = state.selectedTab == RequestsTab.hrInbox;
        return _RequestListView(
          headerHeight: headerHeight,
          isLoading: state.isLoadingPending,
          error: state.pendingError,
          errorTitle: 'No se pudo cargar la bandeja',
          emptyTitle: 'No tienes solicitudes por atender',
          emptyMessage: isHrInbox
              ? 'Cuando un colaborador sin jefe directo envíe una solicitud, aparecerá aquí.'
              : 'Todo lo que llegó está resuelto. Cuando alguien de tu equipo envíe una solicitud, aparecerá aquí '
                  'y recibirás una notificación.',
          emptyIcon: FlowboardIcons.check,
          emptyActionLabel: isHrInbox ? null : 'Ver solicitudes resueltas',
          onEmptyAction: _openResolved,
          requests: state.pending,
          paging: state.pendingPaging,
          bottomSpace: AppSpacing.xl,
          onRetry: _viewModel.load,
          onLoadMore: _viewModel.loadMorePending,
          itemBuilder: (Request request) => ApprovalCard(
            request: request,
            isProcessing: state.processingRequestId == request.id,
            canResolve: state.canResolve(request),
            onTap: () => _openRequest(RequestRoutes.reviewRequest, request.id),
            onReject: () => _viewModel.showRejectDialog(request),
            onApprove: () => _viewModel.approve(request),
          ),
        );
      case RequestsTab.all:
        return _RequestListView(
          headerHeight: headerHeight,
          isLoading: state.isLoadingAll,
          error: state.allError,
          errorTitle: 'No se pudieron cargar las solicitudes',
          emptyTitle: 'No hay solicitudes con este estado',
          emptyMessage: 'Prueba con otro filtro.',
          requests: state.allRequests,
          paging: state.allPaging,
          bottomSpace: AppSpacing.xl,
          onRetry: _viewModel.load,
          onLoadMore: _viewModel.loadMoreAll,
          itemBuilder: (Request request) =>
              RequestListRow(request: request, onTap: () => _openRequest(RequestRoutes.reviewRequest, request.id)),
        );
    }
  }
}

/// Filters of the selected tab, below the tabs.
class _TabFilters extends StatelessWidget {
  const _TabFilters({required this.state, required this.viewModel});

  final RequestsUiState state;
  final RequestsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    switch (state.selectedTab) {
      case RequestsTab.mine:
        return _ChipRow(
          children: <Widget>[
            for (final MyRequestsFilter filter in MyRequestsFilter.values)
              FilterChip(
                label: Text(filter.label),
                selected: state.myFilter == filter,
                onSelected: (bool _) => viewModel.onMyFilterSelected(filter),
              ),
          ],
        );
      case RequestsTab.toApprove:
        return _ChipRow(
          children: <Widget>[
            _MenuChip<RequestType?>(
              label: 'Tipo: ${state.typeFilter?.name ?? 'todos'}',
              selected: state.typeFilter != null,
              options: <RequestType?>[null, ...state.requestTypes],
              optionLabel: (RequestType? type) => type?.name ?? 'Todos',
              onSelect: viewModel.onTypeFilterSelected,
            ),
            _MenuChip<ApprovalSort>(
              label: state.sort.label,
              selected: state.pending.isNotEmpty,
              options: ApprovalSort.values,
              optionLabel: (ApprovalSort sort) => sort.label,
              onSelect: viewModel.onSortSelected,
            ),
          ],
        );
      case RequestsTab.hrInbox:
        return const SizedBox.shrink();
      case RequestsTab.all:
        return _ChipRow(
          children: <Widget>[
            for (final AllRequestsFilter filter in AllRequestsFilter.values)
              FilterChip(
                label: Text(filter.label),
                selected: state.allFilter == filter,
                onSelected: (bool _) => viewModel.onAllFilterSelected(filter),
              ),
          ],
        );
    }
  }
}

/// Single row of filter chips that scrolls sideways when the chips do not fit.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(spacing: AppSpacing.s, children: children),
    );
  }
}

/// Filter chip that opens a menu to pick one of [options].
class _MenuChip<T> extends StatelessWidget {
  const _MenuChip({
    required this.label,
    required this.selected,
    required this.options,
    required this.optionLabel,
    required this.onSelect,
  });

  final String label;
  final bool selected;
  final List<T> options;
  final String Function(T option) optionLabel;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        for (final T option in options)
          MenuItemButton(onPressed: () => onSelect(option), child: Text(optionLabel(option))),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        void toggle() => controller.isOpen ? controller.close() : controller.open();
        return FilterChip(
          selected: selected,
          label: Text(label),
          onSelected: (bool _) => toggle(),
          deleteIcon: const Icon(FlowboardIcons.arrowDropDown, size: 18),
          deleteButtonTooltipMessage: label,
          onDeleted: toggle,
        );
      },
    );
  }
}

/// List of requests below the collapsing header, with its loading, error and empty states and the
/// item that loads the next page.
class _RequestListView extends StatelessWidget {
  const _RequestListView({
    required this.headerHeight,
    required this.isLoading,
    required this.error,
    required this.errorTitle,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.requests,
    required this.paging,
    required this.bottomSpace,
    required this.onRetry,
    required this.onLoadMore,
    required this.itemBuilder,
    this.emptyIcon,
    this.emptyActionLabel,
    this.onEmptyAction,
  });

  final double headerHeight;
  final bool isLoading;
  final String? error;
  final String errorTitle;
  final String emptyTitle;
  final String emptyMessage;
  final IconData? emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final List<Request> requests;
  final PagingState paging;
  final double bottomSpace;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final Widget Function(Request request) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (isLoading && requests.isEmpty) {
      return SkeletonList(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, headerHeight + 8, AppSpacing.screenHorizontal, 0),
      );
    }
    final String? errorMessage = error;
    if (errorMessage != null && requests.isEmpty) {
      return RequestMessageState(
        title: errorTitle,
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: onRetry,
        topPadding: headerHeight + 24,
      );
    }
    if (requests.isEmpty) {
      return RequestMessageState(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
        topPadding: headerHeight + 24,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        headerHeight + 8,
        AppSpacing.screenHorizontal,
        bottomSpace + bottomInset,
      ),
      itemCount: requests.length + (paging.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == requests.length) {
          return RequestLoadMoreItem(itemCount: requests.length, failed: paging.loadMoreFailed, onLoadMore: onLoadMore);
        }
        final Request request = requests[index];
        return Padding(
          key: ValueKey<int>(request.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          child: itemBuilder(request),
        );
      },
    );
  }
}
