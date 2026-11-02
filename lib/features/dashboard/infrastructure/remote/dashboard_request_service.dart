import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/dashboard/infrastructure/remote/dashboard_request_dto.dart';

/// Requests waiting for approval, read from the Request backend.
class DashboardRequestService {
  /// Creates the service.
  const DashboardRequestService({required this.client});

  final ApiClient client;

  /// GET requests/pending-approval/hr-staff.
  Future<List<DashboardRequestDto>> getPendingForHrStaff() async {
    return _list(await client.get('requests/pending-approval/hr-staff'));
  }

  /// GET requests/pending-approval for the requests a direct manager must approve.
  Future<List<DashboardRequestDto>> getPendingForApprover(int approverId) async {
    return _list(await client.get('requests/pending-approval', query: <String, dynamic>{'approverId': approverId}));
  }

  List<DashboardRequestDto> _list(dynamic json) {
    return (json as List<dynamic>)
        .map((dynamic item) => DashboardRequestDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
