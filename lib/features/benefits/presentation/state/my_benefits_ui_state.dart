import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';

const Object _keep = Object();

/// State of "Mis beneficios" (MA-58, MA-59). Tab 0: current; 1: delivered.
class MyBenefitsUiState {
  /// Creates the state.
  const MyBenefitsUiState({this.isLoading = false, this.benefits, this.errorMessage, this.selectedTab = 0});

  final bool isLoading;
  final EmployeeBenefits? benefits;
  final String? errorMessage;
  final int selectedTab;

  /// Number of current benefits, shown in the tab.
  int get currentCount => benefits?.current.length ?? 0;

  /// Number of delivered benefits, shown in the tab.
  int get deliveredCount => benefits?.delivered.length ?? 0;

  /// Copy with the given values replaced.
  MyBenefitsUiState copyWith({bool? isLoading, Object? benefits = _keep, Object? errorMessage = _keep, int? selectedTab}) {
    return MyBenefitsUiState(
      isLoading: isLoading ?? this.isLoading,
      benefits: identical(benefits, _keep) ? this.benefits : benefits as EmployeeBenefits?,
      errorMessage: identical(errorMessage, _keep) ? this.errorMessage : errorMessage as String?,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
