import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/attendance/application/usecase/justify_attendance_use_case.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/presentation/state/attendance_filters.dart';
import 'package:flowboard/features/attendance/presentation/state/justify_attendance_ui_state.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_colors.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_common.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_fields.dart';
import 'package:flowboard/features/attendance/presentation/ui/components/attendance_formatters.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/justify_attendance_view_model.dart';

/// Form to justify a late, absent or incomplete day: kind, reason and an optional link to the
/// evidence. It closes with the message for the previous screen.
class JustifyAttendanceScreen extends StatefulWidget {
  /// Creates the screen for [record].
  const JustifyAttendanceScreen({super.key, required this.record});

  final AttendanceRecord record;

  @override
  State<JustifyAttendanceScreen> createState() => _JustifyAttendanceScreenState();
}

class _JustifyAttendanceScreenState extends State<JustifyAttendanceScreen> {
  late final JustifyAttendanceViewModel _viewModel = getIt<JustifyAttendanceViewModel>();
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.start(widget.record);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted || _closed) return;
    final String? result = _viewModel.state.resultMessage;
    if (result != null) {
      _closed = true;
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final JustifyAttendanceUiState state = _viewModel.state;
        final String? errorMessage = state.errorMessage;
        return Scaffold(
          bottomNavigationBar: FlowboardBottomActionBar(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: state.canSave ? _viewModel.save : null,
                  child: state.isSaving ? const AttendanceButtonProgress() : const Text('Enviar justificación'),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Justificar asistencia', onClose: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    8,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.l,
                    children: <Widget>[
                      _DayCard(record: widget.record),
                      AttendanceSelectField<JustificationType>(
                        label: 'Tipo de justificación',
                        options: JustificationType.values,
                        selected: state.type,
                        optionLabel: (JustificationType type) => type.label,
                        onSelect: _viewModel.onTypeChange,
                      ),
                      AttendanceTextField(
                        label: 'Motivo',
                        value: state.reason,
                        onValueChange: _viewModel.onReasonChange,
                        error: state.reasonError,
                        helperText: 'Cuéntanos qué pasó ese día.',
                        minLines: 4,
                      ),
                      AttendanceTextField(
                        label: 'Enlace del sustento (opcional)',
                        value: state.evidenceUrl,
                        onValueChange: _viewModel.onEvidenceUrlChange,
                        error: state.evidenceError,
                        helperText: 'Por ejemplo, el enlace al certificado médico en Drive.',
                        keyboardType: TextInputType.url,
                      ),
                      if (errorMessage != null)
                        AttendanceBanner(
                          message: errorMessage,
                          icon: FlowboardIcons.warning,
                          containerColor: AttendanceColors.errorBanner,
                          contentColor: AttendanceColors.onErrorBanner,
                        ),
                      AttendanceBanner(
                        message: 'Tu justificación queda registrada en el día. RR. HH. puede revisarla en '
                            'cualquier momento. Máximo ${JustifyAttendanceUseCase.maxReason} caracteres.',
                        icon: FlowboardIcons.info,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card with the day being justified, its punches and its status.
class _DayCard extends StatelessWidget {
  const _DayCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          const AttendanceIconCircle(icon: FlowboardIcons.calendar),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  AttendanceFormatters.longDay(record.workDate),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  AttendanceFormatters.punches(record),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          AttendanceStatusChip(status: record.status),
        ],
      ),
    );
  }
}
