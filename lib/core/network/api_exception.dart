/// Error returned by the backend.
///
/// [code] is the backend error code (null when the failure is not an API error), [message]
/// is a generic text describing the type of error and [details] the concrete reason, such as
/// the business rule that was violated.
class ApiException implements Exception {
  /// Creates the exception.
  const ApiException({this.code, required this.message, this.details});

  final String? code;
  final String message;
  final String? details;

  @override
  String toString() => message;
}
