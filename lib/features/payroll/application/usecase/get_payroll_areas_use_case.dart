import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/repository/payroll_employee_directory.dart';

/// Active areas for the filter of the payment report, in alphabetical order.
class GetPayrollAreasUseCase {
  /// Creates the use case.
  const GetPayrollAreasUseCase({required this.directory});

  final PayrollEmployeeDirectory directory;

  /// Active areas sorted by name.
  Future<List<PayrollArea>> execute() async {
    final List<PayrollArea> areas = await directory.getAreas();
    return areas.where((PayrollArea area) => area.active).toList()
      ..sort((PayrollArea a, PayrollArea b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
