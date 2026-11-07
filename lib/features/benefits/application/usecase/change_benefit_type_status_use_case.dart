import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_type_repository.dart';

/// Activates or deactivates a benefit type (MA-60).
///
/// An inactive type stays in the catalog but can no longer be assigned.
class ChangeBenefitTypeStatusUseCase {
  /// Creates the use case.
  const ChangeBenefitTypeStatusUseCase({required this.repository});

  final BenefitTypeRepository repository;

  /// Deactivates [benefitType] when it is active, otherwise activates it.
  Future<BenefitType> execute(BenefitType benefitType) =>
      benefitType.active ? repository.deactivate(benefitType.id) : repository.activate(benefitType.id);
}
