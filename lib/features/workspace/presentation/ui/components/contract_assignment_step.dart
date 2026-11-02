import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/presentation/state/register_employee_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/area_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/position_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// Second step of the employee registration: contract, area, position and direct manager.
class ContractAssignmentStep extends StatelessWidget {
  /// Creates the step.
  const ContractAssignmentStep({
    super.key,
    required this.state,
    required this.onContractTypeChange,
    required this.onHireDateChange,
    required this.onContractEndDateChange,
    required this.onAreaChange,
    required this.onPositionChange,
    required this.onDirectManagerChange,
  });

  final RegisterEmployeeUiState state;
  final ValueChanged<ContractType> onContractTypeChange;
  final ValueChanged<DateTime> onHireDateChange;
  final ValueChanged<DateTime> onContractEndDateChange;
  final ValueChanged<int> onAreaChange;
  final ValueChanged<int> onPositionChange;
  final ValueChanged<EmployeeId?> onDirectManagerChange;

  @override
  Widget build(BuildContext context) {
    final Position? position = state.selectedPosition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.m,
      children: <Widget>[
        SelectField<ContractType>(
          label: 'Tipo de contrato',
          options: ContractType.values,
          selected: state.contractType,
          optionLabel: (ContractType type) => type.label,
          onSelect: onContractTypeChange,
        ),
        DatePickerField(
          label: 'Fecha de ingreso',
          value: state.hireDate,
          onValueChange: onHireDateChange,
          isError: state.errorOf(RegisterField.hireDate) != null,
          supportingText: state.errorOf(RegisterField.hireDate),
        ),
        if (state.contractType == ContractType.fixedTerm)
          DatePickerField(
            label: 'Fecha de fin de contrato',
            value: state.contractEndDate,
            onValueChange: onContractEndDateChange,
            isError: state.errorOf(RegisterField.contractEndDate) != null,
            supportingText: state.errorOf(RegisterField.contractEndDate),
          ),
        AreaDropdown(
          areas: state.areas,
          selectedAreaId: state.areaId,
          onSelect: (Area area) => onAreaChange(area.id),
          isError: state.errorOf(RegisterField.area) != null,
          supportingText: state.errorOf(RegisterField.area),
        ),
        PositionDropdown(
          positions: state.positions,
          selectedPositionId: state.positionId,
          onSelect: (Position selected) => onPositionChange(selected.id),
          enabled: state.areaId != null,
          isError: state.errorOf(RegisterField.position) != null,
          supportingText: state.errorOf(RegisterField.position) ??
              (position == null ? null : 'Sueldo mínimo referencial del puesto: ${position.referenceSalary.display}'),
        ),
        EmployeeDropdown(
          label: 'Jefe directo',
          employees: state.managers,
          selectedEmployeeId: state.directManagerId,
          onSelect: (Employee? manager) => onDirectManagerChange(manager?.id),
        ),
        const InfoBanner(
          text: 'Al registrar, RR.HH. generará sus credenciales de acceso y le entregará la contraseña temporal.',
        ),
      ],
    );
  }
}

/// Tinted glass banner with an info icon for a short note of a form.
class InfoBanner extends StatelessWidget {
  /// Creates the banner with its [text].
  const InfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        tint: scheme.secondaryContainer,
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: AppSpacing.m,
          children: <Widget>[
            Icon(FlowboardIcons.info, size: 20, color: scheme.onSecondaryContainer),
            Expanded(
              child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}
