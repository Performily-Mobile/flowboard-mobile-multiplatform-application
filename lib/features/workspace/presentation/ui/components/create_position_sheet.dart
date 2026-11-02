import 'package:flutter/material.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/area_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/personal_data_step.dart';

/// Content of the bottom sheet to create a new position inside an active area.
class CreatePositionSheet extends StatelessWidget {
  /// Creates the content.
  const CreatePositionSheet({
    super.key,
    required this.form,
    required this.areas,
    required this.isSaving,
    required this.onAreaChange,
    required this.onTitleChange,
    required this.onSalaryChange,
    required this.onSave,
    required this.onDismiss,
  });

  final PositionForm form;
  final List<Area> areas;
  final bool isSaving;
  final ValueChanged<int> onAreaChange;
  final ValueChanged<String> onTitleChange;
  final ValueChanged<String> onSalaryChange;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      children: <Widget>[
        const SheetHeader(title: 'Nueva posición'),
        AreaDropdown(
          areas: areas,
          selectedAreaId: form.areaId,
          onSelect: (Area area) => onAreaChange(area.id),
          isError: form.areaError != null,
          supportingText: form.areaError,
        ),
        FormTextField(
          label: 'Nombre de la posición',
          value: form.title,
          onValueChange: onTitleChange,
          error: form.titleError,
          textCapitalization: TextCapitalization.sentences,
        ),
        FormTextField(
          label: 'Sueldo mínimo referencial (S/)',
          value: form.referenceSalary,
          onValueChange: onSalaryChange,
          error: form.salaryError,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SheetActions(
          confirmLabel: 'Crear posición',
          enabled: !isSaving && form.title.trim().isNotEmpty && form.referenceSalary.trim().isNotEmpty,
          isSaving: isSaving,
          onConfirm: onSave,
          onCancel: onDismiss,
        ),
      ],
    );
  }
}
