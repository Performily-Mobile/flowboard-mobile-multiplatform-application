/// Vacation balance as returned by the API.
class VacationBalanceDto {
  /// Creates the DTO.
  const VacationBalanceDto({
    required this.employeeId,
    required this.employeeName,
    required this.areaName,
    required this.accruedDays,
    required this.usedDays,
    required this.availableDays,
    required this.lastAccrualDate,
    required this.movements,
  });

  /// Reads the DTO from its JSON.
  factory VacationBalanceDto.fromJson(Map<String, dynamic> json) {
    return VacationBalanceDto(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String?,
      areaName: json['areaName'] as String?,
      accruedDays: (json['accruedDays'] as num?)?.toDouble() ?? 0,
      usedDays: (json['usedDays'] as num?)?.toDouble() ?? 0,
      availableDays: (json['availableDays'] as num?)?.toDouble() ?? 0,
      lastAccrualDate: json['lastAccrualDate'] as String?,
      movements: (json['movements'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic item) => VacationMovementDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int employeeId;
  final String? employeeName;
  final String? areaName;
  final double accruedDays;
  final double usedDays;
  final double availableDays;
  final String? lastAccrualDate;
  final List<VacationMovementDto> movements;

  /// JSON of the DTO, used to keep the offline copy.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'employeeId': employeeId,
        'employeeName': employeeName,
        'areaName': areaName,
        'accruedDays': accruedDays,
        'usedDays': usedDays,
        'availableDays': availableDays,
        'lastAccrualDate': lastAccrualDate,
        'movements': movements.map((VacationMovementDto movement) => movement.toJson()).toList(),
      };
}

/// Movement of a vacation balance as returned by the API.
class VacationMovementDto {
  /// Creates the DTO.
  const VacationMovementDto({
    required this.id,
    required this.type,
    required this.days,
    required this.reason,
    required this.authorId,
    required this.authorName,
    required this.requestId,
    required this.occurredAt,
  });

  /// Reads the DTO from its JSON.
  factory VacationMovementDto.fromJson(Map<String, dynamic> json) {
    return VacationMovementDto(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      days: (json['days'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String?,
      authorId: (json['authorId'] as num?)?.toInt(),
      authorName: json['authorName'] as String?,
      requestId: (json['requestId'] as num?)?.toInt(),
      occurredAt: json['occurredAt'] as String,
    );
  }

  final int id;
  final String type;
  final double days;
  final String? reason;
  final int? authorId;
  final String? authorName;
  final int? requestId;
  final String occurredAt;

  /// JSON of the DTO, used to keep the offline copy.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'days': days,
        'reason': reason,
        'authorId': authorId,
        'authorName': authorName,
        'requestId': requestId,
        'occurredAt': occurredAt,
      };
}

/// Body of a manual adjustment of a vacation balance.
class AdjustVacationBalanceRequestDto {
  /// Creates the DTO.
  const AdjustVacationBalanceRequestDto({
    required this.operation,
    required this.days,
    required this.reason,
    required this.authorId,
  });

  final String operation;
  final double days;
  final String reason;
  final int authorId;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'operation': operation, 'days': days, 'reason': reason, 'authorId': authorId};
}
