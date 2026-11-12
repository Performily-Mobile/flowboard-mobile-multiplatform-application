/// Reads an integer that the API may send as any JSON number.
int _int(Object? value) => (value as num).toInt();

/// Payslip as returned by the API (PayslipResource).
class PayslipDto {
  /// Creates the DTO.
  const PayslipDto({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.payrollPeriodId,
    required this.periodYear,
    required this.periodMonth,
    required this.periodLabel,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.issueDate,
    required this.netAmount,
    required this.currency,
    required this.publicationStatus,
    required this.publishedAt,
    required this.paymentStatus,
    required this.paidOn,
    required this.observationReason,
  });

  /// Reads the DTO from its JSON.
  factory PayslipDto.fromJson(Map<String, dynamic> json) {
    return PayslipDto(
      id: _int(json['id']),
      employeeId: _int(json['employeeId']),
      employeeName: json['employeeName'] as String?,
      payrollPeriodId: _int(json['payrollPeriodId']),
      periodYear: _int(json['periodYear']),
      periodMonth: _int(json['periodMonth']),
      periodLabel: json['periodLabel'] as String?,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String?,
      sizeInBytes: _int(json['sizeInBytes']),
      issueDate: json['issueDate'] as String,
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String?,
      publicationStatus: json['publicationStatus'] as String,
      publishedAt: json['publishedAt'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      paidOn: json['paidOn'] as String?,
      observationReason: json['observationReason'] as String?,
    );
  }

  final int id;
  final int employeeId;
  final String? employeeName;
  final int payrollPeriodId;
  final int periodYear;
  final int periodMonth;
  final String? periodLabel;
  final String fileName;
  final String? contentType;
  final int sizeInBytes;
  final String issueDate;
  final double netAmount;
  final String? currency;
  final String publicationStatus;
  final String? publishedAt;
  final String paymentStatus;
  final String? paidOn;
  final String? observationReason;
}

/// Payslip with the employer data as returned by the API (PayslipDetailResource).
class PayslipDetailDto {
  /// Creates the DTO.
  const PayslipDetailDto({required this.payslip, required this.companyLegalName, required this.companyTaxId});

  /// Reads the DTO from its JSON.
  factory PayslipDetailDto.fromJson(Map<String, dynamic> json) {
    return PayslipDetailDto(
      payslip: PayslipDto.fromJson(json['payslip'] as Map<String, dynamic>),
      companyLegalName: json['companyLegalName'] as String?,
      companyTaxId: json['companyTaxId'] as String?,
    );
  }

  final PayslipDto payslip;
  final String? companyLegalName;
  final String? companyTaxId;
}

/// Temporary download link as returned by the API (PayslipDownloadUrlResource).
class PayslipDownloadUrlDto {
  /// Creates the DTO.
  const PayslipDownloadUrlDto({
    required this.downloadUrl,
    required this.fileName,
    required this.contentType,
    required this.expiresAt,
  });

  /// Reads the DTO from its JSON.
  factory PayslipDownloadUrlDto.fromJson(Map<String, dynamic> json) {
    return PayslipDownloadUrlDto(
      downloadUrl: json['downloadUrl'] as String,
      fileName: json['fileName'] as String?,
      contentType: json['contentType'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  final String downloadUrl;
  final String? fileName;
  final String? contentType;
  final String? expiresAt;
}

/// Body to upload a payslip (POST payslips) or replace its file (PUT payslips/{id}/file).
class PayslipFileRequestDto {
  /// Creates the DTO; [employeeId] and [payrollPeriodId] are only sent when uploading.
  const PayslipFileRequestDto({
    this.employeeId,
    this.payrollPeriodId,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.storageUrl,
    required this.issueDate,
    required this.netAmount,
    required this.currency,
  });

  final int? employeeId;
  final int? payrollPeriodId;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final String storageUrl;
  final String issueDate;
  final double netAmount;
  final String currency;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (employeeId != null) 'employeeId': employeeId,
        if (payrollPeriodId != null) 'payrollPeriodId': payrollPeriodId,
        'fileName': fileName,
        'contentType': contentType,
        'sizeInBytes': sizeInBytes,
        'storageUrl': storageUrl,
        'issueDate': issueDate,
        'netAmount': netAmount,
        'currency': currency,
      };
}
