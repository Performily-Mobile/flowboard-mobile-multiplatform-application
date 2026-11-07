import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

/// Repository of the benefit type catalog.
abstract class BenefitTypeRepository {
  /// Benefit types; only the active ones when [activeOnly] is true.
  Future<List<BenefitType>> getBenefitTypes({required bool activeOnly});

  /// Creates a benefit type.
  Future<BenefitType> createBenefitType(String name, String? description, BenefitUnit unit, bool hasBalance);

  /// Activates the benefit type [benefitTypeId].
  Future<BenefitType> activate(int benefitTypeId);

  /// Deactivates the benefit type [benefitTypeId].
  Future<BenefitType> deactivate(int benefitTypeId);
}
