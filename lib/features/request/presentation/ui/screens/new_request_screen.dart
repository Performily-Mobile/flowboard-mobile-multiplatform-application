import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/entity/vacation_availability.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/presentation/state/new_request_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_attachments.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_fields.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/viewmodel/new_request_view_model.dart';

/// Three-step form to send a request: type, detail and confirmation.
///
/// It closes with the message of the sent request; the system back gesture goes back one step.
class NewRequestScreen extends StatefulWidget {
  /// Creates the screen.
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  late final NewRequestViewModel _viewModel = getIt<NewRequestViewModel>();
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final String? message = _viewModel.state.resultMessage;
    if (!mounted || _closed || message == null) return;
    _closed = true;
    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final NewRequestUiState state = _viewModel.state;
        final bool firstStep = state.step == NewRequestStep.type;
        final bool showForm = !state.isLoading && state.types.isNotEmpty;
        return PopScope(
          canPop: firstStep,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) _viewModel.goBack();
          },
          child: Scaffold(
            bottomNavigationBar: showForm ? _NewRequestActions(state: state, viewModel: _viewModel) : null,
            body: Column(
              children: <Widget>[
                FlowboardTopBar(
                  title: 'Nueva solicitud',
                  onClose: firstStep ? () => Navigator.of(context).maybePop() : null,
                  onBack: firstStep ? null : _viewModel.goBack,
                ),
                Expanded(child: _buildBody(state, showForm)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(NewRequestUiState state, bool showForm) {
    if (state.isLoading) return const SkeletonForm(fieldCount: 4);
    if (!showForm) {
      final String? loadError = state.loadError;
      return RequestMessageState(
        title: loadError != null ? 'No se pudo cargar el formulario' : 'No hay tipos de solicitud activos',
        message: loadError ?? 'Recursos Humanos aún no ha habilitado tipos de solicitud.',
        actionLabel: loadError != null ? 'Reintentar' : null,
        onAction: _viewModel.load,
        topPadding: AppSpacing.xl,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.l,
        children: <Widget>[
          RequestStepHeader(step: state.step.number, total: NewRequestStep.values.length, label: state.step.label),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (state.step) {
              NewRequestStep.type => _TypeStep(key: const ValueKey<int>(1), state: state, viewModel: _viewModel),
              NewRequestStep.detail => _DetailStep(key: const ValueKey<int>(2), state: state, viewModel: _viewModel),
              NewRequestStep.confirmation => _ConfirmationStep(key: const ValueKey<int>(3), state: state),
            },
          ),
        ],
      ),
    );
  }
}

/// Bottom bar with the main action of the current step.
class _NewRequestActions extends StatelessWidget {
  const _NewRequestActions({required this.state, required this.viewModel});

  final NewRequestUiState state;
  final NewRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    switch (state.step) {
      case NewRequestStep.type:
        return FlowboardBottomActionBar(
          children: <Widget>[
            Expanded(
              child: FilledButton(
                onPressed: state.selectedType == null ? null : viewModel.continueToDetail,
                child: const Text('Continuar'),
              ),
            ),
          ],
        );
      case NewRequestStep.detail:
        return FlowboardBottomActionBar(
          children: <Widget>[
            Expanded(
              child: FilledButton(
                onPressed: state.canReview ? viewModel.continueToConfirmation : null,
                child: const Text('Revisar solicitud'),
              ),
            ),
          ],
        );
      case NewRequestStep.confirmation:
        return FlowboardBottomActionBar(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSubmitting ? null : viewModel.goBack,
                child: const Text('Editar'),
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: state.isSubmitting ? null : viewModel.submit,
                child: state.isSubmitting ? const RequestButtonProgress() : const Text('Enviar solicitud'),
              ),
            ),
          ],
        );
    }
  }
}

/// First step: the active request types to choose from.
class _TypeStep extends StatelessWidget {
  const _TypeStep({super.key, required this.state, required this.viewModel});

