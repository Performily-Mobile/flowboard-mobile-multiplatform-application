/// Temporary link to download the PDF of a payslip.
class PayslipDownloadLink {
  /// Creates the link.
  const PayslipDownloadLink({
    required this.downloadUrl,
    required this.fileName,
    required this.contentType,
    required this.expiresAt,
  });

  final String downloadUrl;
  final String fileName;
  final String contentType;
  final DateTime? expiresAt;
}
