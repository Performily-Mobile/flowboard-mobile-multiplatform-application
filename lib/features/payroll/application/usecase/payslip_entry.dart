import 'package:flowboard/features/payroll/domain/entity/payroll_employee.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';

/// A payslip together with its employee (from Workspace), for the HR lists.
class PayslipEntry {
  /// Creates the entry; [employee] is null when Workspace did not return it.
  const PayslipEntry({required this.payslip, required this.employee});

  final Payslip payslip;
  final PayrollEmployee? employee;

  /// Full name of the employee, for example "Pedro Huamán Quispe".
  ///
  /// Falls back to the name sent with the payslip and then to "Colaborador 12" when Workspace did
  /// not return the employee.
  String get fullName {
    final String? fromWorkspace = employee?.fullName;
    if (fromWorkspace != null && fromWorkspace.trim().isNotEmpty) return fromWorkspace;
    final String? fromPayslip = payslip.employeeName?.trim();
    if (fromPayslip != null && fromPayslip.isNotEmpty) return fromPayslip;
    return 'Colaborador ${payslip.employeeId.value}';
  }

  /// Name shown in the lists, last name first: "Huamán Quispe, Pedro".
  String get listName {
    final String? sortable = employee?.sortableName;
    return sortable != null && sortable.trim().isNotEmpty ? sortable : fullName;
  }

  /// Initials of the avatar: "PH", or "#" when there is no name.
  String get initials {
    final String? fromWorkspace = employee?.initials;
    if (fromWorkspace != null && fromWorkspace.isNotEmpty) return fromWorkspace;
    final String letters = (payslip.employeeName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .take(2)
        .map((String word) => word[0])
        .join()
        .toUpperCase();
    return letters.isEmpty ? '#' : letters;
  }

  /// Key used to sort the lists alphabetically by last name.
  String get sortKey => (employee?.sortableName ?? payslip.employeeName ?? '').toLowerCase();
}

/// Sorts [entries] alphabetically by last name.
List<PayslipEntry> sortEntries(Iterable<PayslipEntry> entries) =>
    entries.toList()..sort((PayslipEntry a, PayslipEntry b) => a.sortKey.compareTo(b.sortKey));
