import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';

/// How many employees of an area will receive a benefit and how many will be skipped (MA-61).
class PreviewAreaAssignmentUseCase {
  /// Creates the use case.
  const PreviewAreaAssignmentUseCase({required this.repository});

  final BenefitAssignmentRepository repository;

  /// Preview of the assignment; throws [ArgumentError] when the end date is before the start.
  Future<AreaAssignmentPreview> execute(int benefitTypeId, int areaId, DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) throw ArgumentError('La fecha final no puede ser anterior a la inicial.');
    return repository.previewAreaAssignment(benefitTypeId, areaId, startDate, endDate);
  }
}
