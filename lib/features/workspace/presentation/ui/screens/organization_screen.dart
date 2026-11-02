import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/presentation/state/organization_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/areas_tab.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_position_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/deactivate_area_dialog.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/positions_tab.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/organization_view_model.dart';

/// Sheet open on the organization screen.
enum _OrganizationSheet { area, position }

/// Areas and positions of the organization, in two tabs, with sheets to create them.
class OrganizationScreen extends StatefulWidget {
  /// Creates the screen.
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  late final OrganizationViewModel _viewModel = getIt<OrganizationViewModel>();
  late final ModalSync<_OrganizationSheet> _sheet =
      ModalSync<_OrganizationSheet>(open: _openSheet, onDismissed: _viewModel.dismissSheets);
  late final ModalSync<Area> _deactivateDialog =
      ModalSync<Area>(open: _openDeactivateDialog, onDismissed: _viewModel.dismissDeactivateArea);
  bool _fabExpanded = true;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final OrganizationUiState state = _viewModel.state;
    _sheet.sync(
      context,
      state.isAreaSheetVisible
          ? _OrganizationSheet.area
          : state.isPositionSheetVisible
              ? _OrganizationSheet.position
              : null,
    );
    _deactivateDialog.sync(context, state.areaToDeactivate);
  }

  Future<void> _openSheet(BuildContext context, _OrganizationSheet sheet) async {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final OrganizationUiState state = _viewModel.state;
          return switch (sheet) {
            _OrganizationSheet.area => CreateAreaSheet(
                form: state.areaForm,
                isSaving: state.isSaving,
                onNameChange: _viewModel.onAreaNameChange,
                onDescriptionChange: _viewModel.onAreaDescriptionChange,
                onSave: _viewModel.saveArea,
                onDismiss: _viewModel.dismissSheets,
              ),
            _OrganizationSheet.position => CreatePositionSheet(
                form: state.positionForm,
                areas: state.activeAreas,
                isSaving: state.isSaving,
                onAreaChange: _viewModel.onPositionAreaChange,
                onTitleChange: _viewModel.onPositionTitleChange,
                onSalaryChange: _viewModel.onPositionSalaryChange,
                onSave: _viewModel.savePosition,
                onDismiss: _viewModel.dismissSheets,
              ),
          };
        },
      ),
    );
  }

  Future<void> _openDeactivateDialog(BuildContext context, Area area) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final OrganizationUiState state = _viewModel.state;
          return DeactivateAreaDialog(
            area: area,
            confirmed: state.deactivationConfirmed,
            isSaving: state.isSaving,
            errorMessage: state.deactivationError,
            onConfirmedChange: _viewModel.onDeactivationConfirmedChange,
            onConfirm: _viewModel.confirmDeactivateArea,
            onDismiss: _viewModel.dismissDeactivateArea,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final OrganizationUiState state = _viewModel.state;
        final bool areasTab = state.selectedTab == 0;
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: areasTab ? _viewModel.showAreaSheet : _viewModel.showPositionSheet,
            isExtended: _fabExpanded,
            tooltip: areasTab ? 'Nueva área' : 'Nueva posición',
            icon: const Icon(FlowboardIcons.add),
            label: Text(areasTab ? 'Nueva área' : 'Nueva posición'),
          ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Organización', onBack: navigator.canPop() ? () => navigator.maybePop() : null),
              Expanded(
                child: CollapsingHeaderLayout(
                  showHeaderKey: Object.hash(state.selectedTab, state.areas.length, state.positions.length),
                  onHeaderVisibilityChanged: (bool visible) => setState(() => _fabExpanded = visible),
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.s,
                      children: <Widget>[
                        FlowboardIndexTabs(
                          labels: const <String>['Áreas', 'Posiciones'],
                          selectedIndex: state.selectedTab,
                          onSelect: _viewModel.onTabSelected,
                        ),
                        if (state.errorMessage != null)
                          Text(
                            state.errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                      ],
                    ),
                  ),
                  contentBuilder: (BuildContext context, EdgeInsets contentPadding) {
                    if (state.isLoading && state.areas.isEmpty && state.positions.isEmpty) {
                      return SkeletonList(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          contentPadding.top + 4,
                          AppSpacing.screenHorizontal,
                          0,
                        ),
                        showAvatar: false,
                      );
                    }
                    final EdgeInsets listPadding = EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      contentPadding.top + 4,
                      AppSpacing.screenHorizontal,
                      AppSpacing.fabClearance + MediaQuery.paddingOf(context).bottom,
                    );
                    return areasTab
                        ? AreasTab(
                            areas: state.areas,
                            onDeactivateClick: _viewModel.requestDeactivateArea,
                            padding: listPadding,
                          )
                        : PositionsTab(positions: state.positions, padding: listPadding);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
