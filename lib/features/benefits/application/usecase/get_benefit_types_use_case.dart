import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_type_repository.dart';

/// Benefit catalog sorted by name (MA-60). [activeOnly] true lists the types that can be assigned.
class GetBenefitTypesUseCase {
  /// Creates the use case.
  const GetBenefitTypesUseCase({required this.repository});

  final BenefitTypeRepository repository;

  /// Benefit types sorted by name.
  Future<List<BenefitType>> execute({bool activeOnly = false}) async {
    final List<BenefitType> types = await repository.getBenefitTypes(activeOnly: activeOnly);
    return types..sort((BenefitType a, BenefitType b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
