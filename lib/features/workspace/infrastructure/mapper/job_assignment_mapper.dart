import 'package:flowboard/features/workspace/domain/entity/job_assignment.dart';
import 'package:flowboard/features/workspace/domain/valueobject/assignment_change_type.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/iso_date_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/mapper/workspace_enum_mapper.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/assign_job_request_dto.dart';
import 'package:flowboard/features/workspace/infrastructure/remote/job_assignment_dto.dart';

/// Translates the job history between the API and the domain.
class JobAssignmentMapper {
  const JobAssignmentMapper._();

  /// Domain entry of [dto].
  static JobAssignment toDomain(JobAssignmentDto dto) {
    return JobAssignment(
      id: dto.id,
      areaId: dto.areaId,
      areaName: dto.areaName ?? '',
      positionId: dto.positionId,
      positionTitle: dto.positionTitle ?? '',
      changeType: WorkspaceEnumMapper.fromApi(AssignmentChangeType.values, dto.changeType),
      startDate: IsoDateMapper.parseDate(dto.startDate),
      endDate: dto.endDate == null ? null : IsoDateMapper.parseDate(dto.endDate!),
      current: dto.current,
    );
  }

  /// Body to assign a new job.
  static AssignJobRequestDto toAssignRequest(int areaId, int positionId, DateTime effectiveDate) {
    return AssignJobRequestDto(
      areaId: areaId,
      positionId: positionId,
      effectiveDate: IsoDateMapper.format(effectiveDate),
    );
  }
}
