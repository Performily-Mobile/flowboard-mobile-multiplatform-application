import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/infrastructure/mapper/request_enum_mapper.dart';
import 'package:flowboard/features/request/infrastructure/remote/create_request_type_request_dto.dart';
import 'package:flowboard/features/request/infrastructure/remote/request_type_dto.dart';

/// Translates the request types between the API and the domain.
class RequestTypeMapper {
  const RequestTypeMapper._();

  /// Domain request type of [dto], with its fields in display order.
  static RequestType toDomain(RequestTypeDto dto) {
    final String? description = dto.description;
    final List<RequestField> fields = dto.fields
        .map((RequestFieldDto field) => RequestField(
              id: field.id,
              key: field.key,
              label: field.label,
              dataType: RequestEnumMapper.fromApi(FieldDataType.values, field.dataType, FieldDataType.text),
              isRequired: field.isRequired,
              displayOrder: field.displayOrder,
            ))
        .toList()
      ..sort((RequestField a, RequestField b) => a.displayOrder.compareTo(b.displayOrder));
    return RequestType(
      id: dto.id,
      name: dto.name,
      description: description == null || description.trim().isEmpty ? null : description,
      requiresAttachment: dto.requiresAttachment,
      balanceDeduction:
          RequestEnumMapper.fromApi(BalanceDeduction.values, dto.balanceDeduction, BalanceDeduction.none),
      active: dto.active,
      fields: fields,
    );
  }

  /// Body to create a request type; the fields keep the order in which they were added.
  static CreateRequestTypeRequestDto toCreateRequest({
    required String name,
    required String? description,
    required bool requiresAttachment,
    required BalanceDeduction balanceDeduction,
    required List<NewRequestField> fields,
  }) {
    return CreateRequestTypeRequestDto(
      name: name,
      description: description,
      requiresAttachment: requiresAttachment,
      balanceDeduction: RequestEnumMapper.toApi(balanceDeduction),
      fields: <CreateRequestFieldRequestDto>[
        for (int i = 0; i < fields.length; i++)
          CreateRequestFieldRequestDto(
            key: fields[i].key,
            label: fields[i].label,
            dataType: RequestEnumMapper.toApi(fields[i].dataType),
            isRequired: fields[i].isRequired,
            displayOrder: i + 1,
          ),
      ],
    );
  }
}
