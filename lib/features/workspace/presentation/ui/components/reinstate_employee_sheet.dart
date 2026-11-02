import 'package:flutter/material.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/area_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/position_dropdown.dart';

/// Content of the bottom sheet to bring a terminated employee back with a new position.
class ReinstateEmployeeSheet extends StatelessWidget {
  /// Creates the content.
  const ReinstateEmployeeSheet({
    super.key,
    required this.employeeName,
    required this.form,
    required this.areas,
    required this.positions,
    required this.isSaving,
    required this.errorMessage,
    required this.onAreaChange,
    required this.onPositionChange,
    required this.onDateChange,
    required this.onSave,
    required this.onDismiss,
  });

  final String employeeName;
  final ReinstateForm form;
  final List<Area> areas;
  final List<Position> positions;
  final bool isSaving;
  final String? errorMessage;
  final ValueChanged<int> onAreaChange;
  final ValueChanged<int> onPositionChange;
  final ValueChanged<DateTime> onDateChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SheetBody(
      children: <Widget>[
        SheetHeader(
          title: 'Reincorporar colaborador',
          subtitle: '$employeeName volverá a estado Activo con el puesto que elijas.',
        ),
        AreaDropdown(
          areas: areas,
          selectedAreaId: form.areaId,
          onSelect: (Area area) => onAreaChange(area.id),
          isError: form.areaError != null,
          supportingText: form.areaError,
        ),
        PositionDropdown(
          positions: positions,
          selectedPositionId: form.positionId,
          onSelect: (Position position) => onPositionChange(position.id),
          enabled: form.areaId != null,
          isError: form.positionError != null,
          supportingText: form.positionError,
        ),
        DatePickerField(label: 'Fecha de reingreso', value: form.reinstatementDate, onValueChange: onDateChange),
        if (errorMessage != null)
          Text(errorMessage!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        SheetActions(
          confirmLabel: 'Reincorporar',
          enabled: !isSaving,
          isSaving: isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}
