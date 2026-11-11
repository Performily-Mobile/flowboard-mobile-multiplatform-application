/// Status of an account. Only active accounts can sign in.
enum AccountStatus {
  active,
  disabled;

  /// True when the account can sign in.
  bool get isActive => this == AccountStatus.active;
}
