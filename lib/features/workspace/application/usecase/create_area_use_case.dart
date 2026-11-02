import 'package:flowboard/features/workspace/domain/entity/area.dart';
import 'package:flowboard/features/workspace/domain/repository/area_repository.dart';

/// Creates an area of the organization.
class CreateAreaUseCase {
  /// Creates the use case.
  const CreateAreaUseCase({required this.repository});

  final AreaRepository repository;

  /// Creates the area; throws [ArgumentError] when the name is blank or longer than 80 characters.
  Future<Area> execute(String name, String? description) {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError('El nombre del área es obligatorio.');
    if (trimmedName.length > 80) throw ArgumentError('El nombre admite hasta 80 caracteres.');
    final String? trimmedDescription = description?.trim();
    return repository.createArea(
      trimmedName,
      trimmedDescription == null || trimmedDescription.isEmpty ? null : trimmedDescription,
    );
  }
}
