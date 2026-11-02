import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';

/// Identity document of an employee, validated by its type.
class IdentityDocument {
  /// Creates the document; throws [ArgumentError] when [number] does not match the [type].
  IdentityDocument(this.type, this.number) {
    final bool valid = switch (type) {
      IdentityDocumentType.dni => RegExp(r'^\d{8}$').hasMatch(number),
      IdentityDocumentType.ce => RegExp(r'^[A-Za-z0-9]{9,12}$').hasMatch(number),
      IdentityDocumentType.passport => RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(number),
    };
    if (!valid) {
      throw ArgumentError(switch (type) {
        IdentityDocumentType.dni => 'El DNI debe tener exactamente 8 dígitos.',
        IdentityDocumentType.ce => 'El carné de extranjería debe tener de 9 a 12 caracteres alfanuméricos.',
        IdentityDocumentType.passport => 'El pasaporte debe tener de 6 a 12 caracteres alfanuméricos.',
      });
    }
  }

  final IdentityDocumentType type;
  final String number;
}
