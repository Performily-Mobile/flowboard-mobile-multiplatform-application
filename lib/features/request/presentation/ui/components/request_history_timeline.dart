import 'package:flutter/material.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_colors.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_formatters.dart';

/// One step of the history of a request.
class TimelineItem {
  /// Creates the step; [isCurrent] marks the step where the request is now.
  const TimelineItem({required this.title, required this.detail, this.isCurrent = false});

  final String title;
  final String detail;
  final bool isCurrent;

  /// Copy marked as the current step.
  TimelineItem asCurrent() => TimelineItem(title: title, detail: detail, isCurrent: true);
}

/// Vertical list of the steps of a request, with a dot per step.
class RequestHistoryTimeline extends StatelessWidget {
  /// Creates the timeline.
  const RequestHistoryTimeline({super.key, required this.items});

  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: <Widget>[
        for (final TimelineItem item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isCurrent ? RequestColors.timelineCurrent : RequestColors.timelinePast,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: <Widget>[
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    Text(
                      item.detail,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Steps of the history of [request] as seen by [viewerId].
List<TimelineItem> timelineOf(Request request, int viewerId) {
  final List<TimelineItem> items = <TimelineItem>[];
  String who(int? actorId, String? actorName) {
    if (actorId == null) return 'sistema';
    if (actorId == viewerId) return 'por ti';
    return actorName == null ? 'Colaborador #$actorId' : RequestFormatters.shortName(actorName);
  }

  for (final RequestHistoryEntry entry in request.history) {
    final String time = RequestFormatters.shortDateTime(entry.occurredAt);
    final String actor = who(entry.actorId, entry.actorName);
    if (entry.previousStatus == null) {
      items.add(TimelineItem(title: 'Solicitud enviada', detail: '$time · $actor'));
      if (request.history.length == 1) {
        items.add(request.approverType == ApproverType.hrStaff
            ? TimelineItem(title: 'Asignada a Recursos Humanos', detail: '$time · sin jefe directo')
            : TimelineItem(
                title: 'Asignada a ${RequestFormatters.shortName(request.approverName)}',
                detail: '$time · jefe directo',
              ));
      }
      continue;
    }
    switch (entry.newStatus) {
      case RequestStatus.underReview:
        items.add(TimelineItem(title: 'Devuelta a revisión', detail: '$time · $actor'));
      case RequestStatus.inProgress:
        items.add(TimelineItem(title: 'Solicitud reenviada', detail: '$time · $actor'));
      case RequestStatus.approved:
        items.add(TimelineItem(title: 'Aprobada', detail: '$time · $actor'));
      case RequestStatus.rejected:
        final String? comment = entry.comment;
        items.add(TimelineItem(
          title: 'Rechazada',
          detail: comment == null ? '$time · $actor' : '$time · $actor\nMotivo: $comment',
        ));
      case RequestStatus.cancelled:
        items.add(TimelineItem(title: 'Cancelada', detail: '$time · $actor'));
    }
  }

  if (request.status == RequestStatus.inProgress) {
    items.add(const TimelineItem(title: 'Pendiente', detail: 'Esperando la decisión del aprobador', isCurrent: true));
  } else if (items.isNotEmpty) {
    items[items.length - 1] = items.last.asCurrent();
  }
  return items;
}
