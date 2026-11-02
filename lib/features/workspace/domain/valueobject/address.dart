/// Postal address of an employee. Every part is optional.
class Address {
  /// Creates the address.
  const Address({this.street, this.district, this.province, this.department});

  final String? street;
  final String? district;
  final String? province;
  final String? department;

  List<String?> get _parts => <String?>[street, district, province, department];

  /// True when no part of the address is filled.
  bool get isEmpty => _parts.every((String? part) => part == null || part.trim().isEmpty);

  /// Filled parts joined by commas.
  String get formatted =>
      _parts.where((String? part) => part != null && part.trim().isNotEmpty).cast<String>().join(', ');
}
