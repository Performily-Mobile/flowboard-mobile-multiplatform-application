import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_type_mapper.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_type_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_type_service.dart';

/// Request types read from and written to the Flowboard API.
class RequestTypeRepositoryImpl implements RequestTypeRepository {
  /// Creates the repository.
  const RequestTypeRepositoryImpl({required this.service});

  final RequestTypeService service;

  @override
  Future<List<RequestType>> getRequestTypes({bool activeOnly = false}) async {
    final List<RequestTypeDto> dtos = await service.getRequestTypes(activeOnly: activeOnly);
    return dtos.map(RequestTypeMapper.toDomain).toList();
  }

  @override
  Future<RequestType> createRequestType({
    required String name,
    required String? description,
    required bool requiresAttachment,
    required BalanceDeduction balanceDeduction,
    required List<NewRequestField> fields,
  }) async {
    return RequestTypeMapper.toDomain(await service.createRequestType(RequestTypeMapper.toCreateRequest(
      name: name,
      description: description,
      requiresAttachment: requiresAttachment,
      balanceDeduction: balanceDeduction,
      fields: fields,
    )));
  }

  @override
  Future<RequestType> activate(int requestTypeId) async {
    return RequestTypeMapper.toDomain(await service.activate(requestTypeId));
  }

  @override
  Future<RequestType> deactivate(int requestTypeId) async {
    return RequestTypeMapper.toDomain(await service.deactivate(requestTypeId));
  }

  @override
  Future<void> delete(int requestTypeId) => service.delete(requestTypeId);
}
