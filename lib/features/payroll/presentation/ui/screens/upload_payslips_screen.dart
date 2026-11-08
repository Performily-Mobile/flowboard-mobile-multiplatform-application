import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_search_field.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/payroll/application/usecase/payslip_entry.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_area.dart';
import 'package:flowboard/features/payroll/domain/entity/payroll_period.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payment_sheet_form.dart';
import 'package:flowboard/features/payroll/presentation/state/upload_payslips_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_common.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_dialogs.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_fields.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_glass.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payslip_upload_zone.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/upload_payslips_view_model.dart';

/// "Boletas y pagos" of HR (MA-67, MA-68, MA-69).
///
/// Each payslip of the period shows its payment status (Pendiente, Pagado, Observado) or
/// "Por publicar"; tapping a published one opens the sheet to register its deposit. The period,
/// the search and the filters slide away while scrolling, as in the list of employees of Workspace.
/// Uploading and publishing payslips stay inside a section that is closed until HR opens it.
class UploadPayslipsScreen extends StatefulWidget {
  /// Creates the screen.
  const UploadPayslipsScreen({super.key});

  @override
  State<UploadPayslipsScreen> createState() => _UploadPayslipsScreenState();
}

class _UploadPayslipsScreenState extends State<UploadPayslipsScreen> {
  late final UploadPayslipsViewModel _viewModel = getIt<UploadPayslipsViewModel>();
  late final ModalSync<DuplicatePrompt> _duplicateDialog =
      ModalSync<DuplicatePrompt>(open: _openDuplicateDialog, onDismissed: _viewModel.onReplaceCancelled);
  late final ModalSync<PayslipEntry> _paymentSheet =
      ModalSync<PayslipEntry>(open: _openPaymentSheet, onDismissed: _viewModel.dismissSheet);

