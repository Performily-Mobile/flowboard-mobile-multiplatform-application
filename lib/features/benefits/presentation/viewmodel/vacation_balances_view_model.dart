import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/get_vacation_balances_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/presentation/state/vacation_balances_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the vacation balances of the active employees, to pick whom to adjust (MA-63).
class VacationBalancesViewModel extends ViewModel<VacationBalancesUiState> {
  /// Creates the view model and loads the balances.
  VacationBalancesViewModel({required this.getVacationBalances}) : super(const VacationBalancesUiState()) {
    load();
  }

  final GetVacationBalancesUseCase getVacationBalances;

  /// Loads the balances; a reload keeps the data on screen.
  Future<void> load() async {
    update((VacationBalancesUiState s) => s.copyWith(isLoading: s.balances.isEmpty, errorMessage: null));
    try {
      final List<VacationBalance> balances = await getVacationBalances.execute();
      update((VacationBalancesUiState s) => s.copyWith(isLoading: false, balances: balances));
    } catch (error) {
      update((VacationBalancesUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: benefitsMessage(error, BenefitsAction.load, 'No se pudieron cargar los saldos.'),
          ));
    }
  }

  /// Changes the search text.
  void onQueryChange(String value) => update((VacationBalancesUiState s) => s.copyWith(query: value));
}
