import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';

/// Repository of the request types.
abstract class RequestTypeRepository {
  /// Request types; only the active ones when [activeOnly] is true.
  Future<List<RequestType>> getRequestTypes({bool activeOnly = false});

  /// Creates a request type with its fields.
  Future<RequestType> createRequestType({
    required String name,
    required String? description,
    required bool requiresAttachment,
    required BalanceDeduction balanceDeduction,
    required List<NewRequestField> fields,
  });

  /// Activates the request type.
  Future<RequestType> activate(int requestTypeId);

  /// Deactivates the request type.
  Future<RequestType> deactivate(int requestTypeId);

  /// Deletes the request type; only works when nobody used it.
  Future<void> delete(int requestTypeId);
}
