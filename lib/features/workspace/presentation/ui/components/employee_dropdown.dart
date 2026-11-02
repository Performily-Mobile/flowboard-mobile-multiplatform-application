import 'package:flutter/widgets.dart';
import 'package:flowboard/core/domain/employee_id.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';

/// Field to choose an employee, with a first option "Sin jefe directo".
class EmployeeDropdown extends StatelessWidget {
  /// Creates the field.
  const EmployeeDropdown({
    super.key,
    required this.label,
    required this.employees,
    required this.selectedEmployeeId,
    required this.onSelect,
    this.isError = false,
    this.supportingText,
  });

  final String label;
  final List<Employee> employees;
  final EmployeeId? selectedEmployeeId;
  final ValueChanged<Employee?> onSelect;
  final bool isError;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    Employee? selected;
    for (final Employee employee in employees) {
      if (employee.id == selectedEmployeeId) selected = employee;
    }
    return SelectField<Employee?>(
      label: label,
      options: <Employee?>[null, ...employees],
      selected: selected,
      optionLabel: (Employee? employee) => employee?.name.fullName ?? 'Sin jefe directo',
      onSelect: onSelect,
      isError: isError,
      supportingText: supportingText,
    );
  }
}
