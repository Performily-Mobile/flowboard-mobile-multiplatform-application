import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/dashboard/application/usecase/get_hr_dashboard_use_case.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/presentation/state/hr_dashboard_ui_state.dart';

/// Holds the state of the HR dashboard and reloads it on demand.
class HrDashboardViewModel extends ViewModel<HrDashboardUiState> {
  /// Creates the view model.
  HrDashboardViewModel({required this.getHrDashboard}) : super(const HrDashboardUiState());

  final GetHrDashboardUseCase getHrDashboard;

  static const String _noDataMessage = 'No se pudo cargar el panel. Revisa tu conexión e inténtalo de nuevo.';

  bool _loading = false;

  /// Loads the dashboard when the tab is entered.
  ///
  /// The first time it shows the loading skeleton; afterwards it updates without blocking the screen.
  Future<void> load() => _fetch(isRefresh: false);

  /// Reloads the dashboard after a pull-to-refresh or a retry.
  Future<void> refresh() => _fetch(isRefresh: true);

  /// Fetches the dashboard unless a request is already running.
  Future<void> _fetch({required bool isRefresh}) async {
    if (_loading) return;
    _loading = true;
    update((HrDashboardUiState s) => s.copyWith(
          isLoading: !isRefresh && s.dashboard == null,
          isRefreshing: isRefresh,
          errorMessage: null,
        ));
    final HrDashboard dashboard = await getHrDashboard.execute();
    _loading = false;
    update((HrDashboardUiState s) => s.copyWith(
          dashboard: dashboard,
          isLoading: false,
          isRefreshing: false,
          errorMessage: dashboard.hasNoData ? _noDataMessage : null,
        ));
  }
}
