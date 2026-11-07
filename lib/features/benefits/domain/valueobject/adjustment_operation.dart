/// Direction of a manual vacation adjustment (MA-63): add or deduct days.
enum AdjustmentOperation {
  add('Agregar días'),
  deduct('Descontar días');

  const AdjustmentOperation(this.label);

  /// Text shown in the adjustment form.
  final String label;
}
