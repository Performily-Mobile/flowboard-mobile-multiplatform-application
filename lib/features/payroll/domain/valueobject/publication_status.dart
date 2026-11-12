/// Whether the payslip is still under HR review or the employee can already see it.
enum PublicationStatus {
  underReview('Por publicar'),
  published('Publicada');

  const PublicationStatus(this.label);

  /// Text shown in the status chip.
  final String label;
}
