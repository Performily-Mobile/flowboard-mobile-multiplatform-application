import 'package:flowboard/core/viewmodel/view_model.dart';
import 'package:flowboard/features/benefits/application/usecase/get_my_benefits_use_case.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/presentation/state/my_benefits_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_error_messages.dart';

/// View model of the current and delivered benefits of the employee (MA-58, MA-59, US40).
class MyBenefitsViewModel extends ViewModel<MyBenefitsUiState> {
  /// Creates the view model and loads the benefits.
  MyBenefitsViewModel({required this.getMyBenefits}) : super(const MyBenefitsUiState()) {
    load();
  }

  final GetMyBenefitsUseCase getMyBenefits;

  /// Loads the benefits; a reload keeps the data on screen.
  Future<void> load() async {
    update((MyBenefitsUiState s) => s.copyWith(isLoading: s.benefits == null, errorMessage: null));
    try {
      final EmployeeBenefits benefits = await getMyBenefits.execute();
      update((MyBenefitsUiState s) => s.copyWith(isLoading: false, benefits: benefits));
    } catch (error) {
      update((MyBenefitsUiState s) => s.copyWith(
            isLoading: false,
            errorMessage: benefitsMessage(error, BenefitsAction.load, 'No se pudieron cargar tus beneficios.'),
          ));
    }
  }

  /// Selects the tab [index] (0 current, 1 delivered).
  void onTabSelected(int index) => update((MyBenefitsUiState s) => s.copyWith(selectedTab: index));
}
