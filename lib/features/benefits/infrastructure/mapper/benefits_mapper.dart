import 'package:flowboard/features/benefits/domain/entity/area_assignment_preview.dart';
import 'package:flowboard/features/benefits/domain/entity/assignment_batch.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_assignment.dart';
import 'package:flowboard/features/benefits/domain/entity/benefit_type.dart';
import 'package:flowboard/features/benefits/domain/entity/employee_benefits.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_status.dart';
import 'package:flowboard/features/benefits/domain/valueobject/assignment_target.dart';
import 'package:flowboard/features/benefits/domain/valueobject/benefit_unit.dart';
import 'package:flowboard/features/benefits/infrastructure/mapper/benefits_enum_mapper.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_assignment_dto.dart';
import 'package:flowboard/features/benefits/infrastructure/remote/benefit_type_dto.dart';

/// Translates the benefit DTOs to domain entities and builds the requests.
class BenefitsMapper {
  const BenefitsMapper._();

  /// Domain benefit type of [dto].
  static BenefitType toBenefitType(BenefitTypeDto dto) {
    return BenefitType(
      id: dto.id,
      name: dto.name,
      description: _blankToNull(dto.description),
      unit: BenefitsEnumMapper.unit(dto.unit),
      hasBalance: dto.hasBalance,
      active: dto.active,
    );
  }

  /// Body to create a benefit type.
  static CreateBenefitTypeRequestDto toCreateRequest(
    String name,
    String? description,
    BenefitUnit unit,
    bool hasBalance,
  ) {
    return CreateBenefitTypeRequestDto(
      name: name,
      description: description,
      hasBalance: hasBalance,
      unit: BenefitsEnumMapper.toApi(unit),
    );
  }

  /// Domain assignment of [dto]; a missing employee name becomes "Colaborador #id".
  static BenefitAssignment toAssignment(BenefitAssignmentDto dto) {
    final BenefitDeliveryDto? delivery = dto.delivery;
    return BenefitAssignment(
      id: dto.id,
      benefitTypeId: dto.benefitTypeId,
      benefitTypeName: dto.benefitTypeName ?? '',
      unit: BenefitsEnumMapper.unit(dto.unit),
      employeeId: dto.employeeId,
      employeeName: _blankToNull(dto.employeeName) ?? 'Colaborador #${dto.employeeId}',
      sourceAreaId: dto.sourceAreaId,
      quantity: dto.quantity,
      startDate: _requiredDate(dto.startDate),
      endDate: _requiredDate(dto.endDate),
      status: BenefitsEnumMapper.status(dto.status),
      delivery: delivery == null
          ? null
          : BenefitDelivery(
              deliveredOn: _requiredDate(delivery.deliveredOn),
              registeredById: delivery.registeredById,
              notes: _blankToNull(delivery.notes),
            ),
    );
  }

  /// Domain benefits of an employee.
  static EmployeeBenefits toEmployeeBenefits(EmployeeBenefitsDto dto) {
    return EmployeeBenefits(
      employeeId: dto.employeeId,
      current: dto.current.map(toAssignment).toList(),
      delivered: dto.delivered.map(toAssignment).toList(),
    );
  }

  /// Domain preview of an area assignment.
  static AreaAssignmentPreview toPreview(AreaAssignmentPreviewDto dto) {
    return AreaAssignmentPreview(
      areaId: dto.areaId,
      activeEmployees: dto.activeEmployees,
      alreadyAssigned: dto.alreadyAssigned,
      toAssign: dto.toAssign,
    );
  }

  /// Domain result of an assignment.
  static AssignmentBatch toBatch(BenefitAssignmentBatchDto dto) {
    return AssignmentBatch(
      areaId: dto.areaId,
      assignedCount: dto.assignedCount,
      skippedCount: dto.skippedCount,
      assignments: dto.assignments.map(toAssignment).toList(),
    );
  }

  /// Body to assign a benefit to the [target].
  static AssignBenefitRequestDto toAssignRequest(
    int benefitTypeId,
    AssignmentTarget target,
    double quantity,
    DateTime startDate,
    DateTime endDate,
  ) {
    return AssignBenefitRequestDto(
      benefitTypeId: benefitTypeId,
      employeeId: switch (target) {
        EmployeeTarget(:final int employeeId) => employeeId,
        AreaTarget() => null,
      },
      areaId: switch (target) {
        AreaTarget(:final int areaId) => areaId,
        EmployeeTarget() => null,
      },
      quantity: quantity,
      startDate: BenefitsEnumMapper.isoDate(startDate),
      endDate: BenefitsEnumMapper.isoDate(endDate),
    );
  }

  /// Body to register a delivery.
  static RegisterDeliveryRequestDto toDeliveryRequest(DateTime deliveredOn, int registeredById, String? notes) {
    return RegisterDeliveryRequestDto(
      deliveredOn: BenefitsEnumMapper.isoDate(deliveredOn),
      registeredById: registeredById,
      notes: notes,
    );
  }

  /// Query value of the status filter, or null for all the assignments.
  static String? statusParam(AssignmentStatus? status) => status == null ? null : BenefitsEnumMapper.toApi(status);

  static String? _blankToNull(String? value) => value == null || value.trim().isEmpty ? null : value;

  static DateTime _requiredDate(String value) {
    final DateTime? date = BenefitsEnumMapper.date(value);
    if (date == null) throw FormatException('Fecha inválida: $value');
    return date;
  }
}
