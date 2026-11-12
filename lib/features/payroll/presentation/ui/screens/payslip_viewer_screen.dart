import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip_detail.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_details.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';
import 'package:flowboard/features/payroll/presentation/state/payslip_viewer_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_colors.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_common.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_link_opener.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/payslip_viewer_view_model.dart';

/// Viewer of a payslip of the employee (MA-66): employer, employee, period, net amount and the PDF.
class PayslipViewerScreen extends StatefulWidget {
  /// Creates the screen of the payslip [payslipId]; [title] is shown while it loads.
  const PayslipViewerScreen({super.key, required this.payslipId, required this.title});

  final int payslipId;
  final String title;

  @override
  State<PayslipViewerScreen> createState() => _PayslipViewerScreenState();
}

class _PayslipViewerScreenState extends State<PayslipViewerScreen> {
  late final PayslipViewerViewModel _viewModel = getIt<PayslipViewerViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load(widget.payslipId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onStateChanged() async {
    if (!mounted) return;
    final PayslipViewerUiState state = _viewModel.state;
    final String? message = state.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _viewModel.onSnackbarShown();
    }
    final String? url = state.openUrl;
    if (url != null) {
      _viewModel.onLinkOpened();
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      final bool opened = await openPayslipLink(url);
      if (!opened) messenger.showSnackBar(const SnackBar(content: Text('No se pudo abrir el PDF de la boleta.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final PayslipViewerUiState state = _viewModel.state;
        final PayslipDetail? detail = state.detail;
        final String? error = state.errorMessage;
        final Widget content;
        if (state.isLoading && detail == null) {
          content = const SkeletonDetail(showTabs: false);
        } else if (detail == null) {
          content = PayrollMessageState(
            title: 'No se pudo cargar la boleta',
            message: error ?? 'Inténtalo nuevamente.',
            actionLabel: 'Reintentar',
            onAction: _viewModel.retry,
          );
        } else {
          content = _PayslipContent(detail: detail, isDownloading: state.isDownloading, onDownload: _viewModel.download);
        }
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FlowboardTopBar(
                title: widget.title,
                onBack: navigator.canPop() ? () => navigator.maybePop() : null,
                actions: <Widget>[
                  GlassCircleButton(
                    icon: FlowboardIcons.download,
                    tooltip: 'Descargar PDF',
                    onPressed: detail == null || state.isDownloading ? null : _viewModel.download,
                  ),
                ],
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _PayslipContent extends StatelessWidget {
  const _PayslipContent({required this.detail, required this.isDownloading, required this.onDownload});

  final PayslipDetail detail;
  final bool isDownloading;
  final VoidCallback onDownload;

  /// Note under the card according to the deposit status.
  static String _note(PaymentDetails payment) {
    const String issuer = 'Documento emitido por el sistema de planilla de la organización.';
    return switch (payment.status) {
      PaymentStatus.paid => 'Depositado el ${PayrollFormatters.date(payment.paidOn!)}. $issuer',
      PaymentStatus.pending => 'Pendiente: el depósito aún no ha sido registrado por Recursos Humanos. $issuer',
      PaymentStatus.observed => 'Depósito observado: ${payment.observationReason}. $issuer',
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Payslip payslip = detail.payslip;
    final String employer = <String?>[
      detail.companyLegalName,
      detail.companyTaxId == null ? null : 'RUC ${detail.companyTaxId}',
    ].whereType<String>().join(' · ');
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Emitida el ${PayrollFormatters.date(payslip.issueDate)}',
                style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            PayrollChip.payment(payslip.payment.status),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (employer.isNotEmpty)
                _Divided(
                  child: Text(
                    employer,
                    style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              _Field(label: 'Colaborador', value: payslip.employeeName ?? '—'),
              _Field(label: 'Periodo', value: payslip.period.label),
              _Field(label: 'Pago total', value: PayrollFormatters.money(payslip.netAmount), divided: false),
              const SizedBox(height: AppSpacing.l),
              Container(
                height: 90,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: PayrollColors.pdfPreview,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  'Vista previa del PDF',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          _note(payslip.payment),
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: isDownloading ? null : onDownload,
            icon: isDownloading ? const PayrollButtonProgress() : const Icon(FlowboardIcons.download, size: 18),
            label: const Text('Descargar PDF'),
          ),
        ),
      ],
    );
  }
}

/// Block followed by a divider, as in the card of MA-66.
class _Divided extends StatelessWidget {
  const _Divided({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Padding(padding: const EdgeInsets.only(bottom: AppSpacing.m, top: 2), child: child),
    );
  }
}

/// "Colaborador / Luis Ramos Vega": label over value.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.divided = true});

  final String label;
  final String value;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget field = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
    return divided ? _Divided(child: field) : field;
  }
}
