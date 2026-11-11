/// Role of an account. It decides which screens the account can use.
enum AccountRole {
  humanResources,
  employee;

  /// True when the account belongs to the HR staff.
  bool get isHumanResources => this == AccountRole.humanResources;
}
