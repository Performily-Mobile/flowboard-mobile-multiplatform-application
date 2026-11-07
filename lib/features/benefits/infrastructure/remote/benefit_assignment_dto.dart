/// Reads an integer that the API may send as any JSON number.
int _int(Object? value) => (value as num).toInt();

/// Reads an optional integer.
int? _intOrNull(Object? value) => (value as num?)?.toInt();

/// Reads a list of objects, empty when the API omits it.
List<T> _list<T>(Object? value, T Function(Map<String, dynamic> json) read) =>
    (value as List<dynamic>? ?? const <dynamic>[]).map((dynamic item) => read(item as Map<String, dynamic>)).toList();

/// Benefit assignment as returned by the API.
class BenefitAssignmentDto {
  /// Creates the DTO.
  const BenefitAssignmentDto({
    required this.id,
    required this.benefitTypeId,
    required this.benefitTypeName,
    required this.unit,
    required this.employeeId,
    required this.employeeName,
    required this.sourceAreaId,
    required this.quantity,
    required this.displayQuantity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.delivery,
  });

  /// Reads the DTO from its JSON.
  factory BenefitAssignmentDto.fromJson(Map<String, dynamic> json) {
    final Object? delivery = json['delivery'];
    return BenefitAssignmentDto(
      id: _int(json['id']),
      benefitTypeId: _int(json['benefitTypeId']),
      benefitTypeName: json['benefitTypeName'] as String?,
      unit: json['unit'] as String,
      employeeId: _int(json['employeeId']),
      employeeName: json['employeeName'] as String?,
      sourceAreaId: _intOrNull(json['sourceAreaId']),
      quantity: (json['quantity'] as num).toDouble(),
      displayQuantity: json['displayQuantity'] as String?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: json['status'] as String,
      delivery: delivery == null ? null : BenefitDeliveryDto.fromJson(delivery as Map<String, dynamic>),
    );
  }

  final int id;
  final int benefitTypeId;
  final String? benefitTypeName;
  final String unit;
  final int employeeId;
  final String? employeeName;
  final int? sourceAreaId;
  final double quantity;
  final String? displayQuantity;
  final String startDate;
  final String endDate;
  final String status;
  final BenefitDeliveryDto? delivery;
}

/// Delivery of an assignment as returned by the API.
class BenefitDeliveryDto {
  /// Creates the DTO.
  const BenefitDeliveryDto({required this.deliveredOn, required this.registeredById, required this.notes});

  /// Reads the DTO from its JSON.
  factory BenefitDeliveryDto.fromJson(Map<String, dynamic> json) {
    return BenefitDeliveryDto(
      deliveredOn: json['deliveredOn'] as String,
      registeredById: _intOrNull(json['registeredById']),
      notes: json['notes'] as String?,
    );
  }

  final String deliveredOn;
  final int? registeredById;
  final String? notes;
}

/// Result of an assignment as returned by the API.
class BenefitAssignmentBatchDto {
  /// Creates the DTO.
  const BenefitAssignmentBatchDto({
    required this.areaId,
    required this.assignedCount,
    required this.skippedCount,
    required this.skippedEmployeeIds,
    required this.assignments,
  });

  /// Reads the DTO from its JSON.
  factory BenefitAssignmentBatchDto.fromJson(Map<String, dynamic> json) {
    return BenefitAssignmentBatchDto(
      areaId: _intOrNull(json['areaId']),
      assignedCount: _intOrNull(json['assignedCount']) ?? 0,
      skippedCount: _intOrNull(json['skippedCount']) ?? 0,
      skippedEmployeeIds: (json['skippedEmployeeIds'] as List<dynamic>? ?? const <dynamic>[]).map(_int).toList(),
      assignments: _list(json['assignments'], BenefitAssignmentDto.fromJson),
    );
  }

  final int? areaId;
  final int assignedCount;
  final int skippedCount;
  final List<int> skippedEmployeeIds;
  final List<BenefitAssignmentDto> assignments;
}

/// Benefits of an employee as returned by the API.
class EmployeeBenefitsDto {
  /// Creates the DTO.
  const EmployeeBenefitsDto({
    required this.employeeId,
    required this.currentCount,
    required this.deliveredCount,
    required this.current,
    required this.delivered,
  });

  /// Reads the DTO from its JSON.
  factory EmployeeBenefitsDto.fromJson(Map<String, dynamic> json) {
    return EmployeeBenefitsDto(
      employeeId: _int(json['employeeId']),
      currentCount: _intOrNull(json['currentCount']) ?? 0,
      deliveredCount: _intOrNull(json['deliveredCount']) ?? 0,
      current: _list(json['current'], BenefitAssignmentDto.fromJson),
      delivered: _list(json['delivered'], BenefitAssignmentDto.fromJson),
    );
  }

  final int employeeId;
  final int currentCount;
  final int deliveredCount;
  final List<BenefitAssignmentDto> current;
  final List<BenefitAssignmentDto> delivered;
}

/// Preview of an area assignment as returned by the API.
class AreaAssignmentPreviewDto {
  /// Creates the DTO.
  const AreaAssignmentPreviewDto({
    required this.areaId,
    required this.activeEmployees,
    required this.alreadyAssigned,
    required this.toAssign,
  });

  /// Reads the DTO from its JSON.
  factory AreaAssignmentPreviewDto.fromJson(Map<String, dynamic> json) {
    return AreaAssignmentPreviewDto(
      areaId: _int(json['areaId']),
      activeEmployees: _intOrNull(json['activeEmployees']) ?? 0,
      alreadyAssigned: _intOrNull(json['alreadyAssigned']) ?? 0,
      toAssign: _intOrNull(json['toAssign']) ?? 0,
    );
  }

  final int areaId;
  final int activeEmployees;
  final int alreadyAssigned;
  final int toAssign;
}

/// Body to assign a benefit. It carries [employeeId] or [areaId], never both.
class AssignBenefitRequestDto {
  /// Creates the DTO.
  const AssignBenefitRequestDto({
    required this.benefitTypeId,
    required this.employeeId,
    required this.areaId,
    required this.quantity,
    required this.startDate,
    required this.endDate,
  });

  final int benefitTypeId;
  final int? employeeId;
  final int? areaId;
  final double quantity;
  final String startDate;
  final String endDate;

  /// JSON sent to the API; the target that is null is left out.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'benefitTypeId': benefitTypeId,
        if (employeeId != null) 'employeeId': employeeId,
        if (areaId != null) 'areaId': areaId,
        'quantity': quantity,
        'startDate': startDate,
        'endDate': endDate,
      };
}

/// Body to register the delivery of an assignment.
class RegisterDeliveryRequestDto {
  /// Creates the DTO.
  const RegisterDeliveryRequestDto({required this.deliveredOn, required this.registeredById, required this.notes});

  final String deliveredOn;
  final int? registeredById;
  final String? notes;

  /// JSON sent to the API.
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'deliveredOn': deliveredOn, 'registeredById': registeredById, 'notes': notes};
}