  final NewRequestUiState state;
  final NewRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.itemGap,
      children: <Widget>[
        Text('¿Qué quieres solicitar?', style: theme.textTheme.titleLarge),
        for (final RequestType type in state.types)
          Semantics(
            selected: type.id == state.selectedType?.id,
            child: GlassCard(
              onTap: () => viewModel.onTypeSelected(type),
              tint: type.id == state.selectedType?.id ? scheme.secondaryContainer : null,
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                spacing: AppSpacing.m,
                children: <Widget>[
                  Icon(
                    type.id == state.selectedType?.id ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: scheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: <Widget>[
                        Text(type.name, style: theme.textTheme.bodyLarge),
                        Text(
                          RequestFormatters.typeHint(type, state.availability?.availableDays),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Second step: period, dynamic fields, attachments and approver of the request.
class _DetailStep extends StatelessWidget {
  const _DetailStep({super.key, required this.state, required this.viewModel});

  final NewRequestUiState state;
  final NewRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final RequestType? type = state.selectedType;
    if (type == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final VacationAvailability? availability = state.availability;
    final RequestPeriod? period = state.period;
    final bool hourly = state.byHours && state.canUseHours;
    final String? periodError = state.periodError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.l,
      children: <Widget>[
        if (state.exceedsBalance && availability != null)
          RequestBanner(
            message: 'Solicitaste ${RequestFormatters.days(state.requestedDays)} y tu saldo disponible es de '
                '${RequestFormatters.number(availability.availableDays)}. Ajusta el periodo o consulta con '
                'Recursos Humanos.',
            icon: FlowboardIcons.warning,
            containerColor: RequestColors.errorBanner,
            contentColor: RequestColors.onErrorBanner,
          ),
        if (state.canUseHours)
          RequestSwitchRow(
            title: 'Por horas',
            description: 'Una fracción de la jornada de un solo día',
            value: state.byHours,
            onChanged: viewModel.onByHoursChange,
          ),
        if (hourly) ...<Widget>[
          RequestDateField(
            label: 'Fecha',
            value: state.startDate,
            onValueChange: viewModel.onStartDateChange,
            isError: periodError != null && state.startDate == null,
          ),
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: RequestTimeField(
                  label: 'Hora de inicio',
                  value: state.startTime,
                  onValueChange: viewModel.onStartTimeChange,
                ),
              ),
              Expanded(
                child: RequestTimeField(
                  label: 'Hora de fin',
                  value: state.endTime,
                  onValueChange: viewModel.onEndTimeChange,
                ),
              ),
            ],
          ),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: RequestDateField(
                  label: 'Fecha de inicio',
                  value: state.startDate,
                  onValueChange: viewModel.onStartDateChange,
                  isError: periodError != null && state.startDate == null,
                ),
              ),
              Expanded(
                child: RequestDateField(
                  label: 'Fecha de fin',
                  value: state.endDate,
                  onValueChange: viewModel.onEndDateChange,
                  minDate: state.startDate,
                  isError: state.exceedsBalance,
                  supportingText: state.exceedsBalance ? 'Supera tu saldo' : null,
                ),
              ),
            ],
          ),
        if (periodError != null)
          Text(periodError, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        if (period != null && type.deductsVacationDays && availability != null && !state.exceedsBalance)
          RequestBanner(
            message: '${RequestFormatters.days(period.days)}. Saldo disponible: '
                '${RequestFormatters.balanceDays(availability.availableDays)}.',
            icon: FlowboardIcons.check,
            containerColor: RequestColors.okBanner,
            contentColor: RequestColors.onOkBanner,
          ),
        for (final RequestField field in type.fields)
          DynamicFieldInput(
            key: ValueKey<String>(field.key),
            field: field,
            value: state.values[field.key] ?? '',
            onValueChange: (String value) => viewModel.onFieldChange(field.key, value),
            error: state.fieldErrors[field.key],
          ),
        AttachmentZone(
          isRequired: type.requiresAttachment,
          isUploading: state.isUploading,
          onPicked: viewModel.onFilePicked,
          error: state.attachmentError,
        ),
        for (final FileReference file in state.attachments)
          AttachmentRow(file: file, onRemove: () => viewModel.removeAttachment(file)),
        _ApproverCard(state: state),
      ],
    );
  }
}

/// Card that tells who will receive the request.
class _ApproverCard extends StatelessWidget {
  const _ApproverCard({required this.state});

  final NewRequestUiState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          RequestAvatar(name: state.approverName),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  'Se enviará a ${RequestFormatters.shortName(state.approverName)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  state.approver != null
                      ? 'Tu jefe directo según la jerarquía registrada'
                      : 'No tienes jefe directo asignado',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Third step: summary of the request before sending it.
class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({super.key, required this.state});

  final NewRequestUiState state;

  @override
  Widget build(BuildContext context) {
    final RequestType? type = state.selectedType;
    if (type == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final RequestPeriod? period = state.period;
    final VacationAvailability? availability = state.availability;
    final String? errorMessage = state.errorMessage;
    final List<KeyValue> items = <KeyValue>[
      KeyValue('Tipo', type.name),
      KeyValue('Periodo', RequestFormatters.longPeriod(period)),
      KeyValue(period?.hasHours == true ? 'Horas' : 'Días', RequestFormatters.amount(period)),
      if (type.deductsVacationDays && availability != null)
        KeyValue(
          'Saldo después de aprobar',
          RequestFormatters.balanceDays(availability.afterUsing(state.requestedDays)),
        ),
      for (final RequestField field in type.fields)
        if ((state.values[field.key] ?? '').trim().isNotEmpty)
          KeyValue(field.label, RequestFormatters.fieldValue(field, state.values[field.key]!)),
      if (state.attachments.isNotEmpty)
        KeyValue('Adjuntos', state.attachments.map((FileReference file) => file.fileName).join('\n')),
      KeyValue('Aprobador', state.approver != null ? '${state.approverName} · Jefe directo' : 'Recursos Humanos'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.itemGap,
      children: <Widget>[
        Text('Revisa tu solicitud', style: theme.textTheme.titleLarge),
        KeyValueCard(items: items),
        Text(
          '${RequestFormatters.shortName(state.approverName)} recibirá una notificación en su teléfono. '
          'Podrás seguir el estado en Solicitudes.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (errorMessage != null)
          Text(errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
      ],
    );
  }
}
