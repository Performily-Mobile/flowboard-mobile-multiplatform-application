import 'package:flutter/material.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/area_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/contract_assignment_step.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/position_dropdown.dart';

/// Content of the bottom sheet to move an employee to another area, position or direct manager.
class ReassignJobSheet extends StatelessWidget {
  /// Creates the content.
  const ReassignJobSheet({
    super.key,
    required this.employeeName,
    required this.form,
    required this.areas,
    required this.positions,
    required this.managerCandidates,
    required this.isSaving,
    required this.errorMessage,
    required this.onAreaChange,
    required this.onPositionChange,
    required this.onManagerChange,
    required this.onDateChange,
    required this.onSave,
    required this.onDismiss,
  });

  final String employeeName;
  final ReassignJobForm form;
  final List<Area> areas;
  final List<Position> positions;
  final List<Employee> managerCandidates;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<int> onAreaChange;
  final ValueChanged<int> onPositionChange;
  final ValueChanged<EmployeeId?> onManagerChange;
  final ValueChanged<DateTime> onDateChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SheetBody(
      children: <Widget>[
        SheetHeader(title: 'Reasignar puesto', subtitle: employeeName),
        AreaDropdown(areas: areas, selectedAreaId: form.areaId, onSelect: (Area area) => onAreaChange(area.id)),
        PositionDropdown(
          positions: positions,
          selectedPositionId: form.positionId,
          onSelect: (Position position) => onPositionChange(position.id),
          enabled: form.areaId != null,
          isError: form.positionError != null,
          supportingText: form.positionError,
        ),
        EmployeeDropdown(
          label: 'Jefe directo',
          employees: managerCandidates,
          selectedEmployeeId: form.directManagerId,
          onSelect: (Employee? manager) => onManagerChange(manager?.id),
          isError: form.directManagerError != null,
          supportingText: form.directManagerError,
        ),
        DatePickerField(label: 'Fecha efectiva', value: form.effectiveDate, onValueChange: onDateChange),
        const InfoBanner(text: 'El cambio de puesto quedará registrado en el historial del colaborador.'),
        if (errorMessage != null)
          Text(errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        SheetActions(
          confirmLabel: 'Guardar cambios',
          enabled: !isSaving,
          isSaving: isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}
