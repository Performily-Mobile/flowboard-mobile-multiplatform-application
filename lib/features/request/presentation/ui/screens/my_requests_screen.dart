import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/presentation/state/my_requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/state/requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_cards.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/navigation/request_navigation.dart';
import 'package:flowboard/features/request/presentation/viewmodel/my_requests_view_model.dart';

/// Own requests of an HR staff member, opened from "Más". HR staff are also employees, so they can
/// see their requests, open them and send new ones.
class MyRequestsScreen extends StatefulWidget {
  /// Creates the screen.
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late final MyRequestsViewModel _viewModel = getIt<MyRequestsViewModel>();

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
    final String? message = _viewModel.state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openNewRequest() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(RequestRoutes.newRequest);
    if (mounted && result is String) _viewModel.onResult(result);
  }

  Future<void> _openRequest(int requestId) async {
    final Object? result = await Navigator.of(context).pushNamed(RequestRoutes.requestDetail, arguments: requestId);
    if (mounted && result is String) _viewModel.onResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRequest,
        tooltip: 'Nueva solicitud',
        icon: const Icon(FlowboardIcons.add),
        label: const Text('Nueva solicitud'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final MyRequestsUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Mis solicitudes', onBack: () => Navigator.of(context).maybePop()),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 8),
                child: Row(
                  spacing: AppSpacing.s,
                  children: <Widget>[
                    for (final MyRequestsFilter filter in MyRequestsFilter.values)
                      FilterChip(
                        label: Text(filter.label),
                        selected: state.filter == filter,
                        onSelected: (bool _) => _viewModel.onFilterSelected(filter),
                      ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyRequestsUiState state) {
    if (state.isLoading && state.requests.isEmpty) {
      return const SkeletonList(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 0),
      );
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.requests.isEmpty) {
      return RequestMessageState(
        title: 'No se pudieron cargar tus solicitudes',
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
        topPadding: AppSpacing.l,
      );
    }
    if (state.requests.isEmpty) {
      final bool all = state.filter == MyRequestsFilter.all;
      return RequestMessageState(
        title: all ? 'Aún no tienes solicitudes' : 'No hay solicitudes con este estado',
        message: all
            ? 'Pide vacaciones, permisos o licencias con el botón "Nueva solicitud".'
            : 'Prueba con otro filtro.',
        topPadding: AppSpacing.l,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        4,
        AppSpacing.screenHorizontal,
        AppSpacing.fabClearance + bottomInset,
      ),
      itemCount: state.requests.length + (state.paging.hasMore ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == state.requests.length) {
          return RequestLoadMoreItem(
            itemCount: state.requests.length,
            failed: state.paging.loadMoreFailed,
            onLoadMore: _viewModel.loadMore,
          );
        }
        final Request request = state.requests[index];
        return Padding(
          key: ValueKey<int>(request.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          child: MyRequestCard(request: request, onTap: () => _openRequest(request.id)),
        );
      },
    );
  }
}
