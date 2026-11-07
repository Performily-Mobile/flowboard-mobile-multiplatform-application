import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';

const Object _keep = Object();

/// State of the vacation balance of the employee (MA-57).
class MyVacationBalanceUiState {
  /// Creates the state.
  const MyVacationBalanceUiState({this.isLoading = false, this.synced, this.errorMessage});

  final bool isLoading;
  final SyncedVacationBalance? synced;
  final String? errorMessage;

  /// True when saved data is shown because there was no connection.
  bool get isOffline => synced?.fromCache ?? false;

  /// Copy with the given values replaced.
  MyVacationBalanceUiState copyWith({bool? isLoading, Object? synced = _keep, Object? errorMessage = _keep}) {
    return MyVacationBalanceUiState(
      isLoading: isLoading ?? this.isLoading,
      synced: identical(synced, _keep) ? this.synced : synced as SyncedVacationBalance?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
    );
  }
}
