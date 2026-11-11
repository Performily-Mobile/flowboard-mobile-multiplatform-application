import 'package:flutter/widgets.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/legal_screen.dart';

/// Routes of the IAM bounded context.
///
/// The login and the mandatory password change are not routes: the app shows them while there is
/// no session or the session asks for a new password.
class IamRoutes {
  const IamRoutes._();

  /// Terms of service and privacy policy.
  static const String legal = '/legal';
}

/// Page builder of the IAM routes, registered in the core route registry.
class IamNavigation {
  const IamNavigation._();

  /// Page of [settings], or null when the route does not belong to IAM.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case IamRoutes.legal:
        return const LegalScreen();
    }
    return null;
  }
}
