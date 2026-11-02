import 'package:flowboard/core/domain/money.dart';

/// Position of an area with its minimum reference salary.
class Position {
  /// Creates the position.
  const Position({
    required this.id,
    required this.title,
    required this.areaId,
    required this.areaName,
    required this.referenceSalary,
    required this.active,
  });

  final int id;
  final String title;
  final int areaId;
  final String areaName;
  final Money referenceSalary;
  final bool active;

  /// True when the position belongs to the area [areaId].
  bool belongsTo(int areaId) => this.areaId == areaId;

  @override
  bool operator ==(Object other) => other is Position && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
