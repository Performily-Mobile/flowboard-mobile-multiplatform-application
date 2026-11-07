import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_type_dto.dart';

/// Endpoints of /benefit-types (US37).
class BenefitTypeService {
  /// Creates the service.
  const BenefitTypeService({required this.client});

  final ApiClient client;

  /// GET benefit-types.
  Future<List<BenefitTypeDto>> getBenefitTypes({required bool activeOnly}) async {
    final List<dynamic> json =
        await client.get('benefit-types', query: <String, dynamic>{'activeOnly': activeOnly}) as List<dynamic>;
    return json.map((dynamic item) => BenefitTypeDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST benefit-types.
  Future<BenefitTypeDto> createBenefitType(CreateBenefitTypeRequestDto request) async {
    return BenefitTypeDto.fromJson(await client.post('benefit-types', body: request.toJson()) as Map<String, dynamic>);
  }

  /// PATCH benefit-types/{benefitTypeId}/activate.
  Future<BenefitTypeDto> activate(int benefitTypeId) async {
    return BenefitTypeDto.fromJson(await client.patch('benefit-types/$benefitTypeId/activate') as Map<String, dynamic>);
  }

  /// PATCH benefit-types/{benefitTypeId}/deactivate.
  Future<BenefitTypeDto> deactivate(int benefitTypeId) async {
    return BenefitTypeDto.fromJson(
      await client.patch('benefit-types/$benefitTypeId/deactivate') as Map<String, dynamic>,
    );
  }
}
