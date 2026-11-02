/// Body to create a position.
class CreatePositionRequestDto {
  /// Creates the DTO.
  const CreatePositionRequestDto({
    required this.title,
    required this.areaId,
    required this.referenceSalaryAmount,
    required this.referenceSalaryCurrency,
  });

  final String title;
  final int areaId;
  final double referenceSalaryAmount;
  final String referenceSalaryCurrency;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'areaId': areaId,
        'referenceSalaryAmount': referenceSalaryAmount,
        'referenceSalaryCurrency': referenceSalaryCurrency,
      };
}
