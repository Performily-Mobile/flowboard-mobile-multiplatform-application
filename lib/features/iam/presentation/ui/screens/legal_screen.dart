import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_tabs.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';

/// Tab of the legal screen.
enum LegalTab {
  terms('Términos del servicio'),
  privacy('Privacidad');

  const LegalTab(this.label);

  final String label;
}

/// Terms of service and privacy policy, opened from the login and from the account screen.
class LegalScreen extends StatefulWidget {
  /// Creates the screen.
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  LegalTab _tab = LegalTab.privacy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool privacy = _tab == LegalTab.privacy;
    return Scaffold(
      body: Column(
        children: <Widget>[
          FlowboardTopBar(title: 'Términos y privacidad', onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xs,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.l,
                children: <Widget>[
                  FlowboardTabs<LegalTab>(
                    options: LegalTab.values,
                    selected: _tab,
                    onSelect: (LegalTab tab) => setState(() => _tab = tab),
                    labelOf: (LegalTab tab) => tab.label,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xs,
                    children: <Widget>[
                      Text(
                        privacy ? 'Política de privacidad' : 'Términos del servicio',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'Última actualización: 01/09/2026',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (privacy) ...const <Widget>[
                    _LegalParagraph(
                      title: 'Datos que tratamos',
                      detail: 'Tu ficha laboral, asistencia, solicitudes, beneficios y boletas, registrados por tu '
                          'organización.',
                    ),
                    _LegalParagraph(
                      title: 'Quién puede verlos',
                      detail: 'Solo tú y el personal de Recursos Humanos autorizado, de acuerdo con tus permisos.',
                    ),
                    _LegalParagraph(
                      title: 'Marco legal',
                      detail: 'Ley N.° 29733, Ley de Protección de Datos Personales, y su reglamento.',
                    ),
                    _LegalParagraph(
                      title: 'En tu dispositivo',
                      detail: 'El token de sesión se guarda cifrado en el almacenamiento seguro del dispositivo.',
                    ),
                  ] else
                    const _LegalParagraph(
                      title: 'Uso del servicio',
                      detail: 'Flowboard facilita la consulta de información laboral, sujeto a los permisos asignados '
                          'por tu organización. La versión legal definitiva debe ser aprobada por la organización.',
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

/// One clause of the legal text: a title and its detail.
class _LegalParagraph extends StatelessWidget {
  const _LegalParagraph({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleMedium),
        Text(detail, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
