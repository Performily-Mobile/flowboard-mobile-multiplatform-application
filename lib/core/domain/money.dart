/// Amount of money in a currency.
class Money {
  /// Default currency of the app (Peruvian sol).
  static const String defaultCurrency = 'PEN';

  /// Creates the amount; throws [ArgumentError] when [amount] is negative or the currency
  /// code does not have 3 letters.
  Money({required this.amount, this.currency = defaultCurrency}) {
    if (amount < 0) {
      throw ArgumentError('El monto no puede ser negativo.');
    }
    if (currency.length != 3) {
      throw ArgumentError('La moneda debe tener 3 letras.');
    }
  }

  final double amount;
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
