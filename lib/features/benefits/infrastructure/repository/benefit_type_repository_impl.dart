import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_type_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/benefits_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_type_dto.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_type_service.dart';

/// Benefit type catalog read from and written to the Flowboard API.
class BenefitTypeRepositoryImpl implements BenefitTypeRepository {
  /// Creates the repository.
  const BenefitTypeRepositoryImpl({required this.service});

  final BenefitTypeService service;

  @override
  Future<List<BenefitType>> getBenefitTypes({required bool activeOnly}) async {
    final List<BenefitTypeDto> dtos = await service.getBenefitTypes(activeOnly: activeOnly);
    return dtos.map(BenefitsMapper.toBenefitType).toList();
  }

  @override
  Future<BenefitType> createBenefitType(String name, String? description, BenefitUnit unit, bool hasBalance) async {
    final CreateBenefitTypeRequestDto request = BenefitsMapper.toCreateRequest(name, description, unit, hasBalance);
    return BenefitsMapper.toBenefitType(await service.createBenefitType(request));
  }

  @override
  Future<BenefitType> activate(int benefitTypeId) async {
    return BenefitsMapper.toBenefitType(await service.activate(benefitTypeId));
  }

  @override
  Future<BenefitType> deactivate(int benefitTypeId) async {
    return BenefitsMapper.toBenefitType(await service.deactivate(benefitTypeId));
  }
}
