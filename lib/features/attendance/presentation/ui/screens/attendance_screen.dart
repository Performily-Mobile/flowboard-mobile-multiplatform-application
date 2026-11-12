import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_home_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_area_view.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/attendance_records_view.dart';
import 'package:flowboard/features/attendance/presentation/ui/screens/my_attendance_view.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_home_view_model.dart';

/// "Asistencia" tab. The employee sees their own attendance; the HR staff see the sections of the
/// whole staff, chosen with the tabs at the top of the header.
///
/// A section is built the first time it is shown and kept while the tab is open, so going back to
/// it does not load it again.
class AttendanceScreen extends StatefulWidget {
  /// Creates the screen.
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const List<AttendanceSection> _sections = <AttendanceSection>[
    AttendanceSection.records,
    AttendanceSection.areas,
  ];

  late final AttendanceHomeViewModel _viewModel = getIt<AttendanceHomeViewModel>();
  final Set<AttendanceSection> _visited = <AttendanceSection>{};

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AttendanceHomeUiState state = _viewModel.state;
        return Scaffold(
          body: Column(
            children: <Widget>[
              const FlowboardTopBar(title: 'Asistencia'),
              Expanded(child: state.showsSections ? _buildSections(state) : const MyAttendanceView()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSections(AttendanceHomeUiState state) {
    _visited.add(state.section);
    final Widget? tabs = _sections.length < 2
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: FlowboardTabs<AttendanceSection>(
              options: _sections,
              selected: state.section,
              onSelect: _viewModel.onSectionSelected,
              labelOf: (AttendanceSection section) => section.label,
            ),
          );
    return IndexedStack(
      index: _sections.indexOf(state.section),
      children: <Widget>[
        for (final AttendanceSection section in _sections)
          _visited.contains(section) ? _sectionView(section, tabs) : const SizedBox.shrink(),
      ],
    );
  }

  Widget _sectionView(AttendanceSection section, Widget? tabs) {
    return switch (section) {
      AttendanceSection.records => AttendanceRecordsView(leading: tabs),
      AttendanceSection.areas => AttendanceAreaView(leading: tabs),
      AttendanceSection.hours => const SizedBox.shrink(),
    };
  }
}
