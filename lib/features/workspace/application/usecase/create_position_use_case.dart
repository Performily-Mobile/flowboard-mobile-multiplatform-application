import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/workspace/domain/entity/position.dart';
import 'package:flowboard/features/workspace/domain/repository/position_repository.dart';

/// Creates a position inside an area.
class CreatePositionUseCase {
  /// Creates the use case.
  const CreatePositionUseCase({required this.repository});

  final PositionRepository repository;

  /// Creates the position; throws [ArgumentError] when the title is blank or longer than 80
  /// characters.
  Future<Position> execute(String title, int areaId, Money referenceSalary) {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) throw ArgumentError('El nombre de la posición es obligatorio.');
    if (trimmedTitle.length > 80) throw ArgumentError('El nombre admite hasta 80 caracteres.');
    return repository.createPosition(trimmedTitle, areaId, referenceSalary);
  }
}
