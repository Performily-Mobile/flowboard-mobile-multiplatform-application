/// Group of documents of the employee record.
enum DocumentCategory { contract, certificate, personal }

/// Type of a document of the employee record and the category it belongs to.
enum DocumentType {
  identityDocument(DocumentCategory.personal),
  employmentContract(DocumentCategory.contract),
  contractAddendum(DocumentCategory.contract),
  pensionAffiliation(DocumentCategory.personal),
  healthInsurance(DocumentCategory.personal),
  educationCertificate(DocumentCategory.certificate),
  criminalRecordCertificate(DocumentCategory.certificate),
  warningLetter(DocumentCategory.contract),
  commendationLetter(DocumentCategory.certificate),
  certificateOfEmployment(DocumentCategory.certificate);

  const DocumentType(this.category);

  final DocumentCategory category;
}
