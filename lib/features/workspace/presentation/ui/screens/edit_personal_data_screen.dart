import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/presentation/state/edit_personal_data_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/create_area_sheet.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/date_picker_field.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/detail_row.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/personal_data_step.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/edit_personal_data_view_model.dart';

/// Form to edit the personal data and address of an employee; the identity document is read-only.
///
/// It closes itself after a successful save.
class EditPersonalDataScreen extends StatefulWidget {
  /// Creates the screen for [employeeId].
  const EditPersonalDataScreen({super.key, required this.employeeId});

  final int employeeId;

  @override
  State<EditPersonalDataScreen> createState() => _EditPersonalDataScreenState();
}

class _EditPersonalDataScreenState extends State<EditPersonalDataScreen> {
  late final EditPersonalDataViewModel _viewModel = getIt<EditPersonalDataViewModel>();
  bool _closed = false;

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
    if (!mounted || _closed || !_viewModel.state.isSaved) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final EditPersonalDataUiState state = _viewModel.state;
        final ThemeData theme = Theme.of(context);
        final TextStyle? errorStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error);
        return Scaffold(
          bottomNavigationBar: FlowboardBottomActionBar(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: state.isSaving || state.isLoading ? null : _viewModel.onSave,
                  child: state.isSaving ? const ButtonProgress() : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Editar datos personales', onClose: () => Navigator.of(context).maybePop()),
              Expanded(
                child: state.isLoading
                    ? const SkeletonForm()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          8,
                          AppSpacing.screenHorizontal,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: AppSpacing.m,
                          children: <Widget>[
                            FormTextField(
                              label: 'Documento de identidad',
                              value: state.identityDocumentLabel,
                              onValueChange: (String _) {},
                              enabled: false,
                              helperText: 'El documento de identidad no se puede modificar.',
                            ),
                            FormTextField(
                              label: 'Nombres',
                              value: state.firstName,
                              onValueChange: _viewModel.onFirstNameChange,
                              error: state.errorOf(PersonalDataField.firstName),
                              textCapitalization: TextCapitalization.words,
                            ),
                            FormTextField(
                              label: 'Apellidos',
                              value: state.lastName,
                              onValueChange: _viewModel.onLastNameChange,
                              error: state.errorOf(PersonalDataField.lastName),
                              textCapitalization: TextCapitalization.words,
                            ),
                            DatePickerField(
                              label: 'Fecha de nacimiento',
                              value: state.birthDate,
                              onValueChange: _viewModel.onBirthDateChange,
                              isError: state.errorOf(PersonalDataField.birthDate) != null,
                              supportingText: state.errorOf(PersonalDataField.birthDate),
                            ),
                            FormTextField(
                              label: 'Correo electrónico',
                              value: state.email,
                              onValueChange: _viewModel.onEmailChange,
                              error: state.errorOf(PersonalDataField.email),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            FormTextField(
                              label: 'Teléfono',
                              value: state.phoneNumber,
                              onValueChange: _viewModel.onPhoneChange,
                              error: state.errorOf(PersonalDataField.phone),
                              keyboardType: TextInputType.phone,
                            ),
                            const SectionTitle('Dirección (opcional)'),
                            FormTextField(
                              label: 'Calle y número',
                              value: state.street,
                              onValueChange: _viewModel.onStreetChange,
                            ),
                            FormTextField(
                              label: 'Distrito',
                              value: state.district,
                              onValueChange: _viewModel.onDistrictChange,
                            ),
                            FormTextField(
                              label: 'Provincia',
                              value: state.province,
                              onValueChange: _viewModel.onProvinceChange,
                            ),
                            FormTextField(
                              label: 'Departamento',
                              value: state.department,
                              onValueChange: _viewModel.onDepartmentChange,
                            ),
                            if (state.errorOf(PersonalDataField.address) != null)
                              Text(state.errorOf(PersonalDataField.address)!, style: errorStyle),
                            if (state.errorMessage != null) Text(state.errorMessage!, style: errorStyle),
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
