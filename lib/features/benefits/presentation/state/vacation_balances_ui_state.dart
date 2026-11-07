import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';

const Object _keep = Object();

/// State of the list of vacation balances for HR, with a search by name or area.
class VacationBalancesUiState {
  /// Creates the state.
  const VacationBalancesUiState({
    this.isLoading = false,
    this.balances = const <VacationBalance>[],
    this.errorMessage,
    this.query = '',
  });

  final bool isLoading;
  final List<VacationBalance> balances;
  final String? errorMessage;
  final String query;

  /// Balances whose employee name or area contains the query.
  List<VacationBalance> get filtered {
    final String text = query.trim().toLowerCase();
    if (text.isEmpty) return balances;
    return balances
        .where((VacationBalance balance) =>
            (balance.employeeName ?? '').toLowerCase().contains(text) ||
            (balance.areaName ?? '').toLowerCase().contains(text))
        .toList();
  }

  /// Copy with the given values replaced.
  VacationBalancesUiState copyWith({
    bool? isLoading,
    List<VacationBalance>? balances,
    Object? errorMessage = _keep,
    String? query,
  }) {
    return VacationBalancesUiState(
      isLoading: isLoading ?? this.isLoading,
      balances: balances ?? this.balances,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      query: query ?? this.query,
    );
  }
}
