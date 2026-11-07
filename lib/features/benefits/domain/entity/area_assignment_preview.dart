/// Preview of assigning a benefit to an area (MA-61).
///
/// Tells how many active employees the area has, how many already have the benefit in the period
/// (they are skipped) and how many will receive it.
class AreaAssignmentPreview {
  /// Creates the preview.
  const AreaAssignmentPreview({
    required this.areaId,
    required this.activeEmployees,
    required this.alreadyAssigned,
    required this.toAssign,
  });

  final int areaId;
  final int activeEmployees;
  final int alreadyAssigned;
  final int toAssign;
}
