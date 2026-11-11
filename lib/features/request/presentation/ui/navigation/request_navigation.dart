import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/request/presentation/ui/screens/new_request_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/new_request_type_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/request_detail_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/request_types_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/requests_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/resolved_requests_screen.dart';
import 'package:flowboard/features/request/presentation/ui/screens/review_request_screen.dart';

/// Routes of the Request bounded context.
///
/// The "Solicitudes" tab, the catalog of types and the review opened from the dashboard reuse the
/// names of the core navigation. The new request and the new type are full-screen forms pushed on
/// the root navigator, so the bottom bar is hidden while they are open. The screens that finish an
/// action close with a message for the snackbar of the previous screen.
class RequestRoutes {
  const RequestRoutes._();

  static const String requests = AppRoutes.requests;
  static const String newRequest = '/new-request';

  /// Detail of one of the viewer's requests; receives the request identifier.
  static const String requestDetail = '/request-detail';

  /// Review of a request by its approver; receives the request identifier.
  static const String reviewRequest = AppRoutes.reviewRequest;
  static const String resolvedRequests = '/resolved-requests';
  static const String requestTypes = AppRoutes.requestTypes;
  static const String newRequestType = '/new-request-type';
}

/// Page builder of the Request routes, registered in the core route registry.
class RequestNavigation {
  const RequestNavigation._();

  /// Page of [settings], or null when the route does not belong to Request.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case RequestRoutes.requests:
        return const RequestsScreen();
      case RequestRoutes.newRequest:
        return const NewRequestScreen();
      case RequestRoutes.requestDetail:
        return RequestDetailScreen(requestId: settings.arguments as int);
      case RequestRoutes.reviewRequest:
        return ReviewRequestScreen(requestId: settings.arguments as int);
      case RequestRoutes.resolvedRequests:
        return const ResolvedRequestsScreen();
      case RequestRoutes.requestTypes:
        return const RequestTypesScreen();
      case RequestRoutes.newRequestType:
        return const NewRequestTypeScreen();
    }
    return null;
  }
}
