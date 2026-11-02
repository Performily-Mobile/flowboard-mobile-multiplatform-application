/// Body to change the reference salary of a position.
class UpdatePositionReferenceSalaryRequestDto {
  /// Creates the DTO.
  const UpdatePositionReferenceSalaryRequestDto({
    required this.referenceSalaryAmount,
    required this.referenceSalaryCurrency,
  });

  final double referenceSalaryAmount;
  final String referenceSalaryCurrency;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'referenceSalaryAmount': referenceSalaryAmount,
        'referenceSalaryCurrency': referenceSalaryCurrency,
      };
}
