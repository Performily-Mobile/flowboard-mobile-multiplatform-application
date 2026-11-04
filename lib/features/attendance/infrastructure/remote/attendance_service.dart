import 'package:flowboard/core/network/api_client.dart';

class AttendanceService {
  const AttendanceService({required this.client});

  final ApiClient client;

  String date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<dynamic>> myRecords(
          int id, DateTime from, DateTime to) async =>
      (await client.get('attendance/me', query: {
        'employeeId': id,
        'from': date(from),
        'to': date(to),
      })) as List<dynamic>;

  Future<List<dynamic>> employeeRecords(
          int id, DateTime from, DateTime to) async =>
      (await client.get('attendance/employees/$id', query: {
        'from': date(from),
        'to': date(to),
      })) as List<dynamic>;

  Future<List<dynamic>> areaRecords(int id, DateTime day) async =>
      (await client.get('attendance/areas/$id', query: {
        'workDate': date(day),
      })) as List<dynamic>;

  Future<Map<String, dynamic>> employeeHours(
          int id, DateTime from, DateTime to) async =>
      (await client.get('attendance/reports/employees/$id/hours', query: {
        'from': date(from),
        'to': date(to),
      })) as Map<String, dynamic>;

  Future<Map<String, dynamic>> areaSummary(
          int id, DateTime from, DateTime to) async =>
      (await client.get('attendance/reports/areas/$id', query: {
        'from': date(from),
        'to': date(to),
      })) as Map<String, dynamic>;

  Future<int> punch(int id, String type) async {
    final dynamic value = await client.post('attendance/punches', body: {
      'employeeId': id,
      'type': type,
      'punchedAt': DateTime.now().toUtc().toIso8601String(),
    });
    return value is num ? value.toInt() : int.parse('$value');
  }

  Future<Map<String, dynamic>> justify(
          int id, String reason, String? url) async =>
      (await client.post('attendance/$id/justification', body: {
        'reason': reason,
        'evidenceUrl': url,
      })) as Map<String, dynamic>;

  Future<List<dynamic>> areas() async =>
      (await client.get('areas')) as List<dynamic>;

  Future<List<dynamic>> employees(String q) async =>
      (await client.get('employees', query: {
        'search': q,
        'status': 'ACTIVE',
      })) as List<dynamic>;
}