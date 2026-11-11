import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/iam/presentation/state/account_security_ui_state.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_common.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_labels.dart';
import 'package:flowboard/features/iam/presentation/ui/navigation/iam_navigation.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/account_security_view_model.dart';

/// Account and security of the signed-in user: profile, password, accounts of the employees for
/// HR, preferences, legal terms and sign out.
class AccountSecurityScreen extends StatefulWidget {
  /// Creates the screen.
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  late final AccountSecurityViewModel _viewModel = getIt<AccountSecurityViewModel>();
  late final ModalSync<AccountDialog> _dialog =
      ModalSync<AccountDialog>(open: _openDialog, onDismissed: _viewModel.closeDialog);

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
    final AccountDialog dialog = _viewModel.state.activeDialog;
    _dialog.sync(context, dialog == AccountDialog.none ? null : dialog);
  }

  Future<void> _openDialog(BuildContext context, AccountDialog dialog) {
    return showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => switch (dialog) {
        AccountDialog.signOut => _SignOutDialog(
            onConfirm: _viewModel.confirmSignOut,
            onDismiss: _viewModel.closeDialog,
          ),
        AccountDialog.language => _InfoDialog(
            title: 'Idioma de la aplicación',
            message: 'La traducción completa al inglés todavía no está disponible. La aplicación permanece en '
                'español.',
            onDismiss: _viewModel.closeDialog,
          ),
        AccountDialog.notifications || AccountDialog.none => _InfoDialog(
            title: 'Notificaciones del dispositivo',
            message: 'El sonido y los avisos se administran desde los ajustes del dispositivo.',
            onDismiss: _viewModel.closeDialog,
          ),
      },
    );
  }

  Future<void> _openChangePassword() async {
    final Object? result = await Navigator.of(context, rootNavigator: true).pushNamed(IamRoutes.changePassword);
    if (!mounted || result is! String) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AccountSecurityUiState state = _viewModel.state;
        final ColorScheme scheme = Theme.of(context).colorScheme;
        final String? errorMessage = state.errorMessage;
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Cuenta y seguridad', onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.xs,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: <Widget>[
                    AccountProfileCard(
                      name: state.displayName,
                      email: state.username,
                      roleLabel: state.role.label,
                      initials: state.initials,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    IamSettingsSection(
                      title: 'Seguridad',
                      children: <Widget>[
                        const IamSettingsTile(
                          icon: Icons.fingerprint,
                          title: 'Desbloqueo con huella',
                          subtitle: 'Disponible cuando se integre la autenticación biométrica',
                          trailing: Switch(value: false, onChanged: null),
                        ),
                        IamSettingsTile(
                          icon: FlowboardIcons.lock,
                          title: 'Cambiar contraseña',
                          onTap: _openChangePassword,
                        ),
                        if (state.canManageAccounts)
                          IamSettingsTile(
                            icon: FlowboardIcons.group,
                            title: 'Cuentas y roles de colaboradores',
                            onTap: () => Navigator.of(context).pushNamed(IamRoutes.accounts),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    IamSettingsSection(
                      title: 'Preferencias',
                      children: <Widget>[
                        IamSettingsTile(
                          icon: Icons.language,
                          title: 'Idioma',
                          subtitle: 'Español (es_419)',
                          onTap: () => _viewModel.openDialog(AccountDialog.language),
                        ),
                        IamSettingsTile(
                          icon: FlowboardIcons.notifications,
                          title: 'Notificaciones del dispositivo',
                          subtitle: 'Sonido y avisos del dispositivo',
                          onTap: () => _viewModel.openDialog(AccountDialog.notifications),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    IamSettingsSection(
                      title: 'Acerca de',
                      children: <Widget>[
                        IamSettingsTile(
                          icon: FlowboardIcons.article,
                          title: 'Términos del servicio y privacidad',
                          subtitle: 'Ley N.° 29733 de Protección de Datos Personales',
                          onTap: () => Navigator.of(context).pushNamed(IamRoutes.legal),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    if (errorMessage != null) ...<Widget>[
                      IamBanner(text: errorMessage),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    OutlinedButton.icon(
                      onPressed: state.isSigningOut ? null : () => _viewModel.openDialog(AccountDialog.signOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.error,
                        side: BorderSide(color: scheme.error),
                      ),
                      icon: state.isSigningOut ? const IamButtonProgress() : const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Confirmation shown before signing out.
class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({required this.onConfirm, required this.onDismiss});

  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassDialog(
      icon: Icon(Icons.logout, color: scheme.error),
      title: '¿Cerrar sesión?',
      content: Text(
        'Tu sesión terminará en este dispositivo y se borrarán los datos de acceso guardados. Necesitarás tu '
        'contraseña para volver a ingresar.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      actions: <Widget>[
        TextButton(onPressed: onDismiss, child: const Text('Cancelar')),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

/// Dialog with a title, a message and an "Entendido" button.
class _InfoDialog extends StatelessWidget {
  const _InfoDialog({required this.title, required this.message, required this.onDismiss});

  final String title;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: title,
      content: Text(message),
      actions: <Widget>[TextButton(onPressed: onDismiss, child: const Text('Entendido'))],
    );
  }
}
