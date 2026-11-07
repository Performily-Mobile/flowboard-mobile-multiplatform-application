import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_assignment_dto.dart';

/// Endpoints of /benefits: assignments (US38), deliveries (US39) and my benefits (US40).
class BenefitService {
  /// Creates the service.
  const BenefitService({required this.client});

  final ApiClient client;

  /// GET benefits, optionally filtered by status and benefit type.
  Future<List<BenefitAssignmentDto>> getAssignments({String? status, int? benefitTypeId}) async {
    final List<dynamic> json = await client.get(
      'benefits',
      query: <String, dynamic>{'status': status, 'benefitTypeId': benefitTypeId},
    ) as List<dynamic>;
    return json.map((dynamic item) => BenefitAssignmentDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// GET benefits/area-preview.
  Future<AreaAssignmentPreviewDto> previewAreaAssignment(
    int benefitTypeId,
    int areaId,
    String startDate,
    String endDate,
  ) async {
    final Object? json = await client.get(
      'benefits/area-preview',
      query: <String, dynamic>{
        'benefitTypeId': benefitTypeId,
        'areaId': areaId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return AreaAssignmentPreviewDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET benefits/me.
  Future<EmployeeBenefitsDto> getMyBenefits(int employeeId) async {
    final Object? json = await client.get('benefits/me', query: <String, dynamic>{'employeeId': employeeId});
    return EmployeeBenefitsDto.fromJson(json as Map<String, dynamic>);
  }

  /// POST benefits.
  Future<BenefitAssignmentBatchDto> assign(AssignBenefitRequestDto request) async {
    final Object? json = await client.post('benefits', body: request.toJson());
    return BenefitAssignmentBatchDto.fromJson(json as Map<String, dynamic>);
  }

  /// POST benefits/{assignmentId}/deliveries.
  Future<BenefitAssignmentDto> registerDelivery(int assignmentId, RegisterDeliveryRequestDto request) async {
    final Object? json = await client.post('benefits/$assignmentId/deliveries', body: request.toJson());
    return BenefitAssignmentDto.fromJson(json as Map<String, dynamic>);
  }
}
