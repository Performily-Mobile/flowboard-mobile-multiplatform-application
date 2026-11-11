/// Employee as seen by the Request context: only what is needed to name requesters and approvers.
class RequestPerson {
  /// Creates the person.
  const RequestPerson({
    required this.id,
    required this.name,
    required this.jobDescription,
    required this.directManagerId,
  });

  final int id;

  /// Full name, for example "Ana Torres".
  final String name;

  /// "Position · Area".
  final String jobDescription;

  final int? directManagerId;
}
