/// Life cycle of an assignment: [assigned] moves to [delivered] or [cancelled], which are final.
enum AssignmentStatus {
  assigned('Asignado'),
  delivered('Entregado'),
  cancelled('Anulado');

  const AssignmentStatus(this.label);

  /// Text shown in the status chip.
  final String label;
}
