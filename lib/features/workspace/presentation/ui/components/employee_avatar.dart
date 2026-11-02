import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';

/// Round avatar with the initials of an employee.
class EmployeeAvatar extends StatelessWidget {
  /// Creates the avatar with the [initials] and its [size].
  const EmployeeAvatar({super.key, required this.initials, this.size = 40});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.avatarContainer,
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.onAvatarContainer,
            fontWeight: FontWeight.w600,
            fontSize: size > 48 ? 20 : 14,
          ),
        ),
      ),
    );
  }
}
