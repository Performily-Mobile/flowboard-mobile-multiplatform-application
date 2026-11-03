class AttendanceEmployee {
  final int id;
  final String name;
  final String? code;

  const AttendanceEmployee({
    required this.id,
    required this.name,
    this.code,
  });
}