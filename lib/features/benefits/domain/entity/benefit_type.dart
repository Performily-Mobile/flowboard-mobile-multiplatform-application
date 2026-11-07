import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

/// Benefit type of the catalog (US37). Only the active ones can be assigned.
class BenefitType {
  /// Creates the benefit type.
  const BenefitType({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.hasBalance,
    required this.active,
  });

  final int id;
  final String name;
  final String? description;
  final BenefitUnit unit;
  final bool hasBalance;
  final bool active;

  @override
  bool operator ==(Object other) => other is BenefitType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
