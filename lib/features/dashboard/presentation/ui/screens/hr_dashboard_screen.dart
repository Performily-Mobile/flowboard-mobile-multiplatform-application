import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_glass.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/core/navigation/tab_switcher.dart';
import 'package:flowboard/features/dashboard/domain/entity/hr_dashboard.dart';
import 'package:flowboard/features/dashboard/presentation/state/hr_dashboard_ui_state.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/area_attendance_row.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_accent.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_formatters.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_metric_card.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/dashboard_skeleton.dart';
import 'package:flowboard/features/dashboard/presentation/ui/components/request_to_attend_item.dart';
import 'package:flowboard/features/dashboard/presentation/viewmodel/hr_dashboard_view_model.dart';

/// HR dashboard (MA-18): indicators, today's attendance per area and the oldest pending requests.
///
/// Cards that match a tab (Personal, Solicitudes) switch tabs; reports open on top of the
/// dashboard so that "back" returns to it. Pulling down reloads the data.
class HrDashboardScreen extends StatefulWidget {
  /// Creates the screen.
  const HrDashboardScreen({super.key});

  @override
  State<HrDashboardScreen> createState() => _HrDashboardScreenState();
}

class _HrDashboardScreenState extends State<HrDashboardScreen> {
  late final HrDashboardViewModel _viewModel = getIt<HrDashboardViewModel>();
  late final Timer _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
    _clock = Timer.periodic(const Duration(minutes: 1), (Timer _) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _switchTab(String route) => getIt<TabSwitcher>().switchTo(route);

  void _push(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final HrDashboardUiState state = _viewModel.state;
          final HrDashboard? dashboard = state.dashboard;
          final EdgeInsets padding = EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.s,
            AppSpacing.screenHorizontal,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          );

          return Column(
            children: <Widget>[
              FlowboardTopBar(
                title: DashboardFormatters.greeting(dashboard?.userFirstName, _now),
                subtitle: DashboardFormatters.dateLabel(_now),
                actions: <Widget>[
                  _NotificationsButton(
                    hasPending: (dashboard?.pendingRequests ?? 0) > 0,
                    onPressed: () => _push(AppRoutes.pendingFeature, arguments: 'Notificaciones'),
                  ),
                ],
              ),
              Expanded(
                child: state.isLoading
                    ? DashboardSkeleton(padding: padding)
                    : ScrollConfiguration(
                        // The pull-to-refresh spinner is the edge feedback here, so the damped
                        // stretch of the app scroll behavior is not used.
                        behavior: ScrollConfiguration.of(context).copyWith(
                          overscroll: false,
                          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        ),
                        child: RefreshIndicator(
                          onRefresh: _viewModel.refresh,
                          child: ListView(
                            padding: padding,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: AppSpacing.sectionGap,
                                children: <Widget>[
                                  if (state.errorMessage != null)
                                    _ErrorBanner(message: state.errorMessage!, onRetry: _viewModel.refresh),
                                  if ((dashboard?.pendingRequests ?? 0) > 0)
                                    _PendingBanner(
                                      count: dashboard!.pendingRequests!,
                                      onTap: () => _switchTab(AppRoutes.requests),
                                    ),
                                  _MetricsGrid(
                                    dashboard: dashboard,
                                    onActiveEmployeesTap: () => _switchTab(AppRoutes.employees),
                                    onPendingRequestsTap: () => _switchTab(AppRoutes.requests),
                                    onLatenessTap: () => _push(AppRoutes.attendanceAreaReport),
                                    onExpiringVacationsTap: () => _push(AppRoutes.vacationBalances),
                                  ),
                                  _AttendanceSection(
                                    dashboard: dashboard,
                                    onSeeAll: () => _push(AppRoutes.attendanceAreaReport),
                                  ),
                                  _RequestsSection(
                                    dashboard: dashboard,
                                    onSeeAll: () => _switchTab(AppRoutes.requests),
                                    onRequestTap: (int requestId) => _push(AppRoutes.reviewRequest, arguments: requestId),
                                  ),
                                  if (dashboard != null) _UpdatedCaption(loadedAt: dashboard.loadedAt, now: _now),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Small note at the end of the dashboard telling how fresh the data is.
class _UpdatedCaption extends StatelessWidget {
  const _UpdatedCaption({required this.loadedAt, required this.now});

  final DateTime loadedAt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      DashboardFormatters.updatedLabel(loadedAt, now),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

/// Glass bell of the top bar, with a dot when there are requests waiting.
class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.hasPending, required this.onPressed});

  final bool hasPending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final GlassTokens tokens = GlassTokens.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        GlassCircleButton(icon: FlowboardIcons.notifications, tooltip: 'Notificaciones', onPressed: onPressed),
        if (hasPending)
          Positioned(
            top: 10,
            right: 10,
            child: IgnorePointer(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.glassBorder, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Banner that calls attention to the requests waiting for HR and opens the inbox.
class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final Color content = DashboardAccent.amber.content(brightness);
    final String text = count == 1 ? 'Tienes 1 solicitud por atender' : 'Tienes $count solicitudes por atender';

    return GlassCard(
      onTap: onTap,
      tint: DashboardAccent.amber.container(brightness),
      borderColor: brightness == Brightness.dark ? const Color(0x33F3C577) : AppColors.pendingOutline,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 14),
      semanticLabel: text,
      child: ExcludeSemantics(
        child: Row(
          spacing: AppSpacing.m,
          children: <Widget>[
            Icon(FlowboardIcons.article, size: 24, color: content),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: content),
              ),
            ),
            Icon(FlowboardIcons.chevronRight, color: content),
          ],
        ),
      ),
    );
  }
}

/// Two rows of two indicator cards: employees, requests, lateness and expiring vacations.
class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.dashboard,
    required this.onActiveEmployeesTap,
    required this.onPendingRequestsTap,
    required this.onLatenessTap,
    required this.onExpiringVacationsTap,
  });

  final HrDashboard? dashboard;
  final VoidCallback onActiveEmployeesTap;
  final VoidCallback onPendingRequestsTap;
  final VoidCallback onLatenessTap;
  final VoidCallback onExpiringVacationsTap;

  @override
  Widget build(BuildContext context) {
    final MonthlyLateness? lateness = dashboard?.monthlyLateness;

    return Column(
      spacing: AppSpacing.m,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: DashboardMetricCard(
                  label: 'Colaboradores activos',
                  value: DashboardFormatters.count(dashboard?.activeEmployees),
                  icon: FlowboardIcons.group,
                  accent: DashboardAccent.primary,
                  onTap: onActiveEmployeesTap,
                ),
              ),
              Expanded(
                child: DashboardMetricCard(
                  label: 'Solicitudes pendientes',
                  value: DashboardFormatters.count(dashboard?.pendingRequests),
                  icon: FlowboardIcons.article,
                  accent: DashboardAccent.amber,
                  onTap: onPendingRequestsTap,
                ),
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: DashboardMetricCard(
                  label: 'Tardanzas del mes',
                  value: DashboardFormatters.count(lateness?.lateCount),
                  icon: FlowboardIcons.schedule,
                  accent: DashboardAccent.red,
                  supportingText: lateness == null ? null : DashboardFormatters.lateness(lateness.percentage),
                  onTap: onLatenessTap,
                ),
              ),
              Expanded(
                child: DashboardMetricCard(
                  label: 'Vacaciones por vencer',
                  value: DashboardFormatters.count(dashboard?.expiringVacations),
                  icon: FlowboardIcons.calendar,
                  accent: DashboardAccent.green,
                  supportingText: 'con 30 días o más sin gozar',
                  onTap: onExpiringVacationsTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card with today's attendance per area, or a message when it cannot be shown.
class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection({required this.dashboard, required this.onSeeAll});

  final HrDashboard? dashboard;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final List<AreaAttendance>? attendance = dashboard?.todayAttendance;

    return _SectionCard(
      title: 'Asistencia de hoy por área',
      action: 'Ver',
      onAction: onSeeAll,
      children: <Widget>[
        if (attendance == null)
          const _SectionMessage('No se pudo cargar la asistencia de hoy.')
        else if (attendance.isEmpty)
          const _SectionMessage('Todavía no hay áreas con colaboradores activos.')
        else ...<Widget>[
          for (final AreaAttendance area in attendance) AreaAttendanceRow(attendance: area),
          if (attendance.every((AreaAttendance area) => area.percentage == 0))
            const _SectionMessage('Nadie ha marcado entrada hoy todavía.'),
        ],
      ],
    );
  }
}

/// Card with the oldest pending requests, or a message when they cannot be shown.
class _RequestsSection extends StatelessWidget {
  const _RequestsSection({required this.dashboard, required this.onSeeAll, required this.onRequestTap});

  final HrDashboard? dashboard;
  final VoidCallback onSeeAll;
  final ValueChanged<int> onRequestTap;

  @override
  Widget build(BuildContext context) {
    final List<RequestToAttend>? requests = dashboard?.requestsToAttend;
    final Color divider = GlassTokens.of(context).border;

    return _SectionCard(
      title: 'Solicitudes por atender',
      action: 'Ver todas',
      onAction: onSeeAll,
      children: <Widget>[
        if (requests == null)
          const _SectionMessage('No se pudieron cargar las solicitudes.')
        else if (requests.isEmpty)
          const _SectionMessage('No hay solicitudes por atender.')
        else
          for (int i = 0; i < requests.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, thickness: 1, color: divider),
            RequestToAttendItem(request: requests[i], onTap: () => onRequestTap(requests[i].requestId)),
          ],
      ],
    );
  }
}

/// Card with a title, a text button on the right and free content below.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.action, required this.onAction, required this.children});

  final String title;
  final String action;
  final VoidCallback onAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.s,
        bottom: AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              TextButton(onPressed: onAction, child: Text(action)),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Short muted message shown in place of a section that has no content.
class _SectionMessage extends StatelessWidget {
  const _SectionMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

/// Banner shown when nothing could be loaded, with a retry button.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return GlassCard(
      tint: scheme.errorContainer,
      borderColor: scheme.errorContainer,
      padding: const EdgeInsets.only(left: AppSpacing.l, right: AppSpacing.s, top: AppSpacing.s, bottom: AppSpacing.s),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(message, style: text.bodyMedium?.copyWith(color: scheme.onErrorContainer))),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: scheme.onErrorContainer),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
