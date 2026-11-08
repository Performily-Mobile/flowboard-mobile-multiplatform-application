/// Area of the organization, used only to filter the payment report. It comes from Workspace.
class PayrollArea {
  /// Creates the area.
  const PayrollArea({required this.id, required this.name, required this.active});

  final int id;
  final String name;
  final bool active;

  @override
  bool operator ==(Object other) => other is PayrollArea && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
