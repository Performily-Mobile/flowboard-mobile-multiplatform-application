import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/repository/request_type_repository.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';

/// Creates a request type with its fields.
class CreateRequestTypeUseCase {
  /// Creates the use case.
  const CreateRequestTypeUseCase({required this.repository});

  final RequestTypeRepository repository;

  static const int maxName = 80;
  static const int maxDescription = 255;

  static const Map<String, String> _accents = <String, String>{
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
    'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ü': 'U', 'Ñ': 'N',
  };

  /// Creates the type; throws [ArgumentError] when the name or the description break a rule, or
  /// when two fields have the same key.
  Future<RequestType> execute({
    required String name,
    required String description,
    required bool requiresAttachment,
    required BalanceDeduction balanceDeduction,
    required List<NewRequestField> fields,
  }) {
    final String cleanName = name.trim();
    final String cleanDescription = description.trim();
    if (cleanName.isEmpty) throw ArgumentError('Ingresa el nombre del tipo de solicitud.');
    if (cleanName.length > maxName) throw ArgumentError('El nombre admite hasta $maxName caracteres.');
    if (cleanDescription.length > maxDescription) {
      throw ArgumentError('La descripción admite hasta $maxDescription caracteres.');
    }
    if (fields.map((NewRequestField field) => field.key).toSet().length != fields.length) {
      throw ArgumentError('Hay dos campos con el mismo nombre.');
    }
    return repository.createRequestType(
      name: cleanName,
      description: cleanDescription.isEmpty ? null : cleanDescription,
      requiresAttachment: requiresAttachment,
      balanceDeduction: balanceDeduction,
      fields: fields,
    );
  }

  /// camelCase key of a field built from its [label], not repeated in [existingKeys].
  ///
  /// For example "Motivo del viaje" becomes "motivoDelViaje".
  static String keyFor(String label, Iterable<String> existingKeys) {
    final String plain = label.split('').map((String char) => _accents[char] ?? char).join();
    final List<String> words = plain
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      final String lower = words[i].toLowerCase();
      buffer.write(i == 0 ? lower : '${lower[0].toUpperCase()}${lower.substring(1)}');
    }
    String base = buffer.toString();
    if (base.isEmpty || !RegExp(r'^[A-Za-z]').hasMatch(base)) base = 'campo$base';
    if (base.length < 2) base = '${base}Valor';
    if (base.length > 45) base = base.substring(0, 45);
    final Set<String> taken = existingKeys.toSet();
    String key = base;
    int counter = 2;
    while (taken.contains(key)) {
      key = '$base${counter++}';
    }
    return key;
  }
}
