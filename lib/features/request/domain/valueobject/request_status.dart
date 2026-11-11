/// Status of a request along its approval flow.
enum RequestStatus {
  inProgress,
  underReview,
  approved,
  rejected,
  cancelled;

  /// True when the request was already resolved and cannot change anymore.
  bool get isFinal =>
      this == RequestStatus.approved || this == RequestStatus.rejected || this == RequestStatus.cancelled;
}
