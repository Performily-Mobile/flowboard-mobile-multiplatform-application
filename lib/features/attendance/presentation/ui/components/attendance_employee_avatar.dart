import 'package:flutter/material.dart';

class AttendanceEmployeeAvatar extends StatelessWidget {
  const AttendanceEmployeeAvatar({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        child: Text(
          name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase(),
        ),
      );
}