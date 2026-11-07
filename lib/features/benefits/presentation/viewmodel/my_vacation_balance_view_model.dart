import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/get_my_vacation_balance_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/presentation/state/my_vacation_balance_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the vacation balance of the employee (MA-57, US41).
///
/// Without connection it shows the last saved copy with the time it was synced.
class MyVacationBalanceViewModel extends ViewModel<MyVacationBalanceUiState> {
  /// Creates the view model and loads the balance.
  MyVacationBalanceViewModel({required this.getMyVacationBalance}) : super(const MyVacationBalanceUiState()) {
    load();
  }

  final GetMyVacationBalanceUseCase getMyVacationBalance;

  /// Loads the balance; a reload keeps the data on screen.
  Future<void> load() async {
    update((MyVacationBalanceUiState s) => s.copyWith(isLoading: s.synced == null, errorMessage: null));
    try {
      final SyncedVacationBalance synced = await getMyVacationBalance.execute();
      update((MyVacationBalanceUiState s) => s.copyWith(isLoading: false, synced: synced));
    } catch (error) {
      update((MyVacationBalanceUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: benefitsMessage(error, BenefitsAction.load, 'No se pudo cargar tu saldo de vacaciones.'),
          ));
    }
  }
}
