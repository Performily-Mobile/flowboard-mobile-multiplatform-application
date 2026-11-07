import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/assignment_batch.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/domain/repository/benefit_assignment_repository.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_target.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/benefits_enum_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/benefits_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_assignment_dto.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_service.dart';

/// Benefit assignments read from and written to the Flowboard API.
class BenefitAssignmentRepositoryImpl implements BenefitAssignmentRepository {
  /// Creates the repository.
  const BenefitAssignmentRepositoryImpl({required this.service});

  final BenefitService service;

  @override
  Future<List<BenefitAssignment>> getAssignments(AssignmentStatus? status) async {
    final List<BenefitAssignmentDto> dtos = await service.getAssignments(status: BenefitsMapper.statusParam(status));
    return dtos.map(BenefitsMapper.toAssignment).toList();
  }

  @override
  Future<EmployeeBenefits> getEmployeeBenefits(int employeeId) async {
    return BenefitsMapper.toEmployeeBenefits(await service.getMyBenefits(employeeId));
  }

  @override
  Future<AreaAssignmentPreview> previewAreaAssignment(
    int benefitTypeId,
    int areaId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final AreaAssignmentPreviewDto dto = await service.previewAreaAssignment(
      benefitTypeId,
      areaId,
      BenefitsEnumMapper.isoDate(startDate),
      BenefitsEnumMapper.isoDate(endDate),
    );
    return BenefitsMapper.toPreview(dto);
  }

  @override
  Future<AssignmentBatch> assign(
    int benefitTypeId,
    AssignmentTarget target,
    double quantity,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final AssignBenefitRequestDto request =
        BenefitsMapper.toAssignRequest(benefitTypeId, target, quantity, startDate, endDate);
    return BenefitsMapper.toBatch(await service.assign(request));
  }

  @override
  Future<BenefitAssignment> registerDelivery(
    int assignmentId,
    DateTime deliveredOn,
    int registeredById,
    String? notes,
  ) async {
    final RegisterDeliveryRequestDto request = BenefitsMapper.toDeliveryRequest(deliveredOn, registeredById, notes);
    return BenefitsMapper.toAssignment(await service.registerDelivery(assignmentId, request));
  }
}
