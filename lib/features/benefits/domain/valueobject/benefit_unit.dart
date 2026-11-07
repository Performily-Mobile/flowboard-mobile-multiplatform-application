/// Unit in which a benefit type is measured.
///
/// [money] in soles, [days] in calendar days and [units] in whole pieces.
enum BenefitUnit {
  money('Monto (S/)', 'Monto'),
  days('Días', 'Cantidad de días'),
  units('Unidades', 'Cantidad');

  const BenefitUnit(this.label, this.quantityLabel);

  /// Name shown in the catalog and in the new type form (MA-60).
  final String label;

  /// Label of the quantity field when assigning (MA-61).
  final String quantityLabel;
}
