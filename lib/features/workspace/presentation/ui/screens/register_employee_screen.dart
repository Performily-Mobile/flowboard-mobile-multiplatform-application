import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/presentation/state/register_employee_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/contract_assignment_step.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/personal_data_step.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/register_employee_view_model.dart';

/// Two-step form to register a new employee: personal data, then contract and assignment.
///
/// It closes with the id of the new employee once it is registered; the system back gesture on
/// the second step returns to the first one.
class RegisterEmployeeScreen extends StatefulWidget {
  /// Creates the screen.
  const RegisterEmployeeScreen({super.key});

  @override
  State<RegisterEmployeeScreen> createState() => _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
  late final RegisterEmployeeViewModel _viewModel = getIt<RegisterEmployeeViewModel>();
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final int? employeeId = _viewModel.state.registeredEmployeeId;
    if (!mounted || _closed || employeeId == null) return;
    _closed = true;
    Navigator.of(context).pop(employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final RegisterEmployeeUiState state = _viewModel.state;
        final ThemeData theme = Theme.of(context);
        final bool firstStep = state.step == 1;
        return PopScope(
          canPop: firstStep,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) _viewModel.onBack();
          },
          child: Scaffold(
            bottomNavigationBar: FlowboardBottomActionBar(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s),
                          child: Text(
                            state.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          ),
                        ),
                      FilledButton(
                        onPressed: state.isSubmitting ? null : (firstStep ? _viewModel.onContinue : _viewModel.onSubmit),
                        child: state.isSubmitting
                            ? const ButtonProgress()
                            : Text(firstStep ? 'Continuar' : 'Registrar colaborador'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                FlowboardTopBar(
                  title: 'Nuevo colaborador',
                  onClose: firstStep ? () => Navigator.of(context).maybePop() : null,
                  onBack: firstStep ? null : _viewModel.onBack,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      8,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        _StepIndicator(step: state.step),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: firstStep
                              ? PersonalDataStep(
                                  key: const ValueKey<int>(1),
                                  state: state,
                                  onFirstNameChange: _viewModel.onFirstNameChange,
                                  onLastNameChange: _viewModel.onLastNameChange,
                                  onDocumentTypeChange: _viewModel.onDocumentTypeChange,
                                  onDocumentNumberChange: _viewModel.onDocumentNumberChange,
                                  onBirthDateChange: _viewModel.onBirthDateChange,
                                  onEmailChange: _viewModel.onEmailChange,
                                  onPhoneChange: _viewModel.onPhoneChange,
                                )
                              : ContractAssignmentStep(
                                  key: const ValueKey<int>(2),
                                  state: state,
                                  onContractTypeChange: _viewModel.onContractTypeChange,
                                  onHireDateChange: _viewModel.onHireDateChange,
                                  onContractEndDateChange: _viewModel.onContractEndDateChange,
                                  onAreaChange: _viewModel.onAreaChange,
                                  onPositionChange: _viewModel.onPositionChange,
                                  onDirectManagerChange: _viewModel.onDirectManagerChange,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Caption and two-segment progress bar of the registration steps.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s,
        children: <Widget>[
          Text(
            step == 1 ? 'Paso 1 de 2 · Datos personales' : 'Paso 2 de 2 · Contrato y asignación',
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
          ),
          Row(
            spacing: 4,
            children: <Widget>[
              for (final int index in const <int>[1, 2])
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= step ? scheme.primary : scheme.surfaceContainer,
                      borderRadius: AppShapes.pill,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
