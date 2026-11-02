import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';
import 'package:flowboard/features/workspace/presentation/state/register_employee_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/select_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';

/// First step of the employee registration: personal and contact data.
class PersonalDataStep extends StatelessWidget {
  /// Creates the step.
  const PersonalDataStep({
    super.key,
    required this.state,
    required this.onFirstNameChange,
    required this.onLastNameChange,
    required this.onDocumentTypeChange,
    required this.onDocumentNumberChange,
    required this.onBirthDateChange,
    required this.onEmailChange,
    required this.onPhoneChange,
  });

  final RegisterEmployeeUiState state;
  final ValueChanged<String> onFirstNameChange;
  final ValueChanged<String> onLastNameChange;
  final ValueChanged<IdentityDocumentType> onDocumentTypeChange;
  final ValueChanged<String> onDocumentNumberChange;
  final ValueChanged<DateTime> onBirthDateChange;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPhoneChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.m,
      children: <Widget>[
        FormTextField(
          label: 'Nombres',
          value: state.firstName,
          onValueChange: onFirstNameChange,
          error: state.errorOf(RegisterField.firstName),
          textCapitalization: TextCapitalization.words,
        ),
        FormTextField(
          label: 'Apellidos',
          value: state.lastName,
          onValueChange: onLastNameChange,
          error: state.errorOf(RegisterField.lastName),
          textCapitalization: TextCapitalization.words,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.m,
          children: <Widget>[
            SizedBox(
              width: 120,
              child: SelectField<IdentityDocumentType>(
                label: 'Tipo',
                options: IdentityDocumentType.values,
                selected: state.documentType,
                optionLabel: (IdentityDocumentType type) => type.label,
                onSelect: onDocumentTypeChange,
              ),
            ),
            Expanded(
              child: FormTextField(
                label: 'Número de documento',
                value: state.documentNumber,
                onValueChange: onDocumentNumberChange,
                error: state.errorOf(RegisterField.documentNumber),
                keyboardType:
                    state.documentType == IdentityDocumentType.dni ? TextInputType.number : TextInputType.text,
              ),
            ),
          ],
        ),
        DatePickerField(
          label: 'Fecha de nacimiento',
          value: state.birthDate,
          onValueChange: onBirthDateChange,
          isError: state.errorOf(RegisterField.birthDate) != null,
          supportingText: state.errorOf(RegisterField.birthDate),
        ),
        FormTextField(
          label: 'Correo corporativo',
          value: state.email,
          onValueChange: onEmailChange,
          error: state.errorOf(RegisterField.email),
          keyboardType: TextInputType.emailAddress,
        ),
        FormTextField(
          label: 'Teléfono',
          value: state.phoneNumber,
          onValueChange: onPhoneChange,
          error: state.errorOf(RegisterField.phone),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

/// Text field of the workspace forms with its label above the value and the error below.
class FormTextField extends StatefulWidget {
  /// Creates the field.
  ///
  /// [value] is the text kept by the view model, [error] the message shown below the field,
  /// [minLines] above one makes it a multiline field and [enabled] false makes it read-only.
  const FormTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onValueChange,
    this.error,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.minLines = 1,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onValueChange;
  final String? error;
  final String? helperText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int minLines;
  final bool enabled;

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(FormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool multiline = widget.minLines > 1;
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChange,
      enabled: widget.enabled,
      keyboardType: multiline ? TextInputType.multiline : widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      minLines: widget.minLines,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.error,
        helperText: widget.helperText,
        errorMaxLines: 2,
        helperMaxLines: 2,
      ),
    );
  }
}
