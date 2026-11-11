import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/iam/presentation/state/login_ui_state.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_common.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_fields.dart';
import 'package:flowboard/features/iam/presentation/ui/navigation/iam_navigation.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/login_view_model.dart';

/// Sign-in screen with the corporate e-mail and the password, and the page that explains how to
/// recover the access. When the sign in works the app leaves this screen by itself.
class LoginScreen extends StatefulWidget {
  /// Creates the screen.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel = getIt<LoginViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_viewModel.state.canSubmit) return;
    FocusScope.of(context).unfocus();
    _viewModel.submit();
  }

  void _openLanguageInfo() {
    showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => GlassDialog(
        title: 'Idioma de la aplicación',
        content: const Text(
          'La traducción completa al inglés todavía no está disponible. La aplicación permanece en español.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Entendido')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final LoginUiState state = _viewModel.state;
        return PopScope(
          canPop: !state.isRecoveryVisible,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) _viewModel.hideRecovery();
          },
          child: Scaffold(
            body: state.isRecoveryVisible
                ? _RecoveryPage(onBack: _viewModel.hideRecovery)
                : _LoginForm(
                    state: state,
                    viewModel: _viewModel,
                    onSubmit: _submit,
                    onLanguage: _openLanguageInfo,
                    onLegal: () => Navigator.of(context).pushNamed(IamRoutes.legal),
                  ),
          ),
        );
      },
    );
  }
}

/// Form with the e-mail, the password and the sign-in button.
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.state,
    required this.viewModel,
    required this.onSubmit,
    required this.onLanguage,
    required this.onLegal,
  });

  final LoginUiState state;
  final LoginViewModel viewModel;
  final VoidCallback onSubmit;
  final VoidCallback onLanguage;
  final VoidCallback onLegal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final String? errorMessage = state.errorMessage;
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xxl,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.l,
                  children: <Widget>[
                    Row(
                      spacing: AppSpacing.s,
                      children: <Widget>[
                        const Icon(FlowboardIcons.gridView, color: AppColors.primary),
                        Text(
                          'Flowboard',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Semantics(
                      header: true,
                      child: Text('Iniciar sesión', style: theme.textTheme.headlineLarge),
                    ),
                    Text(
                      'Ingresa con las credenciales que Recursos Humanos te envió por correo.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: muted),
                    ),
                    if (errorMessage != null) IamBanner(text: errorMessage),
                    IamTextField(
                      label: 'Correo corporativo',
                      value: state.username,
                      onValueChange: viewModel.onUsernameChange,
                      icon: FlowboardIcons.person,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const <String>[AutofillHints.username, AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      enabled: !state.isSubmitting,
                    ),
                    IamPasswordField(
                      label: 'Contraseña',
                      value: state.password,
                      onValueChange: viewModel.onPasswordChange,
                      isVisible: state.isPasswordVisible,
                      onToggleVisibility: viewModel.togglePasswordVisibility,
                      autofillHints: const <String>[AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onSubmit(),
                      enabled: !state.isSubmitting,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: viewModel.showRecovery, child: const Text('Olvidé mi contraseña')),
                    ),
                    FilledButton(
                      onPressed: state.canSubmit ? onSubmit : null,
                      child: Text(state.isSubmitting ? 'Ingresando…' : 'Ingresar'),
                    ),
                    Row(
                      spacing: AppSpacing.m,
                      children: <Widget>[
                        const Expanded(child: Divider()),
                        Text('o', style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    Tooltip(
                      message: 'Disponible cuando se integre la autenticación biométrica',
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Ingresar con huella digital'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(onPressed: onLanguage, child: const Text('ES / EN')),
                TextButton(onPressed: onLegal, child: const Text('Términos y privacidad')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains that the HR staff resets the password with a temporary one.
class _RecoveryPage extends StatelessWidget {
  const _RecoveryPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      children: <Widget>[
        FlowboardTopBar(title: 'Recuperar acceso', onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.xl,
              children: <Widget>[
                const Icon(FlowboardIcons.lock, size: 56, color: AppColors.primary),
                Text(
                  'Recursos Humanos restablece tu contraseña',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                Text(
                  'Por seguridad, el personal de RR. HH. genera una contraseña temporal que llega a tu correo '
                  'corporativo. Al ingresar con ella se te pedirá crear una nueva.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: muted),
                ),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xs,
                    children: <Widget>[
                      Text('Contacto de Recursos Humanos', style: theme.textTheme.titleSmall),
                      Text(
                        'Solicita el contacto oficial a tu organización.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                FilledButton(onPressed: onBack, child: const Text('Volver a iniciar sesión')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
