import 'package:intl/intl.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/workspace/domain/valueobject/assignment_change_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/contract_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/document_type.dart';
import 'package:flowboard/features/workspace/domain/valueobject/employment_status.dart';
import 'package:flowboard/features/workspace/domain/valueobject/identity_document_type.dart';

final NumberFormat _amountFormat = NumberFormat('#,##0.00', 'en_US');

/// Date as dd/MM/yyyy.
String formatDisplayDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// Spanish label of the employment status.
extension EmploymentStatusLabel on EmploymentStatus {
  /// Text shown to the user.
  String get label => switch (this) {
        EmploymentStatus.active => 'Activo',
        EmploymentStatus.suspended => 'Suspendido',
        EmploymentStatus.terminated => 'Cesado',
      };
}

/// Spanish label of the contract type.
extension ContractTypeLabel on ContractType {
  /// Text shown to the user.
  String get label => switch (this) {
        ContractType.indefinite => 'Plazo indeterminado',
        ContractType.fixedTerm => 'Plazo fijo',
        ContractType.partTime => 'Tiempo parcial',
        ContractType.internship => 'Prácticas',
      };
}

/// Spanish label of the identity document type.
extension IdentityDocumentTypeLabel on IdentityDocumentType {
  /// Text shown to the user.
  String get label => switch (this) {
        IdentityDocumentType.dni => 'DNI',
        IdentityDocumentType.ce => 'CE',
        IdentityDocumentType.passport => 'Pasaporte',
      };
}

/// Spanish label of the job history change.
extension AssignmentChangeTypeLabel on AssignmentChangeType {
  /// Text shown to the user.
  String get label => switch (this) {
        AssignmentChangeType.hire => 'Ingreso',
        AssignmentChangeType.reassignment => 'Reasignación',
        AssignmentChangeType.reinstatement => 'Reincorporación',
      };
}

/// Spanish label of the document category.
extension DocumentCategoryLabel on DocumentCategory {
  /// Text shown to the user.
  String get label => switch (this) {
        DocumentCategory.contract => 'Contrato',
        DocumentCategory.certificate => 'Constancia',
        DocumentCategory.personal => 'Personal',
      };
}

/// Spanish label of the document type.
extension DocumentTypeLabel on DocumentType {
  /// Text shown to the user.
  String get label => switch (this) {
        DocumentType.identityDocument => 'Documento de identidad',
        DocumentType.employmentContract => 'Contrato de trabajo',
        DocumentType.contractAddendum => 'Adenda de contrato',
        DocumentType.pensionAffiliation => 'Afiliación previsional',
        DocumentType.healthInsurance => 'Seguro de salud',
        DocumentType.educationCertificate => 'Certificado de estudios',
        DocumentType.criminalRecordCertificate => 'Certificado de antecedentes',
        DocumentType.warningLetter => 'Carta de amonestación',
        DocumentType.commendationLetter => 'Carta de felicitación',
        DocumentType.certificateOfEmployment => 'Constancia de trabajo',
      };
}

/// Amount with its currency symbol, for example "S/ 2,500.00".
extension MoneyDisplay on Money {
  /// Text shown to the user.
  String get display {
    final String symbol = currency == Money.defaultCurrency ? 'S/' : currency;
    return '$symbol ${_amountFormat.format(amount)}';
  }
}
