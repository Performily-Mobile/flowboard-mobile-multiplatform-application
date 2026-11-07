import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/benefits/domain/entity/vacation_balance.dart';
import 'package:flowboard/features/benefits/presentation/state/vacation_balance_detail_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_dialogs.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_icons.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/vacation_movement_row.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/vacation_balance_detail_view_model.dart';

/// Sheet open on the balance detail.
enum _DetailSheet { adjust }

/// Vacation balance of one employee, with the manual adjustment of HR (MA-63).
class VacationBalanceDetailScreen extends StatefulWidget {
  /// Creates the screen; [employeeName] is shown while the balance loads.
  const VacationBalanceDetailScreen({super.key, required this.employeeId, required this.employeeName});

  final int employeeId;
  final String employeeName;

  @override
  State<VacationBalanceDetailScreen> createState() => _VacationBalanceDetailScreenState();
}

class _VacationBalanceDetailScreenState extends State<VacationBalanceDetailScreen> {
  late final VacationBalanceDetailViewModel _viewModel = getIt<VacationBalanceDetailViewModel>();
  late final ModalSync<_DetailSheet> _sheet =
      ModalSync<_DetailSheet>(open: _openSheet, onDismissed: _viewModel.dismissAdjustSheet);

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load(widget.employeeId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final VacationBalanceDetailUiState state = _viewModel.state;
    _sheet.sync(context, state.isAdjustSheetVisible ? _DetailSheet.adjust : null);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _viewModel.onSnackbarShown();
    }
  }

  Future<void> _openSheet(BuildContext context, _DetailSheet sheet) async {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) => AdjustBalanceSheet(
          form: _viewModel.state.adjustmentForm,
          onOperationChange: _viewModel.onOperationChange,
          onDaysChange: _viewModel.onDaysChange,
          onReasonChange: _viewModel.onReasonChange,
          onSave: _viewModel.saveAdjustment,
          onDismiss: _viewModel.dismissAdjustSheet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final VacationBalanceDetailUiState state = _viewModel.state;
        final VacationBalance? balance = state.balance;
        final Widget content;
        if (state.isLoading) {
          content = const SkeletonList(showAvatar: false);
        } else if (balance == null) {
          content = BenefitsMessageState(
            title: 'No se pudo cargar el saldo',
            message: state.errorMessage ?? 'Inténtalo nuevamente.',
            actionLabel: 'Reintentar',
            onAction: _viewModel.retry,
          );
        } else {
          content = _BalanceDetail(balance: balance);
        }
        return Scaffold(
          floatingActionButton: balance == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: _viewModel.showAdjustSheet,
                  icon: const Icon(BenefitsIcons.edit),
                  label: const Text('Ajustar saldo'),
                ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Saldo de vacaciones',
                subtitle: balance?.employeeName ?? widget.employeeName,
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

class _BalanceDetail extends StatelessWidget {
  const _BalanceDetail({required this.balance});

  final VacationBalance balance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8,
        AppSpacing.screenHorizontal,
        AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        Row(
          spacing: AppSpacing.s,
          children: <Widget>[
            Expanded(child: _StatCard(label: 'Acumulados', value: BenefitsFormatters.number(balance.accruedDays))),
            Expanded(child: _StatCard(label: 'Usados', value: BenefitsFormatters.number(balance.usedDays))),
            Expanded(
              child: _StatCard(
                label: 'Disponibles',
                value: BenefitsFormatters.number(balance.availableDays),
                highlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        const BenefitsSectionHeader(text: 'Movimientos'),
        if (balance.movements.isEmpty)
          Text(
            'Todavía no hay movimientos.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        for (final VacationMovement movement in balance.movements)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: VacationMovementRow(movement: movement, daysInSubtitle: true),
          ),
      ],
    );
  }
}

/// Card of the accrued, used or available days; the available ones in the primary color.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.highlighted = false});

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: <Widget>[
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlighted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
