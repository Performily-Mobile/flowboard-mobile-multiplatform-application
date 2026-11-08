import 'package:url_launcher/url_launcher.dart';

/// Opens the temporary link of a payslip PDF outside the app; returns false when it cannot.
Future<bool> openPayslipLink(String url) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
