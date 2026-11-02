import 'package:flutter/widgets.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';

/// Field to choose a position of the selected area.
class PositionDropdown extends StatelessWidget {
  /// Creates the field.
  const PositionDropdown({
    super.key,
    required this.positions,
    required this.selectedPositionId,
    required this.onSelect,
    this.enabled = true,
    this.isError = false,
    this.supportingText,
  });

  final List<Position> positions;
  final int? selectedPositionId;
  final ValueChanged<Position> onSelect;
  final bool enabled;
  final bool isError;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    Position? selected;
    for (final Position position in positions) {
      if (position.id == selectedPositionId) selected = position;
    }
    return SelectField<Position>(
      label: 'Posición',
      options: positions,
      selected: selected,
      optionLabel: (Position position) => position.title,
      onSelect: onSelect,
      enabled: enabled,
      isError: isError,
      supportingText: supportingText,
    );
  }
}
