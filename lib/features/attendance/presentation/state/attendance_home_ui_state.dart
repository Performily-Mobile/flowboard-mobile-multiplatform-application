import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';

/// State of the attendance tab: the employee sees their attendance and the HR staff the sections.
class AttendanceHomeUiState {
  /// Creates the state.
  const AttendanceHomeUiState({required this.role, this.section = AttendanceSection.records});

  final UserRole role;
  final AttendanceSection section;

  /// True when the viewer is from HR and sees the sections.
  bool get showsSections => role == UserRole.humanResources;

  /// Copy with the given values replaced.
  AttendanceHomeUiState copyWith({AttendanceSection? section}) {
    return AttendanceHomeUiState(role: role, section: section ?? this.section);
  }
}
