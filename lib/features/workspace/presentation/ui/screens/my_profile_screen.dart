import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/skeleton.dart';
import 'package:flowboard/core/designsystem/component/flowboard_top_bar.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/features/workspace/domain/entity/employee.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document.dart';
import 'package:flowboard/features/workspace/presentation/state/my_profile_ui_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/detail_row.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/employee_avatar.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/message_state.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/status_chip.dart';
import 'package:flowboard/features/workspace/presentation/ui/components/workspace_labels.dart';
import 'package:flowboard/features/workspace/presentation/ui/navigation/workspace_navigation.dart';
import 'package:flowboard/features/workspace/presentation/viewmodel/my_profile_view_model.dart';

/// Profile of the signed-in employee with shortcuts to the record and the organization chart.
class MyProfileScreen extends StatefulWidget {
  /// Creates the screen.
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final MyProfileViewModel _viewModel = getIt<MyProfileViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (BuildContext context, Widget? child) {
          final MyProfileUiState state = _viewModel.state;
          return Column(
            children: <Widget>[
              FlowboardTopBar(title: 'Mi perfil', onBack: navigator.canPop() ? () => navigator.maybePop() : null),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyProfileUiState state) {
    final Employee? employee = state.employee;
    if (state.isLoading && employee == null) return const SkeletonDetail(showTabs: false);
    if (employee == null) {
      return MessageState(
        title: 'Perfil no disponible',
        message: state.errorMessage ?? 'No se pudo cargar tu perfil.',
        actionLabel: 'Reintentar',
        onAction: _viewModel.load,
        topPadding: AppSpacing.xl,
      );
    }
    final Employee? manager = state.directManager;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8, AppSpacing.screenHorizontal, AppSpacing.xl + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          _ProfileCard(employee: employee),
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(WorkspaceRoutes.myRecord),
                  icon: const Icon(FlowboardIcons.folder, size: 18),
                  label: const Text('Mi expediente'),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(
                    WorkspaceRoutes.organizationChart,
                    arguments: OrganizationChartArgs(areaId: employee.areaId, highlightedEmployeeId: employee.id.value),
                  ),
                  icon: const Icon(FlowboardIcons.accountTree, size: 18),
                  label: const Text('Organigrama'),
                ),
              ),
            ],
          ),
          const SectionTitle('Datos laborales', topPadding: AppSpacing.m + 8),
          InfoPanel(
            children: <Widget>[
              DetailRow(
                label: 'Jefe directo',
                value: manager == null ? 'Sin jefe directo' : '${manager.name.fullName} · ${manager.positionTitle}',
              ),
              DetailRow(label: 'Fecha de ingreso', value: formatDisplayDate(employee.employmentPeriod.hireDate)),
              const _LockedRow(label: 'Sueldo asignado', value: 'S/ ••••••'),
            ],
          ),
          const SectionTitle('Datos personales', topPadding: AppSpacing.m + 8),
          InfoPanel(
            children: <Widget>[
              DetailRow(label: 'Documento de identidad', value: _masked(employee.identityDocument)),
              DetailRow(label: 'Correo electrónico', value: employee.email.value),
            ],
          ),
        ],
      ),
    );
  }

  /// Masks the document number, for example "DNI 4•••••30": only the first digit and the last
  /// two are shown.
  String _masked(IdentityDocument document) {
    final String number = document.number;
    final String visible = number.length > 3
        ? '${number[0]}${'•' * (number.length - 3)}${number.substring(number.length - 2)}'
        : number;
    return '${document.type.label} $visible';
  }
}

/// Glass card with the avatar, name, job and status of the current user.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          spacing: 6,
          children: <Widget>[
            EmployeeAvatar(initials: employee.name.initials, size: 72),
            Text(employee.name.fullName, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
            Text(
              employee.jobDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            StatusChip(status: employee.status),
          ],
        ),
      ),
    );
  }
}

/// Detail row whose value is hidden, marked with a lock icon.
class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          Icon(
            FlowboardIcons.lock,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
            semanticLabel: 'Dato protegido',
          ),
        ],
      ),
    );
  }
}
