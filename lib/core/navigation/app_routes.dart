/// Route names of the app.
///
/// Names have a single segment so a nested [Navigator] can open them as its initial route.
class AppRoutes {
  const AppRoutes._();

  static const String panel = '/panel';
  static const String home = '/home';
  static const String employees = '/employees';
  static const String requests = '/requests';
  static const String attendance = '/attendance';
  static const String payslips = '/payslips';
  static const String more = '/more';
  static const String myProfile = '/my-profile';

  static const String organization = '/organization';
  static const String payroll = '/payroll';
  static const String wellbeing = '/wellbeing';
  static const String benefits = '/benefits';
  static const String myBenefits = '/my-benefits';
  static const String myVacationBalance = '/my-vacation-balance';
  static const String requestTypes = '/request-types';
  static const String account = '/account';

  /// Temporary screen; receives the title as the route argument.
  static const String pendingFeature = '/pending';
}
