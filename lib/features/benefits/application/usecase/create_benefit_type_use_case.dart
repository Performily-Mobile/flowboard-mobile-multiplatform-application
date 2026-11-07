import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_type_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';

/// Creates a benefit type (MA-60, US37). The name is required and unique within the catalog.
class CreateBenefitTypeUseCase {
  /// Creates the use case.
  const CreateBenefitTypeUseCase({required this.repository});

  final BenefitTypeRepository repository;

  static const int _maxName = 80;

  /// Creates the type; throws [ArgumentError] when the name is blank or too long.
  Future<BenefitType> execute(String name, BenefitUnit unit, bool hasBalance, {String? description}) {
    final String cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Ingresa el nombre del beneficio.');
    if (cleanName.length > _maxName) throw ArgumentError('El nombre admite hasta $_maxName caracteres.');
    final String? cleanDescription = description?.trim();
    return repository.createBenefitType(
      cleanName,
      cleanDescription == null || cleanDescription.isEmpty ? null : cleanDescription,
      unit,
      hasBalance,
    );
  }
}
