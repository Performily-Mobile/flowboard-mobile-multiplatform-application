import 'package:intl/intl.dart';
import 'package:flowboard/core/domain/money.dart';
import 'package:flowboard/features/payroll/domain/valueobject/payment_status.dart';

/// Texts and formats of Payroll exactly as they appear in the prototype (MA-64 to MA-69).
class PayrollFormatters {
  const PayrollFormatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  /// "S/ 2,480.00"; other currencies keep their code.
  static String money(Money money) => '${_symbol(money)} ${_money.format(money.amount)}';

  /// "S/ •,•••.••": the amount is hidden while HR decides on a duplicated payslip (MA-68).
  static String maskedMoney(Money money) => '${_symbol(money)} •,•••.••';

  /// "Pago total S/ 2,480.00".
  static String total(String amount) => 'Pago total $amount';

  /// Date as dd/MM/yyyy.
  static String date(DateTime date) => '${_two(date.day)}/${_two(date.month)}/${date.year}';

  /// Date as dd/MM.
  static String shortDate(DateTime date) => '${_two(date.day)}/${_two(date.month)}';

  /// "1 boleta cargada", "248 boletas cargadas".
  static String uploadedCount(int count) => count == 1 ? '1 boleta cargada' : '$count boletas cargadas';

  /// "Publicar 1 boleta", "Publicar 248 boletas".
  static String publishLabel(int count) => count == 1 ? 'Publicar 1 boleta' : 'Publicar $count boletas';

  /// "3 boletas con depósito pendiente" (MA-69).
  static String reportCount(int count, PaymentStatus? status) {
    final String noun = count == 1 ? 'boleta' : 'boletas';
    final String detail = switch (status) {
      PaymentStatus.pending => 'con depósito pendiente',
      PaymentStatus.paid => 'con depósito registrado',
      PaymentStatus.observed => 'con depósito observado',
      null => count == 1 ? 'publicada' : 'publicadas',
    };
    return '$count $noun $detail';
  }

  /// True when every word of [query] appears in one of [texts]; case and accents are ignored.
  static bool matches(List<String> texts, String query) {
    final String haystack = _normalize(texts.join(' '));
    return _normalize(query).split(RegExp(r'\s+')).where((String word) => word.isNotEmpty).every(haystack.contains);
  }

  static String _normalize(String text) {
    const String from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const String to = 'aaaaeeeeiiiioooouuuun';
    final StringBuffer buffer = StringBuffer();
    for (final int rune in text.toLowerCase().runes) {
      final String char = String.fromCharCode(rune);
      final int index = from.indexOf(char);
      buffer.write(index < 0 ? char : to[index]);
    }
    return buffer.toString();
  }

  static String _symbol(Money money) => money.currency == Money.defaultCurrency ? 'S/' : money.currency;

  static String _two(int value) => value.toString().padLeft(2, '0');
}
