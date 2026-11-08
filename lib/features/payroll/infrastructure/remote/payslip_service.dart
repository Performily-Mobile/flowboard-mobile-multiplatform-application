import 'package:flowboard/core/network/api_client.dart';
import 'package:flowboard/features/payroll/infrastructure/remote/payslip_dto.dart';

/// Endpoints of /payslips: HR management (US43-US46) and the payslips of the employee (US41, US42).
class PayslipService {
  /// Creates the service.
  const PayslipService({required this.client});

  final ApiClient client;

  /// Header the backend reads to know which employee asks (temporary until IAM).
  static const String _employeeHeader = 'X-Employee-Id';

  /// GET payslips?payrollPeriodId=.
  Future<List<PayslipDto>> getPayslipsByPayrollPeriod(int payrollPeriodId) async {
    final List<dynamic> json =
        await client.get('payslips', query: <String, dynamic>{'payrollPeriodId': payrollPeriodId}) as List<dynamic>;
    return json.map((dynamic item) => PayslipDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// POST payslips.
  Future<PayslipDto> uploadPayslip(PayslipFileRequestDto request) async {
    final Object? json = await client.post('payslips', body: request.toJson());
    return PayslipDto.fromJson(json as Map<String, dynamic>);
  }

  /// PUT payslips/{payslipId}/file.
  Future<PayslipDto> replacePayslipFile(int payslipId, PayslipFileRequestDto request) async {
    final Object? json = await client.put('payslips/$payslipId/file', body: request.toJson());
    return PayslipDto.fromJson(json as Map<String, dynamic>);
  }

  /// PATCH payslips/{payslipId}/mark-as-paid.
  Future<PayslipDto> markAsPaid(int payslipId, String paidOn) async {
    final Object? json = await client.patch('payslips/$payslipId/mark-as-paid', body: <String, dynamic>{'paidOn': paidOn});
    return PayslipDto.fromJson(json as Map<String, dynamic>);
  }

  /// PATCH payslips/{payslipId}/mark-as-observed.
  Future<PayslipDto> markAsObserved(int payslipId, String reason) async {
    final Object? json =
        await client.patch('payslips/$payslipId/mark-as-observed', body: <String, dynamic>{'reason': reason});
    return PayslipDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET payslips/me?year=.
  Future<List<PayslipDto>> getMyPayslips(int employeeId, int year) async {
    final List<dynamic> json = await client.get(
      'payslips/me',
      query: <String, dynamic>{'year': year},
      headers: <String, String>{_employeeHeader: '$employeeId'},
    ) as List<dynamic>;
    return json.map((dynamic item) => PayslipDto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// GET payslips/me/{payslipId}.
  Future<PayslipDetailDto> getMyPayslip(int employeeId, int payslipId) async {
    final Object? json =
        await client.get('payslips/me/$payslipId', headers: <String, String>{_employeeHeader: '$employeeId'});
    return PayslipDetailDto.fromJson(json as Map<String, dynamic>);
  }

  /// GET payslips/me/{payslipId}/download-url.
  Future<PayslipDownloadUrlDto> getMyPayslipDownloadUrl(int employeeId, int payslipId) async {
    final Object? json = await client.get(
      'payslips/me/$payslipId/download-url',
      headers: <String, String>{_employeeHeader: '$employeeId'},
    );
    return PayslipDownloadUrlDto.fromJson(json as Map<String, dynamic>);
  }
}
