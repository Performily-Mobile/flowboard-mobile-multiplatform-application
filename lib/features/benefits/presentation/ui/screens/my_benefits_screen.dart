import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/presentation/state/my_benefits_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_colors.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/my_benefits_view_model.dart';

/// Delivered benefits also listed in the "Vigentes" tab, as in MA-58.
const int _recentDelivered = 2;

/// Current and delivered benefits of the employee (MA-58, MA-59).
class MyBenefitsScreen extends StatefulWidget {
  /// Creates the screen.
  const MyBenefitsScreen({super.key});

  @override
  State<MyBenefitsScreen> createState() => _MyBenefitsScreenState();
}

class _MyBenefitsScreenState extends State<MyBenefitsScreen> {
  late final MyBenefitsViewModel _viewModel = getIt<MyBenefitsViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final MyBenefitsUiState state = _viewModel.state;
        final EmployeeBenefits? benefits = state.benefits;
        final String? error = state.errorMessage;
        final Widget content;
        if (state.isLoading) {
          content = const SkeletonList(showAvatar: false);
        } else if (benefits == null) {
          content = BenefitsMessageState(
            title: 'No se pudieron cargar tus beneficios',
            message: error ?? 'Inténtalo nuevamente.',
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          );
        } else {
          content = state.selectedTab == 0 ? _CurrentTab(benefits: benefits) : _DeliveredTab(delivered: benefits.delivered);
        }
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Mis beneficios', onBack: navigator.canPop() ? () => navigator.maybePop() : null),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.s,
                  children: <Widget>[
                    FlowboardIndexTabs(
                      labels: <String>['Vigentes (${state.currentCount})', 'Entregados (${state.deliveredCount})'],
                      selectedIndex: state.selectedTab,
                      onSelect: _viewModel.onTabSelected,
                    ),
                    if (benefits != null && error != null)
                      BenefitsBanner(
                        message: error,
                        icon: FlowboardIcons.warning,
                        containerColor: BenefitsColors.warningBanner,
                        contentColor: BenefitsColors.onWarningBanner,
                        actionLabel: 'Reintentar',
                        onAction: _viewModel.load,
                      ),
                  ],
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

EdgeInsets _listPadding(BuildContext context) => EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      0,
      AppSpacing.screenHorizontal,
      AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
    );

class _CurrentTab extends StatelessWidget {
  const _CurrentTab({required this.benefits});

  final EmployeeBenefits benefits;

  @override
  Widget build(BuildContext context) {
    final List<BenefitAssignment> recent = benefits.delivered.take(_recentDelivered).toList();
    return ListView(
      padding: _listPadding(context),
      children: <Widget>[
        if (benefits.current.isEmpty)
          const BenefitsMessageState(
            title: 'No tienes beneficios vigentes',
            message: 'Cuando RR.HH. te asigne un beneficio aparecerá aquí.',
            topPadding: 24,
          ),
        for (final BenefitAssignment assignment in benefits.current)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
            child: _CurrentBenefitCard(assignment: assignment),
          ),
        if (recent.isNotEmpty) ...<Widget>[
          const BenefitsSectionHeader(text: 'Entregados recientemente'),
          for (final BenefitAssignment assignment in recent)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: _DeliveredItem(assignment: assignment),
            ),
        ],
      ],
    );
  }
}

class _DeliveredTab extends StatelessWidget {
  const _DeliveredTab({required this.delivered});

  final List<BenefitAssignment> delivered;

  @override
  Widget build(BuildContext context) {
    if (delivered.isEmpty) {
      return const BenefitsMessageState(
        title: 'Aún no tienes beneficios entregados',
        message: 'Cuando RR.HH. registre la entrega de un beneficio, lo verás aquí.',
      );
    }
    return ListView.separated(
      padding: _listPadding(context),
      itemCount: delivered.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (BuildContext context, int index) => _DeliveredItem(assignment: delivered[index]),
    );
  }
}

/// Card of a current benefit (MA-58).
class _CurrentBenefitCard extends StatelessWidget {
  const _CurrentBenefitCard({required this.assignment});

  final BenefitAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          const GlassIconBadge(icon: FlowboardIcons.gift),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(assignment.benefitTypeName, style: theme.textTheme.bodyLarge),
                Text(
                  'Periodo: ${BenefitsFormatters.period(assignment.startDate, assignment.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  BenefitsFormatters.quantity(assignment.quantity, assignment.unit),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          BenefitChip(text: AssignmentStatus.assigned.label, containerColor: BenefitsColors.assigned),
        ],
      ),
    );
  }
}

/// Item of a delivered benefit (MA-59): "Entregado el 15/07/2026 · S/ 1,240.00".
class _DeliveredItem extends StatelessWidget {
  const _DeliveredItem({required this.assignment});

  final BenefitAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final DateTime? deliveredOn = assignment.delivery?.deliveredOn;
    return BenefitListItem(
      leading: const GlassIconBadge(icon: FlowboardIcons.gift),
      title: assignment.benefitTypeName,
      subtitle: <String?>[
        deliveredOn == null ? null : 'Entregado el ${BenefitsFormatters.date(deliveredOn)}',
        BenefitsFormatters.quantity(assignment.quantity, assignment.unit),
      ].whereType<String>().join(' · '),
      trailing: BenefitChip(text: AssignmentStatus.delivered.label, containerColor: BenefitsColors.delivered),
    );
  }
}
