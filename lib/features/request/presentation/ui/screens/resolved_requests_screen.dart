import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/presentation/state/resolved_requests_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_cards.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/navigation/request_navigation.dart';
import 'package:flowboard/features/request/presentation/viewmodel/resolved_requests_view_model.dart';

/// List of the requests the viewer already approved or rejected as direct manager.
class ResolvedRequestsScreen extends StatefulWidget {
  /// Creates the screen.
  const ResolvedRequestsScreen({super.key});

  @override
  State<ResolvedRequestsScreen> createState() => _ResolvedRequestsScreenState();
}

class _ResolvedRequestsScreenState extends State<ResolvedRequestsScreen> {
  late final ResolvedRequestsViewModel _viewModel = getIt<ResolvedRequestsViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openRequest(int requestId) async {
    await Navigator.of(context).pushNamed(RequestRoutes.reviewRequest, arguments: requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Solicitudes resueltas', onBack: () => Navigator.of(context).maybePop()),
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

  Widget _buildBody(BuildContext context, ResolvedRequestsUiState state) {
    if (state.isLoading && state.requests.isEmpty) {
      return const SkeletonList(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, 0),
      );
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null && state.requests.isEmpty) {
      return RequestMessageState(
        title: 'No se pudieron cargar las solicitudes',
        message: errorMessage,
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
        topPadding: AppSpacing.xl,
      );
    }
    if (state.requests.isEmpty) {
      return const RequestMessageState(
        title: 'Aún no hay solicitudes resueltas',
        message: 'Las solicitudes de tu equipo que apruebes o rechaces aparecerán aquí.',
        topPadding: AppSpacing.xl,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + bottomInset,
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
          child: RequestListRow(request: request, onTap: () => _openRequest(request.id)),
        );
      },
    );
  }
}
