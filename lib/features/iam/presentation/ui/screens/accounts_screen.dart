import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/component/glass_dialog.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/navigation/modal_sync.dart';
import 'package:flowboard/features/iam/domain/entity/account.dart';
import 'package:flowboard/features/iam/domain/valueobject/account_role.dart';
import 'package:flowboard/features/iam/presentation/state/accounts_ui_state.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_common.dart';
import 'package:flowboard/features/iam/presentation/ui/components/iam_labels.dart';
import 'package:flowboard/features/iam/presentation/viewmodel/accounts_view_model.dart';

/// Accounts of the employees for HR: change the role or reset the password of an active account.
class AccountsScreen extends StatefulWidget {
  /// Creates the screen.
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late final AccountsViewModel _viewModel = getIt<AccountsViewModel>();
  late final ModalSync<Account> _roleDialog =
      ModalSync<Account>(open: _openRoleDialog, onDismissed: _viewModel.dismissDialog);
  late final ModalSync<Account> _resetDialog =
      ModalSync<Account>(open: _openResetDialog, onDismissed: _viewModel.dismissDialog);
  late final ModalSync<String> _passwordDialog =
      ModalSync<String>(open: _openPasswordDialog, onDismissed: _viewModel.dismissTemporaryPassword);

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
    if (!mounted) return;
    final AccountsUiState state = _viewModel.state;
    _roleDialog.sync(context, state.roleCandidate);
    _resetDialog.sync(context, state.resetCandidate);
    _passwordDialog.sync(context, state.temporaryPassword);
    final String? message = state.snackbarMessage;
    if (message != null) {
      _viewModel.consumeSnackbar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openRoleDialog(BuildContext context, Account account) {
    return showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => GlassDialog(
        title: 'Asignar rol',
        content: Text('${account.username}\n\nDebe quedar al menos una cuenta activa de RR. HH.'),
        actions: <Widget>[
          TextButton(onPressed: _viewModel.dismissDialog, child: const Text('Cancelar')),
          TextButton(
            onPressed: () => _viewModel.confirmRoleChange(AccountRole.employee),
            child: const Text('Colaborador'),
          ),
          FilledButton(
            onPressed: () => _viewModel.confirmRoleChange(AccountRole.humanResources),
            child: const Text('RR. HH.'),
          ),
        ],
      ),
    );
  }

  Future<void> _openResetDialog(BuildContext context, Account account) {
    return showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => GlassDialog(
        title: 'Restablecer contraseña',
        content: Text(
          'Se generará una contraseña temporal para ${account.username}. Debes entregarla al colaborador '
          'mediante un canal seguro.',
        ),
        actions: <Widget>[
          TextButton(onPressed: _viewModel.dismissDialog, child: const Text('Cancelar')),
          FilledButton(onPressed: _viewModel.confirmPasswordReset, child: const Text('Restablecer')),
        ],
      ),
    );
  }

  Future<void> _openPasswordDialog(BuildContext context, String password) {
    return showGlassDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ThemeData theme = Theme.of(dialogContext);
        return GlassDialog(
          title: 'Contraseña temporal',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.l,
            children: <Widget>[
              const Text(
                'Muéstrala solo al colaborador correspondiente. Esta clave no se guardará en la aplicación.',
              ),
              SelectableText(password, style: theme.textTheme.titleLarge),
            ],
          ),
          actions: <Widget>[
            FilledButton(onPressed: _viewModel.dismissTemporaryPassword, child: const Text('Entendido')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AccountsUiState state = _viewModel.state;
        return Scaffold(
          body: Column(
            children: <Widget>[
              FlowboardTopBar(
                title: 'Cuentas de colaboradores',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              if (state.isProcessing) const LinearProgressIndicator(),
              Expanded(child: _AccountsBody(state: state, viewModel: _viewModel)),
            ],
          ),
        );
      },
    );
  }
}

/// List of accounts, or the loading and error states.
class _AccountsBody extends StatelessWidget {
  const _AccountsBody({required this.state, required this.viewModel});

  final AccountsUiState state;
  final AccountsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String? errorMessage = state.errorMessage;
    if (state.isLoading && state.accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && state.accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.l,
            children: <Widget>[
              IamBanner(text: errorMessage),
              FilledButton(onPressed: viewModel.load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.xs,
          AppSpacing.screenHorizontal,
          AppSpacing.fabClearance,
        ),
        itemCount: state.accounts.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.itemGap),
        itemBuilder: (BuildContext context, int index) {
          final Account account = state.accounts[index];
          return _AccountCard(
            account: account,
            isOwn: state.isOwnAccount(account),
            canManage: state.canManage(account) && !state.isProcessing,
            onChangeRole: () => viewModel.askRoleChange(account),
            onResetPassword: () => viewModel.askPasswordReset(account),
          );
        },
      ),
    );
  }
}

/// Card of one account with its role, its status and the actions HR can take.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.isOwn,
    required this.canManage,
    required this.onChangeRole,
    required this.onResetPassword,
  });

  final Account account;
  final bool isOwn;
  final bool canManage;
  final VoidCallback onChangeRole;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final List<String> details = <String>[
      account.role.label,
      account.status.label,
      if (account.mustChangePassword) 'Clave temporal pendiente',
      if (isOwn) 'Tu cuenta',
    ];
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.s, AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: <Widget>[
          Text(account.username, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(details.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          if (account.canBeManaged && !isOwn)
            Wrap(
              alignment: WrapAlignment.end,
              children: <Widget>[
                TextButton(onPressed: canManage ? onChangeRole : null, child: const Text('Cambiar rol')),
                TextButton(
                  onPressed: canManage ? onResetPassword : null,
                  child: const Text('Restablecer contraseña'),
                ),
              ],
            )
          else
            const SizedBox(height: AppSpacing.s),
        ],
      ),
    );
  }
}
