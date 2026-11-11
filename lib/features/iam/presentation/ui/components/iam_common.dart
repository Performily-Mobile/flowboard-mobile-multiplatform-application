import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_colors.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Kind of message shown by an [IamBanner].
enum IamBannerKind { error, success, info }

/// Tinted box with a short message, used for errors and confirmations in the IAM screens.
class IamBanner extends StatelessWidget {
  /// Creates the banner.
  const IamBanner({super.key, required this.text, this.kind = IamBannerKind.error});

  final String text;
  final IamBannerKind kind;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, IconData icon) = switch (kind) {
      IamBannerKind.error => (AppColors.errorContainer, AppColors.onErrorContainer, FlowboardIcons.warning),
      IamBannerKind.success => (AppColors.activeContainer, AppColors.onSurface, FlowboardIcons.check),
      IamBannerKind.info => (AppColors.secondaryContainer, AppColors.onSecondaryContainer, FlowboardIcons.info),
    };
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: AppShapes.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s,
            children: <Widget>[
              Icon(icon, size: 20, color: foreground),
              Expanded(
                child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: foreground)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Checklist of the password rules, ticked as the user types.
class PasswordRequirements extends StatelessWidget {
  /// Creates the checklist.
  const PasswordRequirements({
    super.key,
    required this.hasMinLength,
    required this.hasUpperAndLowerCase,
    required this.hasDigit,
    required this.hasSymbol,
  });

  final bool hasMinLength;
  final bool hasUpperAndLowerCase;
  final bool hasDigit;
  final bool hasSymbol;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s,
        children: <Widget>[
          Text('Tu contraseña debe tener', style: Theme.of(context).textTheme.titleSmall),
          _Requirement(text: 'Al menos 8 caracteres', met: hasMinLength),
          _Requirement(text: 'Una mayúscula y una minúscula', met: hasUpperAndLowerCase),
          _Requirement(text: 'Al menos un número', met: hasDigit),
          _Requirement(text: r'Al menos un símbolo (!@#$%)', met: hasSymbol),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.text, required this.met});

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = met ? AppColors.primary : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      label: '$text: ${met ? 'cumple' : 'pendiente'}',
      excludeSemantics: true,
      child: Row(
        spacing: AppSpacing.s,
        children: <Widget>[
          Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: color),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color))),
        ],
      ),
    );
  }
}

/// Card with the avatar, the name, the e-mail and the role of the signed-in user.
class AccountProfileCard extends StatelessWidget {
  /// Creates the card.
  const AccountProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.initials,
  });

  final String name;
  final String email;
  final String roleLabel;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color secondary = theme.colorScheme.onSurfaceVariant;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        spacing: AppSpacing.l,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.avatarContainer),
            child: Text(
              initials,
              style: theme.textTheme.titleMedium?.copyWith(color: AppColors.onAvatarContainer),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(name, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  email.isEmpty ? 'Sin correo registrado' : email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(roleLabel, style: theme.textTheme.labelMedium?.copyWith(color: secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Titled group of rows of the account screen.
class IamSettingsSection extends StatelessWidget {
  /// Creates the section.
  const IamSettingsSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        GlassCard(
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: 1, indent: AppSpacing.l, endIndent: AppSpacing.l),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Row of a [IamSettingsSection] with an icon, a title and an optional subtitle and trailing widget.
class IamSettingsTile extends StatelessWidget {
  /// Creates the row; without [onTap] it cannot be tapped.
  const IamSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? text = subtitle;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: text == null ? null : Text(text),
      trailing: trailing ?? (onTap == null ? null : const Icon(FlowboardIcons.chevronRight)),
      onTap: onTap,
      shape: const RoundedRectangleBorder(borderRadius: AppShapes.medium),
    );
  }
}

/// Small spinner shown inside a button while its action runs.
class IamButtonProgress extends StatelessWidget {
  /// Creates the indicator.
  const IamButtonProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
  }
}
