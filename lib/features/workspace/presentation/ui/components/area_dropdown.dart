import 'package:flutter/widgets.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';

/// Field to choose an area.
class AreaDropdown extends StatelessWidget {
  /// Creates the field.
  const AreaDropdown({
    super.key,
    required this.areas,
    required this.selectedAreaId,
    required this.onSelect,
    this.isError = false,
    this.supportingText,
  });

  final List<Area> areas;
  final int? selectedAreaId;
  final ValueChanged<Area> onSelect;
  final bool isError;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    Area? selected;
    for (final Area area in areas) {
      if (area.id == selectedAreaId) selected = area;
    }
    return SelectField<Area>(
      label: 'Área',
      options: areas,
      selected: selected,
      optionLabel: (Area area) => area.name,
      onSelect: onSelect,
      isError: isError,
      supportingText: supportingText,
    );
  }
}
