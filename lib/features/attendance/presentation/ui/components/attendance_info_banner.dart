import 'package:flutter/material.dart';

class AttendanceInfoBanner extends StatelessWidget {
  const AttendanceInfoBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(message),
        ),
      );
}