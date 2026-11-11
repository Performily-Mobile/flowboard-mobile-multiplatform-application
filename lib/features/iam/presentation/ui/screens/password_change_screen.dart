import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_bottom_action_bar.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/iam/presentation/state/password_change_ui_state.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_common.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_fields.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/password_change_view_model.dart';

/// Change of the password.
///
/// When the user signed in with a temporary password the change is mandatory: there is no way
/// back, only signing out, and the app opens by itself once the password is saved. Otherwise the
/// screen closes with the result message.
class PasswordChangeScreen extends StatefulWidget {
  /// Creates the screen.
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  late final PasswordChangeViewModel _viewModel = getIt<PasswordChangeViewModel>();
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
    final PasswordChangeUiState state = _viewModel.state;
    final String? result = state.resultMessage;
    if (result == null || state.isMandatory) return;
    _closed = true;
    Navigator.of(context).pop(result);
  }

  void _submit() {
    if (!_viewModel.state.canSubmit) return;
    FocusScope.of(context).unfocus();
    _viewModel.submit();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final PasswordChangeUiState state = _viewModel.state;
        final ThemeData theme = Theme.of(context);
        final String? errorMessage = state.errorMessage;
        return Scaffold(
          bottomNavigationBar: FlowboardBottomActionBar(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: state.canSubmit ? _submit : null,
                  child: state.isSaving
                      ? const IamButtonProgress()
                      : Text(state.isMandatory ? 'Guardar y continuar' : 'Guardar contraseña'),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              if (state.isMandatory)
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                      child: TextButton(
                        onPressed: state.isSaving ? null : _viewModel.leave,
                        child: const Text('Cerrar sesión'),
                      ),
                    ),
                  ),
                )
              else
                FlowboardTopBar(title: 'Cambiar contraseña', onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.s,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.l,
                      children: <Widget>[
                        if (state.isMandatory) ...<Widget>[
                          Semantics(
                            header: true,
                            child: Text('Crea tu contraseña', style: theme.textTheme.headlineMedium),
                          ),
                          const IamBanner(
                            text: 'Ingresaste con una contraseña temporal. Crea una propia para continuar.',
                            kind: IamBannerKind.info,
                          ),
                        ],
                        if (errorMessage != null) IamBanner(text: errorMessage),
                        IamPasswordField(
                          label: state.isMandatory ? 'Contraseña temporal' : 'Contraseña actual',
                          value: state.currentPassword,
                          onValueChange: _viewModel.onCurrentPasswordChange,
                          isVisible: state.isVisible(PasswordField.current),
                          onToggleVisibility: () => _viewModel.toggleVisibility(PasswordField.current),
                          autofillHints: const <String>[AutofillHints.password],
                          textInputAction: TextInputAction.next,
                          enabled: !state.isSaving,
                        ),
                        IamPasswordField(
                          label: 'Nueva contraseña',
                          value: state.newPassword,
                          onValueChange: _viewModel.onNewPasswordChange,
                          isVisible: state.isVisible(PasswordField.newPassword),
                          onToggleVisibility: () => _viewModel.toggleVisibility(PasswordField.newPassword),
                          autofillHints: const <String>[AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          enabled: !state.isSaving,
                        ),
                        IamPasswordField(
                          label: 'Confirmar nueva contraseña',
                          value: state.confirmation,
                          onValueChange: _viewModel.onConfirmationChange,
                          isVisible: state.isVisible(PasswordField.confirmation),
                          onToggleVisibility: () => _viewModel.toggleVisibility(PasswordField.confirmation),
                          errorText: state.confirmationMismatch ? 'Las contraseñas no coinciden.' : null,
                          autofillHints: const <String>[AutofillHints.newPassword],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          enabled: !state.isSaving,
                        ),
                        PasswordRequirements(
                          hasMinLength: state.hasMinLength,
                          hasUpperAndLowerCase: state.hasUpperAndLowerCase,
                          hasDigit: state.hasDigit,
                          hasSymbol: state.hasSymbol,
                        ),
                      ],
                    ),
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