  /// Whether HR opened the "Cargar y publicar boletas" section.
  bool _uploadSectionOpen = false;

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
    final UploadPayslipsUiState state = _viewModel.state;
    _duplicateDialog.sync(context, state.duplicate);
    _paymentSheet.sync(context, state.sheet?.entry);
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _viewModel.onSnackbarShown();
    }
  }

  Future<void> _openDuplicateDialog(BuildContext context, DuplicatePrompt prompt) async {
    await showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => DuplicatePayslipDialog(
        prompt: prompt,
        onReplace: _viewModel.onReplaceConfirmed,
        onCancel: _viewModel.onReplaceCancelled,
      ),
    );
  }

  Future<void> _openPaymentSheet(BuildContext context, PayslipEntry entry) async {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final PaymentSheetForm? form = _viewModel.state.sheet;
          if (form == null) return const SizedBox.shrink();
          return UpdatePaymentStatusSheet(
            form: form,
            onChoiceChange: _viewModel.onSheetChoiceChange,
            onPaidOnChange: _viewModel.onSheetPaidOnChange,
            onReasonChange: _viewModel.onSheetReasonChange,
            onSave: _viewModel.saveSheet,
            onDismiss: _viewModel.dismissSheet,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final UploadPayslipsUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Boletas y pagos',
                onBack: navigator.canPop() ? () => navigator.maybePop() : null,
              ),
              Expanded(
                child: CollapsingHeaderLayout(
                  showHeaderKey: Object.hash(state.selectedPeriod?.id, state.entries.length, state.errorMessage != null),
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
                    child: Column(
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        PayrollSelectField<PayrollPeriod>(
                          label: 'Periodo',
                          options: state.periods,
                          selected: state.selectedPeriod,
                          optionLabel: (PayrollPeriod period) => period.period.label,
                          onSelect: _viewModel.onPeriodSelected,
                          enabled: !state.isUploading,
                        ),
                        FlowboardSearchField(
                          query: state.query,
                          onQueryChange: _viewModel.onQueryChange,
                          placeholder: 'Buscar por nombre o apellido',
                        ),
                        _Filters(
                          state: state,
                          onAreaSelected: _viewModel.onAreaSelected,
                          onStatusSelected: _viewModel.onStatusSelected,
                        ),
                      ],
                    ),
                  ),
                  contentBuilder: (BuildContext context, EdgeInsets contentPadding) =>
                      _buildContent(context, state, contentPadding.top),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UploadPayslipsUiState state, double headerHeight) {
    final bool sectionOpen = _uploadSectionOpen || state.isUploading || state.bannerMessage != null;
    final UploadProgress? upload = state.upload;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        headerHeight + 4,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        PayrollExpandableSection(
          title: 'Cargar y publicar boletas',
          subtitle: state.underReviewCount > 0
              ? '${state.underReviewCount} por publicar · PDF del sistema de planilla'
              : 'PDF del sistema de planilla · una boleta por colaborador',
          icon: FlowboardIcons.upload,
          expanded: sectionOpen,
          onToggle: () => setState(() => _uploadSectionOpen = !sectionOpen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.itemGap,
            children: <Widget>[
              PayslipUploadZone(
                enabled: state.canPickFiles,
                supportingText: upload == null
                    ? 'Solo PDF · una boleta por colaborador'
                    : 'Cargando ${upload.current} de ${upload.total}...',
                onFilesSelected: _viewModel.onFilesSelected,
              ),
              if (state.bannerMessage != null) PayrollErrorBanner(message: state.bannerMessage!),
              FilledButton(
                onPressed: state.canPublish ? _viewModel.onPublishClick : null,
                child: Text(
                  state.isPublishing ? 'Publicando...' : PayrollFormatters.publishLabel(state.underReviewCount),
                ),
              ),
            ],
          ),
        ),
        ..._payslips(context, state),
      ],
    );
  }

  /// Count of the period and the rows, or the loading, error or empty state.
  List<Widget> _payslips(BuildContext context, UploadPayslipsUiState state) {
    final ThemeData theme = Theme.of(context);
    if ((state.isLoadingPeriods || state.isLoadingPayslips) && state.entries.isEmpty) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.xl),
          child: SkeletonList(itemCount: 3, inline: true, padding: EdgeInsets.zero),
        ),
      ];
    }
    final String? error = state.errorMessage;
    if (error != null) {
      return <Widget>[
        PayrollMessageState(
          title: 'No se pudieron cargar las boletas',
          message: error,
          actionLabel: 'Reintentar',
          onAction: _viewModel.loadPeriods,
          topPadding: AppSpacing.xl,
          horizontalPadding: 0,
        ),
      ];
    }
    if (state.selectedPeriod == null) {
      return const <Widget>[
        PayrollMessageState(
          title: 'No hay períodos de planilla',
          message: 'Todavía no se registró ningún período de planilla.',
          topPadding: AppSpacing.xl,
          horizontalPadding: 0,
        ),
      ];
    }
    final List<PayslipEntry> visible = state.visibleEntries;
    if (visible.isEmpty && state.hasFilters) {
      return <Widget>[
        PayrollMessageState(
          title: 'No encontramos boletas',
          message: 'Ninguna boleta del período coincide con la búsqueda o los filtros.',
          actionLabel: 'Limpiar filtros',
          onAction: () {
            _viewModel.onQueryChange('');
            _viewModel.onAreaSelected(null);
            _viewModel.onStatusSelected(null);
          },
          topPadding: AppSpacing.xl,
          horizontalPadding: 0,
        ),
      ];
    }
    final bool masked = state.duplicate != null;
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
        child: Text(
          state.hasFilters
              ? PayrollFormatters.reportCount(visible.length, state.selectedStatus)
              : PayrollFormatters.uploadedCount(state.entries.length),
          style: theme.textTheme.titleMedium,
        ),
      ),
      for (final PayslipEntry entry in visible)
        PayrollListRow(
          key: ValueKey<int>(entry.payslip.id),
          leading: PayrollInitialsAvatar(initials: entry.initials),
          title: entry.listName,
          subtitle: PayrollFormatters.total(
            masked
                ? PayrollFormatters.maskedMoney(entry.payslip.netAmount)
                : PayrollFormatters.money(entry.payslip.netAmount),
          ),
          trailing: <Widget>[
            PayrollStatusChips(
              publication: entry.payslip.publicationStatus,
              payment: entry.payslip.payment.status,
            ),
          ],
          onTap: () => _viewModel.onEntryTap(entry),
        ),
    ];
  }
}

/// Chips of the area and the payment status, in one row that scrolls sideways when it does not fit.
class _Filters extends StatelessWidget {
  const _Filters({required this.state, required this.onAreaSelected, required this.onStatusSelected});

  final UploadPayslipsUiState state;
  final ValueChanged<PayrollArea?> onAreaSelected;
  final ValueChanged<PaymentStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final PayrollArea? area = state.selectedArea;
    final PaymentStatus? status = state.selectedStatus;
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppSpacing.s,
          children: <Widget>[
            PayrollFilterChip<PaymentStatus>(
              label: status == null ? 'Estado de pago' : 'Estado: ${status.label}',
              selected: status != null,
              options: PaymentStatus.values,
              optionLabel: (PaymentStatus option) => option.label,
              onSelect: onStatusSelected,
              onClear: () => onStatusSelected(null),
            ),
            PayrollFilterChip<PayrollArea>(
              label: area == null ? 'Área' : 'Área: ${area.name}',
              selected: area != null,
              options: state.areas,
              optionLabel: (PayrollArea option) => option.name,
              onSelect: onAreaSelected,
              onClear: () => onAreaSelected(null),
            ),
          ],
        ),
      ),
    );
  }
}
