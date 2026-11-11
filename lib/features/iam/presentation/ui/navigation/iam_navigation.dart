import 'package:flutter/widgets.dart';
import 'package:flowboard/core/navigation/app_routes.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/account_security_screen.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/accounts_screen.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/legal_screen.dart';
import 'package:flowboard/features/iam/presentation/ui/screens/password_change_screen.dart';

/// Routes of the IAM bounded context.
///
/// "Cuenta y seguridad", opened from "Más", reuses the name of the core navigation. The login and
/// the mandatory password change are not routes: the app shows them while there is no session or
/// the session asks for a new password.
class IamRoutes {
  const IamRoutes._();

  static const String account = AppRoutes.account;

  /// Accounts of the employees, only for the HR staff.
  static const String accounts = '/accounts';

  /// Terms of service and privacy policy.
  static const String legal = '/legal';

  /// Change of the password started by the user; closes with the result message.
  static const String changePassword = '/change-password';
}

/// Page builder of the IAM routes, registered in the core route registry.
class IamNavigation {
  const IamNavigation._();

  /// Page of [settings], or null when the route does not belong to IAM.
  static Widget? pageFor(RouteSettings settings) {
    switch (settings.name) {
      case IamRoutes.account:
        return const AccountSecurityScreen();
      case IamRoutes.accounts:
        return const AccountsScreen();
      case IamRoutes.legal:
        return const LegalScreen();
      case IamRoutes.changePassword:
        return const PasswordChangeScreen();
    }
    return null;
  }
}
