import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/collapsing_header_layout.dart';
import 'package:flowboard/core/designsystem/component/flowboard_search_field.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/payroll/domain/entity/payslip.dart';
import 'package:flowboard/features/payroll/presentation/state/my_payslips_ui_state.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_colors.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_common.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_formatters.dart';
import 'package:flowboard/features/payroll/presentation/ui/components/payroll_link_opener.dart';
import 'package:flowboard/features/payroll/presentation/ui/navigation/payroll_routes.dart';
import 'package:flowboard/features/payroll/presentation/viewmodel/my_payslips_view_model.dart';

/// "Mis boletas" of the employee: tab "Boletas" (MA-64, MA-65, user flow UF-03).
///
/// The payslips are hidden behind a verification card until the employee unlocks them with the
/// fingerprint or the password; then the published payslips of the year are listed.
class MyPayslipsScreen extends StatefulWidget {
  /// Creates the screen.
  const MyPayslipsScreen({super.key});

  @override
  State<MyPayslipsScreen> createState() => _MyPayslipsScreenState();
}

class _MyPayslipsScreenState extends State<MyPayslipsScreen> {
  late final MyPayslipsViewModel _viewModel = getIt<MyPayslipsViewModel>();

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
    final PayslipsSnackbar? snackbar = _viewModel.state.snackbar;
    if (snackbar == null) return;
    final String? url = snackbar.openUrl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackbar.message),
        action: url == null ? null : SnackBarAction(label: 'Abrir', onPressed: () => openPayslipLink(url)),
      ),
    );
    _viewModel.onSnackbarShown();
  }

  void _openViewer(Payslip payslip) {
    Navigator.of(context).pushNamed(
      PayrollRoutes.payslipViewer,
      arguments: PayslipViewerArgs(payslipId: payslip.id, title: 'Boleta ${payslip.period.inlineLabel}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final MyPayslipsUiState state = _viewModel.state;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const FlowboardTopBar(title: 'Mis boletas'),
              Expanded(
                child: state.isLocked
                    ? _LockedPayslips(
                        isVerifying: state.isVerifying,
                        message: state.lockMessage,
                        onUnlockWithFingerprint: () => _viewModel.unlock(withPassword: false),
                        onUsePassword: () => _viewModel.unlock(withPassword: true),
                      )
                    : _PayslipsList(
                        state: state,
                        onYearSelected: _viewModel.onYearSelected,
                        onQueryChange: _viewModel.onQueryChange,
                        onRetry: _viewModel.load,
                        onOpen: _openViewer,
                        onDownload: _viewModel.download,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// MA-64: the list placeholder behind the "Tus boletas están protegidas" card.
class _LockedPayslips extends StatelessWidget {
  const _LockedPayslips({
    required this.isVerifying,
    required this.message,
    required this.onUnlockWithFingerprint,
    required this.onUsePassword,
  });

  final bool isVerifying;
  final String? message;
  final VoidCallback onUnlockWithFingerprint;
  final VoidCallback onUsePassword;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String? error = message;
    return Stack(
      children: <Widget>[
        const IgnorePointer(child: ExcludeSemantics(child: SkeletonList(itemCount: 4, showAvatar: false))),
        Align(
          alignment: const Alignment(0, -0.25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: GlassCard(
              blur: true,
              radius: 28,
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 28, AppSpacing.xl, AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: PayrollColors.lockContainer),
                      child: Icon(FlowboardIcons.lock, size: 28, color: scheme.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Tus boletas están protegidas',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400, color: scheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Verifica tu identidad para ver tu remuneración y descargar tus boletas.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: isVerifying ? null : onUnlockWithFingerprint,
                      icon: isVerifying ? const PayrollButtonProgress() : const Icon(Icons.fingerprint, size: 20),
                      label: const Text('Desbloquear con huella'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  TextButton(
                    onPressed: isVerifying ? null : onUsePassword,
                    child: const Text('Usar contraseña'),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// MA-65: search box and year chips that slide away while scrolling, the payslips of the year and
/// the note about pending deposits.
class _PayslipsList extends StatelessWidget {
  const _PayslipsList({
    required this.state,
    required this.onYearSelected,
    required this.onQueryChange,
    required this.onRetry,
    required this.onOpen,
    required this.onDownload,
  });

  final MyPayslipsUiState state;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onRetry;
  final ValueChanged<Payslip> onOpen;
  final ValueChanged<Payslip> onDownload;

  @override
  Widget build(BuildContext context) {
    return CollapsingHeaderLayout(
      showHeaderKey: Object.hash(state.selectedYear, state.payslips.length, state.errorMessage != null),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 4, AppSpacing.screenHorizontal, 12),
        child: Column(
          spacing: AppSpacing.m,
          children: <Widget>[
            FlowboardSearchField(
              query: state.query,
              onQueryChange: onQueryChange,
              placeholder: 'Buscar por mes, monto o estado',
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: AppSpacing.s,
                children: <Widget>[
                  for (final int year in state.years)
                    FilterChip(
                      label: Text('$year'),
                      selected: year == state.selectedYear,
                      showCheckmark: true,
                      onSelected: (_) => onYearSelected(year),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      contentBuilder: (BuildContext context, EdgeInsets contentPadding) => _content(context, contentPadding.top),
    );
  }

  Widget _content(BuildContext context, double headerHeight) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String? error = state.errorMessage;
    if (state.isLoading && state.payslips.isEmpty) {
      return SkeletonList(
        itemCount: 5,
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, headerHeight + 4, AppSpacing.screenHorizontal, 0),
      );
    }
    if (error != null && state.payslips.isEmpty) {
      return PayrollMessageState(
        title: 'No se pudieron cargar tus boletas',
        message: error,
        actionLabel: 'Reintentar',
        onAction: onRetry,
        topPadding: headerHeight + 48,
      );
    }
    if (state.payslips.isEmpty) {
      return PayrollMessageState(
        title: 'No tienes boletas en ${state.selectedYear}',
        message: 'Cuando Recursos Humanos publique tus boletas de pago aparecerán aquí.',
        topPadding: headerHeight + 48,
      );
    }
    final List<Payslip> visible = state.visiblePayslips;
    if (visible.isEmpty) {
      return PayrollMessageState(
        title: 'No encontramos boletas',
        message: 'Ninguna boleta de ${state.selectedYear} coincide con "${state.query.trim()}".',
        actionLabel: 'Limpiar búsqueda',
        onAction: () => onQueryChange(''),
        topPadding: headerHeight + 48,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        headerHeight + 4,
        AppSpacing.screenHorizontal,
        AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: visible.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Text(
            visible.length == 1 ? '1 boleta' : '${visible.length} boletas',
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          );
        }
        if (index == visible.length + 1) {
          return state.hasPending
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Text(
                    'Pendiente: el depósito aún no ha sido registrado por Recursos Humanos.',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                )
              : const SizedBox.shrink();
        }
        final Payslip payslip = visible[index - 1];
        return PayrollListRow(
          key: ValueKey<int>(payslip.id),
          leading: const PayrollIconAvatar(),
          title: payslip.period.label,
          subtitle: 'Emitida el ${PayrollFormatters.shortDate(payslip.issueDate)} · '
              '${PayrollFormatters.total(PayrollFormatters.money(payslip.netAmount))}',
          subtitleMaxLines: 2,
          onTap: () => onOpen(payslip),
          trailing: <Widget>[
            PayrollChip.payment(payslip.payment.status),
            if (state.downloadingId == payslip.id)
              const SizedBox(width: 48, height: 48, child: Center(child: PayrollButtonProgress()))
            else
              GlassCircleButton(
                icon: FlowboardIcons.download,
                tooltip: 'Descargar boleta de ${payslip.period.inlineLabel}',
                onPressed: () => onDownload(payslip),
              ),
          ],
        );
      },
    );
  }
}
