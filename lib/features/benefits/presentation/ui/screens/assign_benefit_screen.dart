import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/entity/directory_entries.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/presentation/state/assign_benefit_ui_state.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_colors.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_common.dart';
import 'package:flowboard/features/benefits/presentation/ui/components/benefits_fields.dart';
import 'package:flowboard/features/benefits/presentation/viewmodel/assign_benefit_view_model.dart';

/// Assign benefit form (MA-61), full screen without the bottom bar.
///
/// It closes with the result message, which the benefits screen shows in its snackbar.
class AssignBenefitScreen extends StatefulWidget {
  /// Creates the screen.
  const AssignBenefitScreen({super.key});

  @override
  State<AssignBenefitScreen> createState() => _AssignBenefitScreenState();
}

class _AssignBenefitScreenState extends State<AssignBenefitScreen> {
  late final AssignBenefitViewModel _viewModel = getIt<AssignBenefitViewModel>();
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
    final String? message = _viewModel.state.resultMessage;
    if (!mounted || _closed || message == null) return;
    _closed = true;
    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AssignBenefitUiState state = _viewModel.state;
        final ThemeData theme = Theme.of(context);
        final String? loadError = state.loadError;
        final String? errorMessage = state.errorMessage;
        final bool showForm = !state.isLoading && loadError == null && state.benefitTypes.isNotEmpty;

        final Widget content;
        if (state.isLoading) {
          content = const SkeletonForm(fieldCount: 5);
        } else if (loadError != null) {
          content = BenefitsMessageState(
            title: 'No se pudo abrir el formulario',
            message: loadError,
            actionLabel: 'Reintentar',
            onAction: _viewModel.load,
          );
        } else if (state.benefitTypes.isEmpty) {
          content = const BenefitsMessageState(
            title: 'No hay beneficios activos',
            message: 'Activa o crea un tipo de beneficio en el catálogo para poder asignarlo.',
          );
        } else {
          content = _AssignForm(state: state, viewModel: _viewModel);
        }

        return Scaffold(
          bottomNavigationBar: showForm
              ? FlowboardBottomActionBar(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.s),
                              child: Text(
                                errorMessage,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                              ),
                            ),
                          FilledButton(
                            onPressed: state.canSubmit ? _viewModel.onSubmit : null,
                            child: state.isSubmitting ? const BenefitsButtonProgress() : Text(state.submitLabel),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Asignar beneficio', onClose: () => Navigator.of(context).maybePop()),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _AssignForm extends StatelessWidget {
  const _AssignForm({required this.state, required this.viewModel});

  final AssignBenefitUiState state;
  final AssignBenefitViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BenefitUnit unit = state.selectedType?.unit ?? BenefitUnit.money;
    final AreaAssignmentPreview? preview = state.preview;
    final String? dateError = state.dateError;
    final bool areaMode = state.mode == AssignTargetMode.area;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          BenefitsSelectField<BenefitType>(
            label: 'Tipo de beneficio',
            options: state.benefitTypes,
            selected: state.selectedType,
            optionLabel: (BenefitType type) => type.name,
            onSelect: viewModel.onTypeSelected,
          ),
          Text('Asignar a', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          BenefitsSegmented<AssignTargetMode>(
            options: AssignTargetMode.values,
            selected: state.mode,
            optionLabel: (AssignTargetMode mode) => mode.label,
            onSelect: viewModel.onModeSelected,
          ),
          if (areaMode)
            BenefitsSelectField<AreaOption>(
              label: 'Área',
              options: state.areas,
              selected: state.selectedArea,
              optionLabel: (AreaOption area) => area.name,
              onSelect: viewModel.onAreaSelected,
              supportingText: _areaHelper(state),
              isError: state.previewError != null,
            )
          else
            BenefitsSelectField<EmployeeOption>(
              label: 'Colaborador',
              options: state.employees,
              selected: state.selectedEmployee,
              optionLabel: (EmployeeOption employee) => '${employee.name} · ${employee.areaName}',
              onSelect: viewModel.onEmployeeSelected,
            ),
          BenefitsTextField(
            label: unit.quantityLabel,
            value: state.quantity,
            onValueChange: viewModel.onQuantityChange,
            error: state.quantityError,
            numeric: true,
            integerOnly: unit == BenefitUnit.units,
            prefix: unit == BenefitUnit.money ? 'S/' : null,
            suffix: switch (unit) {
              BenefitUnit.days => 'días',
              BenefitUnit.units => 'unidades',
              BenefitUnit.money => null,
            },
          ),
          Row(
            spacing: AppSpacing.m,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: BenefitsDateField(
                  label: 'Desde',
                  value: state.startDate,
                  onValueChange: viewModel.onStartDateChange,
                ),
              ),
              Expanded(
                child: BenefitsDateField(
                  label: 'Hasta',
                  value: state.endDate,
                  onValueChange: viewModel.onEndDateChange,
                  firstDate: state.startDate,
                  isError: dateError != null,
                ),
              ),
            ],
          ),
          if (dateError != null)
            Text(dateError, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          if (areaMode && preview != null && preview.alreadyAssigned > 0)
            BenefitsBanner(
              message: _skippedMessage(preview),
              icon: FlowboardIcons.warning,
              containerColor: BenefitsColors.warningBanner,
              contentColor: BenefitsColors.onWarningBanner,
            ),
        ],
      ),
    );
  }

  String _skippedMessage(AreaAssignmentPreview preview) {
    final int skipped = preview.alreadyAssigned;
    if (preview.toAssign == 0) return 'Todos los colaboradores activos del área ya tienen este beneficio en el periodo.';
    if (skipped == 1) return '1 colaborador ya tiene este beneficio en el periodo y será omitido.';
    return '$skipped colaboradores ya tienen este beneficio en el periodo y serán omitidos.';
  }

  /// Helper of the area field: "Se asignará a los 48 colaboradores activos del área."
  String? _areaHelper(AssignBenefitUiState state) {
    final AreaOption? area = state.selectedArea;
    if (area == null) return null;
    final String? previewError = state.previewError;
    if (previewError != null) return previewError;
    if (state.isLoadingPreview) return 'Calculando colaboradores…';
    final int active = state.preview?.activeEmployees ?? area.activeEmployees;
    return switch (active) {
      0 => 'El área no tiene colaboradores activos.',
      1 => 'Se asignará al único colaborador activo del área.',
      _ => 'Se asignará a los $active colaboradores activos del área.',
    };
  }
}
