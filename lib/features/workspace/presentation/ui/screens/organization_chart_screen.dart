import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart.dart';
import 'package:flowboard/features/workspace/domain/valueobject/organization_chart_node.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_chart_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/area_dropdown.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/detail_row.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/organization_chart_node_item.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/organization_chart_view_model.dart';

/// Organization chart of the whole company or of one area.
///
/// [areaId] is the area shown first (null for the whole organization) and
/// [highlightedEmployeeId] the employee to highlight, usually the current user.
class OrganizationChartScreen extends StatefulWidget {
  /// Creates the screen.
  const OrganizationChartScreen({super.key, this.areaId, this.highlightedEmployeeId});

  final int? areaId;
  final int? highlightedEmployeeId;

  @override
  State<OrganizationChartScreen> createState() => _OrganizationChartScreenState();
}

class _OrganizationChartScreenState extends State<OrganizationChartScreen> {
  late final OrganizationChartViewModel _viewModel = getIt<OrganizationChartViewModel>();

  static const List<OrganizationChartMode> _modes = <OrganizationChartMode>[
    OrganizationChartMode.wholeOrganization,
    OrganizationChartMode.byArea,
  ];

  @override
  void initState() {
    super.initState();
    _viewModel.initialize(widget.areaId, widget.highlightedEmployeeId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final OrganizationChartUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Organigrama', onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    8,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl + bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.itemGap,
                    children: <Widget>[
                      FlowboardTabs<OrganizationChartMode>(
                        options: _modes,
                        selected: state.mode,
                        onSelect: _viewModel.onModeChange,
                        labelOf: (OrganizationChartMode mode) =>
                            mode == OrganizationChartMode.wholeOrganization ? 'Toda la organización' : 'Por área',
                      ),
                      if (state.mode == OrganizationChartMode.byArea)
                        AreaDropdown(
                          areas: state.areas,
                          selectedAreaId: state.selectedAreaId,
                          onSelect: (Area area) => _viewModel.onAreaSelected(area.id),
                        ),
                      ..._chartContent(context, state),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _chartContent(BuildContext context, OrganizationChartUiState state) {
    final ThemeData theme = Theme.of(context);
    final OrganizationChart? chart = state.chart;
    if (state.isLoading && chart == null) {
      return const <Widget>[
        SkeletonList(itemCount: 5, inline: true, padding: EdgeInsets.zero, showTrailing: false),
      ];
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return <Widget>[
        Text(errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: _viewModel.loadChart, child: const Text('Reintentar')),
        ),
      ];
    }
    if (chart == null || chart.isEmpty) {
      return <Widget>[
        Text(
          'No hay colaboradores activos para mostrar.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ];
    }
    return <Widget>[
      for (final OrganizationChartNode node in chart.nodes)
        OrganizationChartNodeItem(node: node, highlightedEmployeeId: state.highlightedEmployeeId),
      if (chart.pendingReassignment.isNotEmpty) ...<Widget>[
        const SectionTitle('Pendientes de reasignación'),
        for (final OrganizationChartNode node in chart.pendingReassignment) PendingNodeCard(node: node),
      ],
      Text(
        'Los colaboradores sin jefe directo aparecen en el primer nivel.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    ];
  }
}
