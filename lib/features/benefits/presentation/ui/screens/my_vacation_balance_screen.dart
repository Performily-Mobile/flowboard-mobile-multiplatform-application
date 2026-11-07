import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/core/navigation/tab_switcher.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/presentation/state/my_vacation_balance_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_colors.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_icons.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/vacation_movement_row.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/my_vacation_balance_view_model.dart';

/// Vacation balance of the employee (MA-57).
///
/// Without connection it shows the saved data with "Sin conexión. Mostrando datos sincronizados el …".
/// "Solicitar vacaciones" opens the requests tab, owned by the Request bounded context.
class MyVacationBalanceScreen extends StatefulWidget {
  /// Creates the screen.
  const MyVacationBalanceScreen({super.key});

  @override
  State<MyVacationBalanceScreen> createState() => _MyVacationBalanceScreenState();
}

class _MyVacationBalanceScreenState extends State<MyVacationBalanceScreen> {
  late final MyVacationBalanceViewModel _viewModel = getIt<MyVacationBalanceViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _requestVacation() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    getIt<TabSwitcher>().switchTo(AppRoutes.requests);
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final MyVacationBalanceUiState state = _viewModel.state;
        final SyncedVacationBalance? synced = state.synced;
        final Widget content;
        if (state.isLoading) {
          content = const SkeletonList(showAvatar: false);
        } else if (synced == null) {
          content = BenefitsMessageState(
            title: 'No se pudo cargar tu saldo',
            message: state.errorMessage ?? 'Inténtalo nuevamente.',
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          );
        } else {
          content = _BalanceContent(
            synced: synced,
            errorMessage: state.errorMessage,
            onRetry: _viewModel.load,
            onRequestVacation: _requestVacation,
          );
        }
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Saldo de vacaciones',
                onBack: navigator.canPop() ? () => navigator.maybePop() : null,
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceContent extends StatelessWidget {
  const _BalanceContent({
    required this.synced,
    required this.errorMessage,
    required this.onRetry,
    required this.onRequestVacation,
  });

  final SyncedVacationBalance synced;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onRequestVacation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VacationBalance balance = synced.balance;
    final String? error = errorMessage;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        4,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        if (synced.fromCache)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: BenefitsBanner(
              message: 'Sin conexión. Mostrando datos sincronizados ${BenefitsFormatters.syncedAt(synced.syncedAt)}.',
              icon: BenefitsIcons.wifiOff,
              containerColor: BenefitsColors.offlineBanner,
              contentColor: BenefitsColors.onOfflineBanner,
              actionLabel: 'Reintentar',
              onAction: onRetry,
            ),
          ),
        if (error != null && !synced.fromCache)
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
        _BalanceCard(balance: balance, onRequestVacation: onRequestVacation),
        const SizedBox(height: AppSpacing.m),
        const BenefitsSectionHeader(text: 'Movimientos'),
        if (balance.movements.isEmpty)
          Text(
            'Todavía no hay movimientos en tu saldo.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        for (final VacationMovement movement in balance.movements)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: VacationMovementRow(movement: movement),
          ),
      ],
    );
  }
}

/// Main card: available days, a bar with the used share and the button to request vacations.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.onRequestVacation});

  final VacationBalance balance;
  final VoidCallback onRequestVacation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? caption = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6,
            children: <Widget>[
              Text(
                BenefitsFormatters.number(balance.availableDays),
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: scheme.primary, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'días disponibles',
                  style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: AppShapes.pill,
            child: LinearProgressIndicator(
              value: balance.usedRatio,
              minHeight: 6,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainer,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Acumulados ${BenefitsFormatters.number(balance.accruedDays)}', style: caption),
              Text('Usados ${BenefitsFormatters.number(balance.usedDays)}', style: caption),
            ],
          ),
          FilledButton.icon(
            onPressed: onRequestVacation,
            icon: const Icon(FlowboardIcons.add, size: 18),
            label: const Text('Solicitar vacaciones'),
          ),
        ],
      ),
    );
  }
}
