import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_search_field.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/presentation/state/vacation_balances_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_colors.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/ui/navigation/benefits_routes.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/vacation_balances_view_model.dart';

/// Vacation balances of the active employees; tapping one opens its detail (MA-63).
class VacationBalancesScreen extends StatefulWidget {
  /// Creates the screen.
  const VacationBalancesScreen({super.key});

  @override
  State<VacationBalancesScreen> createState() => _VacationBalancesScreenState();
}

class _VacationBalancesScreenState extends State<VacationBalancesScreen> {
  late final VacationBalancesViewModel _viewModel = getIt<VacationBalancesViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openBalance(int employeeId, String employeeName) async {
    await Navigator.of(context).pushNamed(
      BenefitsRoutes.vacationBalanceDetail,
      arguments: VacationBalanceDetailArgs(employeeId: employeeId, employeeName: employeeName),
    );
    if (mounted) _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final VacationBalancesUiState state = _viewModel.state;
        final String? error = state.errorMessage;
        final Widget content;
        if (state.isLoading) {
          content = const SkeletonList();
        } else if (error != null && state.balances.isEmpty) {
          content = BenefitsMessageState(
            title: 'No se pudieron cargar los saldos',
            message: error,
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          );
        } else {
          content = _BalancesList(state: state, onRetry: _viewModel.load, onBalanceTap: _openBalance);
        }
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Saldos de vacaciones',
                onBack: navigator.canPop() ? () => navigator.maybePop() : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                child: FlowboardSearchField(
                  query: state.query,
                  onQueryChange: _viewModel.onQueryChange,
                  placeholder: 'Buscar por nombre o área',
                ),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _BalancesList extends StatelessWidget {
  const _BalancesList({required this.state, required this.onRetry, required this.onBalanceTap});

  final VacationBalancesUiState state;
  final VoidCallback onRetry;
  final void Function(int employeeId, String employeeName) onBalanceTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? error = state.errorMessage;
    final List<VacationBalance> balances = state.filtered;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: BenefitsBanner(
              message: error,
              icon: FlowboardIcons.warning,
              containerColor: BenefitsColors.warningBanner,
              contentColor: BenefitsColors.onWarningBanner,
              actionLabel: 'Reintentar',
              onAction: onRetry,
            ),
          ),
        if (balances.isEmpty)
          BenefitsMessageState(
            title: 'Sin resultados',
            message: state.balances.isEmpty ? 'Aún no hay saldos de vacaciones.' : 'Prueba con otro nombre.',
            topPadding: 24,
          ),
        for (final VacationBalance balance in balances)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
            child: Builder(builder: (BuildContext context) {
              final String name = balance.employeeName ?? 'Colaborador #${balance.employeeId}';
              return BenefitListItem(
                leading: InitialsAvatar(name: name),
                title: name,
                subtitle: <String?>[
                  balance.areaName,
                  'Usados ${BenefitsFormatters.number(balance.usedDays)} de ${BenefitsFormatters.number(balance.accruedDays)}',
                ].whereType<String>().join(' · '),
                onTap: () => onBalanceTap(balance.employeeId, name),
                trailing: Text(
                  '${BenefitsFormatters.number(balance.availableDays)} d',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
