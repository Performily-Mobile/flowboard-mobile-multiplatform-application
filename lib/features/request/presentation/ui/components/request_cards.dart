import 'package:flutter/material.dart';
import 'package:flowboard/core/designsystem/component/flowboard_overflow_menu.dart';
import 'package:flowboard/core/designsystem/component/glass_card.dart';
import 'package:flowboard/core/designsystem/icon/flowboard_icons.dart';
import 'package:flowboard/core/designsystem/theme/app_spacing.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_common.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';

const EdgeInsets _cardPadding = EdgeInsets.all(AppSpacing.l);

/// Card of one of the viewer's own requests: type, status, period and a short detail.
class MyRequestCard extends StatelessWidget {
  /// Creates the card.
  const MyRequestCard({super.key, required this.request, required this.onTap});

  final Request request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s,
        children: <Widget>[
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              Expanded(
                child: Text(
                  request.requestTypeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              RequestStatusChip(status: request.status),
            ],
          ),
          Text(
            RequestFormatters.shortPeriod(request.period),
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          Text(
            RequestFormatters.myRequestDetail(request),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

/// Card of a request waiting for the decision of the viewer, with quick reject and approve buttons.
class ApprovalCard extends StatelessWidget {
  /// Creates the card; [canResolve] false hides the buttons because the request is the viewer's own.
  const ApprovalCard({
    super.key,
    required this.request,
    required this.isProcessing,
    required this.canResolve,
    required this.onTap,
    required this.onReject,
    required this.onApprove,
  });

  final Request request;
  final bool isProcessing;
  final bool canResolve;
  final VoidCallback onTap;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.m,
        children: <Widget>[
          Row(
            spacing: AppSpacing.m,
            children: <Widget>[
              RequestAvatar(name: request.requesterName),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: <Widget>[
                    Text(
                      RequestFormatters.shortName(request.requesterName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      RequestFormatters.approvalSummary(request),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    Text(
                      RequestFormatters.sentAgo(request.submittedAt),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: AppSpacing.s,
            children: <Widget>[
              if (!canResolve)
                Flexible(
                  child: Text(
                    'Es tu solicitud: no puedes resolverla tú.',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                )
              else if (isProcessing)
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              else ...<Widget>[
                OutlinedButton(onPressed: onReject, child: const Text('Rechazar')),
                FilledButton(onPressed: onApprove, child: const Text('Aprobar')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Card of a request of any employee: requester, type, dates, approver and status.
class RequestListRow extends StatelessWidget {
  /// Creates the card.
  const RequestListRow({super.key, required this.request, required this.onTap});

  final Request request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    return GlassCard(
      onTap: onTap,
      padding: _cardPadding,
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          RequestAvatar(name: request.requesterName),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  RequestFormatters.shortName(request.requesterName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${request.requestTypeName} · ${RequestFormatters.shortRange(request.period)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                Text(
                  RequestFormatters.approverLine(request),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          RequestStatusChip(status: request.status),
        ],
      ),
    );
  }
}

/// Card of a request type of the catalog, with its status and a menu to toggle or delete it.
class RequestTypeRow extends StatelessWidget {
  /// Creates the card.
  const RequestTypeRow({super.key, required this.type, required this.onToggleStatus, required this.onDelete});

  final RequestType type;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.xs, AppSpacing.m),
      child: Row(
        spacing: AppSpacing.m,
        children: <Widget>[
          const RequestIconCircle(icon: FlowboardIcons.article),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  type.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  RequestFormatters.typeCatalogDetail(type),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          RequestChip(
            text: type.active ? 'Activo' : 'Inactivo',
            containerColor: type.active ? RequestColors.typeActive : RequestColors.typeInactive,
          ),
          FlowboardOverflowMenu(
            tooltip: 'Opciones de ${type.name}',
            actions: <FlowboardMenuAction>[
              FlowboardMenuAction(label: type.active ? 'Desactivar' : 'Activar', onSelected: onToggleStatus),
              FlowboardMenuAction(label: 'Eliminar', destructive: true, onSelected: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}
