import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/presentation/state/benefits_admin_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_colors.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_dialogs.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_formatters.dart';
import 'package:flowboard/features/benefits/presentation/ui/navigation/benefits_routes.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/benefits_admin_view_model.dart';

const int _catalogTab = 0;

/// Sheet open on the benefits screen.
enum _AdminSheet { newType }

/// Benefits of HR (MA-60, MA-62): catalog of types and assignments with the delivery registration.
///
/// The top bar opens the vacation balances.
class BenefitsAdminScreen extends StatefulWidget {
  /// Creates the screen.
  const BenefitsAdminScreen({super.key});

  @override
  State<BenefitsAdminScreen> createState() => _BenefitsAdminScreenState();
}

class _BenefitsAdminScreenState extends State<BenefitsAdminScreen> {
  late final BenefitsAdminViewModel _viewModel = getIt<BenefitsAdminViewModel>();
  late final ModalSync<_AdminSheet> _typeSheet =
      ModalSync<_AdminSheet>(open: _openTypeSheet, onDismissed: _viewModel.dismissTypeSheet);
  late final ModalSync<BenefitType> _toggleDialog =
      ModalSync<BenefitType>(open: _openToggleDialog, onDismissed: _viewModel.dismissToggleType);
  late final ModalSync<BenefitAssignment> _deliveryDialog =
      ModalSync<BenefitAssignment>(open: _openDeliveryDialog, onDismissed: _viewModel.dismissDeliveryDialog);

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
    if (!mounted) return;
    final BenefitsAdminUiState state = _viewModel.state;
    _typeSheet.sync(context, state.isTypeSheetVisible ? _AdminSheet.newType : null);
    _toggleDialog.sync(context, state.typeToToggle);
    _deliveryDialog.sync(context, state.deliveryForm?.assignment);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _viewModel.onSnackbarShown();
    }
  }

  Future<void> _assign() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(BenefitsRoutes.assignBenefit);
    if (mounted && result is String) _viewModel.onAssignmentResult(result);
  }

  Future<void> _openTypeSheet(BuildContext context, _AdminSheet sheet) async {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) => CreateBenefitTypeSheet(
          form: _viewModel.state.typeForm,
          onNameChange: _viewModel.onTypeNameChange,
          onUnitChange: _viewModel.onTypeUnitChange,
          onHasBalanceChange: _viewModel.onTypeHasBalanceChange,
          onCreate: _viewModel.saveType,
          onDismiss: _viewModel.dismissTypeSheet,
        ),
      ),
    );
  }

  Future<void> _openToggleDialog(BuildContext context, BenefitType type) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) => ToggleBenefitTypeDialog(
          benefitType: type,
          isSaving: _viewModel.state.isTogglingType,
          onConfirm: _viewModel.confirmToggleType,
          onDismiss: _viewModel.dismissToggleType,
        ),
      ),
    );
  }

  Future<void> _openDeliveryDialog(BuildContext context, BenefitAssignment assignment) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final DeliveryForm? form = _viewModel.state.deliveryForm;
          if (form == null) return const SizedBox.shrink();
          return RegisterDeliveryDialog(
            form: form,
            onDateChange: _viewModel.onDeliveryDateChange,
            onNotesChange: _viewModel.onDeliveryNotesChange,
            onConfirm: _viewModel.confirmDelivery,
            onDismiss: _viewModel.dismissDeliveryDialog,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final BenefitsAdminUiState state = _viewModel.state;
        final bool catalog = state.selectedTab == _catalogTab;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: catalog ? _viewModel.showTypeSheet : _assign,
            icon: const Icon(FlowboardIcons.add),
            label: Text(catalog ? 'Nuevo beneficio' : 'Asignar beneficio'),
          ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Beneficios',
                onBack: navigator.canPop() ? () => navigator.maybePop() : null,
                actions: <Widget>[
                  TextButton(
                    onPressed: () => navigator.pushNamed(BenefitsRoutes.vacationBalances),
                    child: const Text('Vacaciones'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                child: FlowboardIndexTabs(
                  labels: const <String>['Catálogo', 'Asignaciones'],
                  selectedIndex: state.selectedTab,
                  onSelect: _viewModel.onTabSelected,
                ),
              ),
              Expanded(
                child: catalog
                    ? _CatalogTab(state: state, onTypeTap: _viewModel.requestToggleType, onRetry: _viewModel.load)
                    : _AssignmentsTab(
                        state: state,
                        onFilterSelected: _viewModel.onFilterSelected,
                        onAssignmentTap: _viewModel.showDeliveryDialog,
                        onRetry: _viewModel.load,
                      ),
              ),
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
      AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
    );

/// Catalog (MA-60). Tapping a type lets HR activate or deactivate it.
class _CatalogTab extends StatelessWidget {
  const _CatalogTab({required this.state, required this.onTypeTap, required this.onRetry});

  final BenefitsAdminUiState state;
  final ValueChanged<BenefitType> onTypeTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String? error = state.catalogError;
    if (state.isLoadingCatalog) return const SkeletonList(showAvatar: false);
    if (error != null && state.benefitTypes.isEmpty) {
      return BenefitsMessageState(
        title: 'No se pudo cargar el catálogo',
        message: error,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }
    if (state.benefitTypes.isEmpty) {
      return const BenefitsMessageState(
        title: 'El catálogo está vacío',
        message: 'Crea el primer tipo de beneficio con el botón "Nuevo beneficio".',
      );
    }
    return ListView.separated(
      padding: _listPadding(context),
      itemCount: state.benefitTypes.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (BuildContext context, int index) {
        final BenefitType type = state.benefitTypes[index];
        return BenefitListItem(
          leading: const GlassIconBadge(icon: FlowboardIcons.gift),
          title: type.name,
          subtitle: _catalogDetail(type),
          onTap: () => onTypeTap(type),
          trailing: BenefitChip(
            text: type.active ? 'Activo' : 'Inactivo',
            containerColor: type.active ? BenefitsColors.active : BenefitsColors.inactive,
          ),
        );
      },
    );
  }

  /// "Monto (S/) · Maneja saldo": the unit plus the balance or the description.
  String _catalogDetail(BenefitType type) =>
      <String?>[type.unit.label, type.hasBalance ? 'Maneja saldo' : type.description].whereType<String>().join(' · ');
}

/// Assignments to deliver or delivered (MA-62). Tapping one to deliver opens "Registrar entrega".
class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({
    required this.state,
    required this.onFilterSelected,
    required this.onAssignmentTap,
    required this.onRetry,
  });

  final BenefitsAdminUiState state;
  final ValueChanged<AssignmentStatus> onFilterSelected;
  final ValueChanged<BenefitAssignment> onAssignmentTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool toDeliver = state.assignmentFilter == AssignmentStatus.assigned;
    final String? error = state.assignmentsError;
    final Widget content;
    if (state.isLoadingAssignments) {
      content = const SkeletonList();
    } else if (error != null && state.assignments.isEmpty) {
      content = BenefitsMessageState(
        title: 'No se pudieron cargar las asignaciones',
        message: error,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    } else if (state.assignments.isEmpty) {
      content = BenefitsMessageState(
        title: toDeliver ? 'No hay beneficios por entregar' : 'Aún no hay entregas',
        message: toDeliver
            ? 'Asigna un beneficio a un colaborador o a un área con el botón "Asignar beneficio".'
            : 'Las entregas registradas aparecerán aquí.',
      );
    } else {
      content = ListView.separated(
        padding: _listPadding(context),
        itemCount: state.assignments.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
        itemBuilder: (BuildContext context, int index) {
          final BenefitAssignment assignment = state.assignments[index];
          return _AssignmentItem(assignment: assignment, onTap: () => onAssignmentTap(assignment));
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 0, AppSpacing.screenHorizontal, 12),
          child: FlowboardTabs<AssignmentStatus>(
            options: const <AssignmentStatus>[AssignmentStatus.assigned, AssignmentStatus.delivered],
            selected: state.assignmentFilter,
            onSelect: onFilterSelected,
            labelOf: (AssignmentStatus status) => status == AssignmentStatus.assigned ? 'Por entregar' : 'Entregados',
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  const _AssignmentItem({required this.assignment, required this.onTap});

  final BenefitAssignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String quantity =
        '${assignment.benefitTypeName} · ${BenefitsFormatters.quantity(assignment.quantity, assignment.unit)}';
    final DateTime? deliveredOn = assignment.delivery?.deliveredOn;
    return BenefitListItem(
      leading: InitialsAvatar(name: assignment.employeeName),
      title: assignment.employeeName,
      subtitle: deliveredOn == null ? quantity : '$quantity · ${BenefitsFormatters.date(deliveredOn)}',
      onTap: assignment.canBeDelivered ? onTap : null,
      trailing: BenefitChip(text: assignment.status.label, containerColor: BenefitsColors.status(assignment.status)),
    );
  }
}
