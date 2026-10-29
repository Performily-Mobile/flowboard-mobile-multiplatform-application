import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_shapes.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/navigation/app_routes.dart';

/// "Más" tab for HR: options grouped in two tonal blocks, "Gestión" and "Mi cuenta".
class MorePage extends StatelessWidget {
  /// Creates the screen.
  const MorePage({super.key});

  void _open(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const FlowboardTopBar(title: 'Más'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xs,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                spacing: AppSpacing.sectionGap,
                children: <Widget>[
                  _MoreSection(
                    title: 'Gestión',
                    items: <_MoreItemData>[
                      _MoreItemData(FlowboardIcons.accountTree, 'Organización', 'Áreas, posiciones y organigrama',
                          () => _open(context, AppRoutes.organization)),
                      _MoreItemData(FlowboardIcons.article, 'Tipos de solicitud', 'Campos, adjuntos y descuento de saldo',
                          () => _open(context, AppRoutes.requestTypes)),
                      _MoreItemData(FlowboardIcons.gift, 'Beneficios', 'Catálogo, asignación y entregas',
                          () => _open(context, AppRoutes.benefits)),
                      _MoreItemData(FlowboardIcons.creditCard, 'Boletas y pagos', 'Carga, publicación y estado de depósito',
                          () => _open(context, AppRoutes.payroll)),
                      _MoreItemData(FlowboardIcons.favorite, 'Bienestar', 'Espacios, dispositivos e indicadores',
                          () => _open(context, AppRoutes.wellbeing)),
                    ],
                  ),
                  _MoreSection(
                    title: 'Mi cuenta',
                    items: <_MoreItemData>[
                      _MoreItemData(FlowboardIcons.person, 'Mi perfil y autogestión', 'Ver mi información como colaborador',
                          () => _open(context, AppRoutes.myProfile)),
                      _MoreItemData(FlowboardIcons.gift, 'Mis beneficios', 'Beneficios vigentes y entregados',
                          () => _open(context, AppRoutes.myBenefits)),
                      _MoreItemData(FlowboardIcons.schedule, 'Mi saldo de vacaciones', 'Días disponibles y movimientos',
                          () => _open(context, AppRoutes.myVacationBalance)),
                      _MoreItemData(FlowboardIcons.lock, 'Cuenta y seguridad', 'Huella, idioma y cierre de sesión',
                          () => _open(context, AppRoutes.account)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItemData {
  const _MoreItemData(this.icon, this.title, this.subtitle, this.onTap);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

/// Titled group of options shown inside a tonal card.
class _MoreSection extends StatelessWidget {
  const _MoreSection({required this.title, required this.items});

  final String title;
  final List<_MoreItemData> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: scheme.surfaceContainerLow,
            shape: const RoundedRectangleBorder(borderRadius: AppShapes.medium),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < items.length; i++) ...<Widget>[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 72, right: AppSpacing.l),
                      child: Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                  _MoreItem(data: items[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One option: round icon, title, short description and a chevron.
class _MoreItem extends StatelessWidget {
  const _MoreItem({required this.data});

  final _MoreItemData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: 14),
        child: Row(
          spacing: AppSpacing.l,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
              child: Icon(data.icon, size: 20, color: scheme.onSecondaryContainer),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(FlowboardIcons.chevronRight, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
