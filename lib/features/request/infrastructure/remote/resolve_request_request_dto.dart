/// Body to approve, reject, return or cancel a request.
class ResolveRequestRequestDto {
  /// Creates the body.
  const ResolveRequestRequestDto({required this.actorId, this.comment});

  final int actorId;
  final String? comment;

  /// JSON of the body.
  Map<String, dynamic> toJson() => <String, dynamic>{'actorId': actorId, 'comment': comment};
}
