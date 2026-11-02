import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/flowboard_overflow_menu.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/presentation/state/employee_detail_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/contract_assignment_step.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/documents_tab.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/job_assignment_tab.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/message_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/personal_data_tab.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/reassign_job_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/reinstate_employee_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/terminate_employee_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/termination_blocked_dialog.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/upload_document_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/navigation/workspace_navigation.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/employee_detail_view_model.dart';

const List<String> _tabs = <String>['Datos', 'Puesto', 'Expediente', 'Cuenta'];
const int _documentsTab = 2;

/// Record of one employee with tabs for personal data, job, documents and account.
///
/// When the screen is opened from "Reasignar reportes", the reassign sheet opens as soon as the
/// record is loaded.
class EmployeeDetailScreen extends StatefulWidget {
  /// Creates the screen for [employeeId].
  const EmployeeDetailScreen({super.key, required this.employeeId, this.openReassignOnStart = false});

  final int employeeId;
  final bool openReassignOnStart;

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late final EmployeeDetailViewModel _viewModel = getIt<EmployeeDetailViewModel>();
  late final ModalSync<EmployeeAction> _modal =
      ModalSync<EmployeeAction>(open: _openAction, onDismissed: _viewModel.dismissAction);
  bool _reassignHandled = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load(widget.employeeId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final EmployeeDetailUiState state = _viewModel.state;
    if (widget.openReassignOnStart && !_reassignHandled && state.employee != null) {
      _reassignHandled = true;
      scheduleMicrotask(_viewModel.openReassignJob);
    }
    _modal.sync(context, state.activeAction == EmployeeAction.none ? null : state.activeAction);
    final String? message = state.message;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      scheduleMicrotask(_viewModel.consumeMessage);
    }
  }

  Future<void> _openEmployee(int employeeId, {bool openReassign = false}) async {
    await Navigator.of(context).pushNamed(
      WorkspaceRoutes.employeeDetail,
      arguments: EmployeeDetailArgs(employeeId: employeeId, openReassign: openReassign),
    );
  }

  Future<void> _editPersonalData(int employeeId) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      WorkspaceRoutes.editPersonalData,
      arguments: EditPersonalDataArgs(employeeId: employeeId),
    );
    if (mounted) _viewModel.load(widget.employeeId);
  }

  Widget _watch(Widget Function(EmployeeDetailUiState state, Employee employee) builder) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final EmployeeDetailUiState state = _viewModel.state;
        final Employee? employee = state.employee;
        if (employee == null) return const SizedBox.shrink();
        return builder(state, employee);
      },
    );
  }

  Future<void> _openAction(BuildContext context, EmployeeAction action) async {
    switch (action) {
      case EmployeeAction.reassignJob:
        await showGlassBottomSheet<void>(
          context: context,
          builder: (BuildContext sheetContext) => _watch((EmployeeDetailUiState state, Employee employee) {
            return ReassignJobSheet(
              employeeName: employee.name.fullName,
              form: state.reassignJobForm,
              areas: state.areas,
              positions: state.positionsOf(state.reassignJobForm.areaId),
              managerCandidates: state.managerCandidates,
              isSaving: state.isSaving,
              errorMessage: state.actionError,
              onAreaChange: _viewModel.onReassignAreaChange,
              onPositionChange: _viewModel.onReassignPositionChange,
              onManagerChange: _viewModel.onReassignManagerChange,
              onDateChange: _viewModel.onReassignDateChange,
              onSave: _viewModel.saveReassignJob,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case EmployeeAction.terminate:
        await showGlassDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => _watch((EmployeeDetailUiState state, Employee employee) {
            return TerminateEmployeeSheet(
              employeeName: employee.name.fullName,
              form: state.terminationForm,
              isSaving: state.isSaving,
              errorMessage: state.actionError,
              onReasonChange: _viewModel.onTerminationReasonChange,
              onDateChange: _viewModel.onTerminationDateChange,
              onConfirm: _viewModel.saveTermination,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case EmployeeAction.terminationBlocked:
        await showGlassDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) => _watch((EmployeeDetailUiState state, Employee employee) {
            return TerminationBlockedDialog(
              employeeName: employee.name.fullName,
              subordinates: state.subordinates,
              onSubordinateClick: (Employee subordinate) {
                _viewModel.dismissAction();
                _openEmployee(subordinate.id.value);
              },
              onReassignReports: () {
                _viewModel.dismissAction();
                if (state.subordinates.isNotEmpty) {
                  _openEmployee(state.subordinates.first.id.value, openReassign: true);
                }
              },
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case EmployeeAction.reinstate:
        await showGlassBottomSheet<void>(
          context: context,
          builder: (BuildContext sheetContext) => _watch((EmployeeDetailUiState state, Employee employee) {
            return ReinstateEmployeeSheet(
              employeeName: employee.name.fullName,
              form: state.reinstateForm,
              areas: state.areas,
              positions: state.positionsOf(state.reinstateForm.areaId),
              isSaving: state.isSaving,
              errorMessage: state.actionError,
              onAreaChange: _viewModel.onReinstateAreaChange,
              onPositionChange: _viewModel.onReinstatePositionChange,
              onDateChange: _viewModel.onReinstateDateChange,
              onSave: _viewModel.saveReinstate,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case EmployeeAction.uploadDocument:
        await showGlassBottomSheet<void>(
          context: context,
          builder: (BuildContext sheetContext) => _watch((EmployeeDetailUiState state, Employee employee) {
            return UploadDocumentSheet(
              form: state.uploadDocumentForm,
              isSaving: state.isSaving,
              errorMessage: state.actionError,
              onDocumentTypeChange: _viewModel.onUploadDocumentTypeChange,
              onFileSelected: _viewModel.onFileSelected,
              onSave: _viewModel.saveDocument,
              onDismiss: _viewModel.dismissAction,
            );
          }),
        );
      case EmployeeAction.none:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final EmployeeDetailUiState state = _viewModel.state;
          final Employee? employee = state.employee;
          return Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Ficha del colaborador',
                onBack: () => Navigator.of(context).maybePop(),
                actions: <Widget>[
                  if (employee != null) _employeeMenu(employee),
                ],
              ),
              Expanded(child: _buildBody(context, state, employee)),
            ],
          );
        },
      ),
    );
  }

  Widget _employeeMenu(Employee employee) {
    return FlowboardOverflowMenu(
      actions: <FlowboardMenuAction>[
        FlowboardMenuAction(label: 'Editar datos personales', onSelected: () => _editPersonalData(employee.id.value)),
        if (!employee.isTerminated)
          FlowboardMenuAction(label: 'Reasignar puesto', onSelected: _viewModel.openReassignJob),
        FlowboardMenuAction(label: 'Subir documento', onSelected: _viewModel.openUploadDocument),
        if (employee.isTerminated)
          FlowboardMenuAction(label: 'Reincorporar', onSelected: _viewModel.openReinstate)
        else
          FlowboardMenuAction(label: 'Registrar cese', destructive: true, onSelected: _viewModel.openTerminate),
      ],
    );
  }

  Widget _buildBody(BuildContext context, EmployeeDetailUiState state, Employee? employee) {
    if (state.isLoading && employee == null) {
      return const SkeletonDetail();
    }
    if (employee == null) {
      return MessageState(
        title: 'Ficha no disponible',
        message: state.errorMessage ?? 'No se encontró el colaborador.',
        actionLabel: 'Reintentar',
        onAction: () => _viewModel.load(widget.employeeId),
        topPadding: AppSpacing.xl,
      );
    }
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: <Widget>[
        _EmployeeHeader(employee: employee),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: 8),
          child: FlowboardIndexTabs(labels: _tabs, selectedIndex: state.selectedTab, onSelect: _viewModel.onTabSelected),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              8,
              AppSpacing.screenHorizontal,
              AppSpacing.xl + bottomInset,
            ),
            child: switch (state.selectedTab) {
              0 => PersonalDataTab(employee: employee),
              1 => JobAssignmentTab(
                  employee: employee,
                  directManagerName: state.directManagerName,
                  jobAssignments: state.jobAssignments,
                ),
              _documentsTab => DocumentsTab(
                  documents: state.filteredDocuments,
                  selectedCategory: state.documentFilter,
                  onCategoryChange: _viewModel.onDocumentFilterChange,
                  onUploadClick: _viewModel.openUploadDocument,
                ),
              _ => const InfoBanner(
                  text: 'La cuenta de acceso y el rol del colaborador se gestionan en el módulo de identidad (IAM).',
                ),
            },
          ),
        ),
      ],
    );
  }
}

/// Avatar, name, job and status at the top of the record.
class _EmployeeHeader extends StatelessWidget {
  const _EmployeeHeader({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.m),
      child: Row(
        spacing: AppSpacing.l,
        children: <Widget>[
          EmployeeAvatar(initials: employee.name.initials, size: 56),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                Text(
                  employee.name.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  employee.jobDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                StatusChip(status: employee.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
