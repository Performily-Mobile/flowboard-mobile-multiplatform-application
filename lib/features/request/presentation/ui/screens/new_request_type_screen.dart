import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_sheet.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/presentation/state/new_request_type_ui_state.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_dialogs.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_fields.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_labels.dart';
import 'package:flowboard/features/request/presentation/viewmodel/new_request_type_view_model.dart';

/// Form for HR to create a request type: name, description, attachment rule, balance deduction and
/// fields. It closes with the message of the new type.
class NewRequestTypeScreen extends StatefulWidget {
  /// Creates the screen.
  const NewRequestTypeScreen({super.key});

  @override
  State<NewRequestTypeScreen> createState() => _NewRequestTypeScreenState();
}

class _NewRequestTypeScreenState extends State<NewRequestTypeScreen> {
  late final NewRequestTypeViewModel _viewModel = getIt<NewRequestTypeViewModel>();
  late final ModalSync<bool> _fieldSheet =
      ModalSync<bool>(open: _openFieldSheet, onDismissed: _viewModel.dismissFieldSheet);
  bool _closed = false;

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
    if (!mounted || _closed) return;
    final NewRequestTypeUiState state = _viewModel.state;
    final String? result = state.resultMessage;
    if (result != null) {
      _closed = true;
      Navigator.of(context).pop(result);
      return;
    }
    _fieldSheet.sync(context, state.fieldForm == null ? null : true);
  }

  Future<void> _openFieldSheet(BuildContext context, bool visible) async {
    await showGlassBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final FieldForm? form = _viewModel.state.fieldForm;
          if (form == null) return const SizedBox.shrink();
          return AddFieldSheet(
            label: form.label,
            dataType: form.dataType,
            isRequired: form.isRequired,
            error: form.error,
            onLabelChange: _viewModel.onFieldLabelChange,
            onDataTypeChange: _viewModel.onFieldDataTypeChange,
            onRequiredChange: _viewModel.onFieldRequiredChange,
            onAdd: _viewModel.addField,
            onDismiss: _viewModel.dismissFieldSheet,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final NewRequestTypeUiState state = _viewModel.state;
        final ThemeData theme = Theme.of(context);
        final String? errorMessage = state.errorMessage;
        return Scaffold(
          bottomNavigationBar: FlowboardBottomActionBar(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: state.canSave ? _viewModel.save : null,
                  child: state.isSaving ? const RequestButtonProgress() : const Text('Guardar tipo'),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Nuevo tipo de solicitud', onClose: () => Navigator.of(context).maybePop()),
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
                      RequestTextField(
                        label: 'Nombre',
                        value: state.name,
                        onValueChange: _viewModel.onNameChange,
                        error: state.nameError,
                      ),
                      RequestTextField(
                        label: 'Descripción',
                        value: state.description,
                        onValueChange: _viewModel.onDescriptionChange,
                      ),
                      RequestSwitchRow(
                        title: 'Requiere documento adjunto',
                        description: 'El colaborador no podrá enviar sin sustento',
                        value: state.requiresAttachment,
                        onChanged: _viewModel.onRequiresAttachmentChange,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.s,
                        children: <Widget>[
                          Text(
                            'Descuenta saldo',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          FlowboardTabs<BalanceDeduction>(
                            options: BalanceDeduction.values,
                            selected: state.balanceDeduction,
                            onSelect: _viewModel.onBalanceDeductionChange,
                            labelOf: (BalanceDeduction deduction) => deduction.label,
                          ),
                        ],
                      ),
                      RequestSectionHeader(
                        text: 'Campos del formulario',
                        action: TextButton(onPressed: _viewModel.showFieldSheet, child: const Text('+ Agregar campo')),
                      ),
                      _FieldsCard(fields: state.fields, onRemove: _viewModel.removeField),
                      if (errorMessage != null)
                        Text(errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
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

/// Card with the fields added to the form, or a hint when there are none.
class _FieldsCard extends StatelessWidget {
  const _FieldsCard({required this.fields, required this.onRemove});

  final List<NewRequestField> fields;
  final ValueChanged<NewRequestField> onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    if (fields.isEmpty) {
      return Text(
        'Sin campos. El colaborador solo elegirá las fechas y, si corresponde, adjuntará el sustento.',
        style: theme.textTheme.bodySmall?.copyWith(color: muted),
      );
    }
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, 4, AppSpacing.xs, 4),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < fields.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: <Widget>[
                      Text(fields[i].label, style: theme.textTheme.bodyLarge),
                      Text(
                        RequestFormatters.fieldDetail(fields[i].dataType, fields[i].isRequired),
                        style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar ${fields[i].label}',
                  onPressed: () => onRemove(fields[i]),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
