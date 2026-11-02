import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';

const Object _keep = Object();

/// State of the HR dashboard screen.
class HrDashboardUiState {
  /// Creates the state.
  const HrDashboardUiState({
    this.dashboard,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  /// Last loaded dashboard, kept while a refresh is in progress.
  final HrDashboard? dashboard;

  /// True during the first load, when there is nothing to show yet.
  final bool isLoading;

  /// True while a pull-to-refresh or a retry is in progress.
  final bool isRefreshing;

  /// Message shown when no section could be loaded.
  final String? errorMessage;

  /// Copy with the given values replaced.
  HrDashboardUiState copyWith({
    Object? dashboard = _keep,
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _keep,
  }) {
    return HrDashboardUiState(
      dashboard: identical(dashboard, _keep) ? this.dashboard : dashboard as HrDashboard?,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
