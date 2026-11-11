import 'package:intl/intl.dart';
import 'package:flowboard/core/domain/file_reference.dart';
import 'package:flowboard/features/request/domain/entity/request.dart';
import 'package:flowboard/features/request/domain/entity/request_type.dart';
import 'package:flowboard/features/request/domain/valueobject/approver_type.dart';
import 'package:flowboard/features/request/domain/valueobject/balance_deduction.dart';
import 'package:flowboard/features/request/domain/valueobject/field_data_type.dart';
import 'package:flowboard/features/request/domain/valueobject/request_period.dart';
import 'package:flowboard/features/request/domain/valueobject/request_status.dart';
import 'package:flowboard/features/request/domain/valueobject/request_time.dart';
import 'package:flowboard/features/request/presentation/ui/components/request_labels.dart';

/// Texts of the request screens: dates, periods, names and summaries.
class RequestFormatters {
  const RequestFormatters._();

  static final NumberFormat _number = NumberFormat('#,##0.##', 'en_US');
  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  /// Date as dd/MM/yyyy.
  static String date(DateTime date) => '${_two(date.day)}/${_two(date.month)}/${date.year}';

  /// Date as dd/MM.
  static String shortDate(DateTime date) => '${_two(date.day)}/${_two(date.month)}';

  /// Time as HH:mm.
  static String time(RequestTime time) => time.format();

  /// Date and time as "dd/MM/yyyy · HH:mm".
  static String dateTime(DateTime value) => '${date(value)} · ${_two(value.hour)}:${_two(value.minute)}';

  /// Date and time as "dd/MM · HH:mm".
  static String shortDateTime(DateTime value) => '${shortDate(value)} · ${_two(value.hour)}:${_two(value.minute)}';

  /// Code of a request, for example "S-0042".
  static String code(int requestId) => 'S-${requestId.toString().padLeft(4, '0')}';

  /// Initials of the first two words of [name].
  static String initials(String name) {
    return _words(name).take(2).map((String word) => word.substring(0, 1).toUpperCase()).join();
  }

  /// First two words of [name], for example "Ana Torres" of "Ana Torres Ruiz".
  static String shortName(String name) => _words(name).take(2).join(' ');

  /// First word of [name].
  static String firstName(String name) {
    final List<String> words = _words(name);
    return words.isEmpty ? name : words.first;
  }

  /// Number with up to two decimals.
  static String number(double value) => _number.format(value);

  /// "1 día" or "N días".
  static String days(int value) => value == 1 ? '1 día' : '$value días';

  /// "1 día" or "N días" for a balance with decimals.
  static String balanceDays(double value) => value == 1 ? '1 día' : '${number(value)} días';

  /// "1 hora" or "N horas".
  static String hours(double value) => value == 1 ? '1 hora' : '${number(value)} horas';

  /// Short period with its amount, for example "12/05 al 16/05 · 5 días".
  static String shortPeriod(RequestPeriod? period) {
    if (period == null) return 'Sin fecha';
    if (period.hasHours) return '${shortDate(period.startDate)} · ${hours(period.hours)}';
    if (period.isSingleDay) return '${shortDate(period.startDate)} · ${days(period.days)}';
    return '${shortDate(period.startDate)} al ${shortDate(period.endDate)} · ${days(period.days)}';
  }

  /// Short range of dates, for example "12/05 al 16/05".
  static String shortRange(RequestPeriod? period) {
    if (period == null) return 'Sin fecha';
    if (period.isSingleDay) return shortDate(period.startDate);
    return '${shortDate(period.startDate)} al ${shortDate(period.endDate)}';
  }

  /// Full period, for example "12/05/2026 · 09:00 a 11:00".
  static String longPeriod(RequestPeriod? period) {
    if (period == null) return 'Sin fecha';
    final RequestTime? start = period.startTime;
    final RequestTime? end = period.endTime;
    if (start != null && end != null) return '${date(period.startDate)} · ${time(start)} a ${time(end)}';
    if (period.isSingleDay) return date(period.startDate);
    return '${date(period.startDate)} al ${date(period.endDate)}';
  }

  /// Full period followed by its days or hours.
  static String longPeriodWithAmount(RequestPeriod? period) {
    if (period == null) return 'Sin fecha';
    return '${longPeriod(period)} · ${amount(period)}';
  }

  /// Days or hours of the period.
  static String amount(RequestPeriod? period) {
    if (period == null) return '—';
    return period.hasHours ? hours(period.hours) : days(period.days);
  }

  /// "Enviada hace ..." from [submittedAt] until [now].
  static String sentAgo(DateTime submittedAt, {DateTime? now}) {
    final Duration elapsed = (now ?? DateTime.now()).difference(submittedAt);
    final String text;
    if (elapsed.inMinutes < 1) {
      text = 'hace un momento';
    } else if (elapsed.inMinutes < 60) {
      text = 'hace ${elapsed.inMinutes} min';
    } else if (elapsed.inHours < 24) {
      text = 'hace ${elapsed.inHours} h';
    } else if (elapsed.inDays == 1) {
      text = 'hace 1 día';
    } else {
      text = 'hace ${elapsed.inDays} días';
    }
    return 'Enviada $text';
  }

  /// Type, period and whether it has an attachment.
  static String approvalSummary(Request request) {
    return <String>[
      request.requestTypeName,
      if (request.period != null) shortPeriod(request.period),
      if (request.attachments.isNotEmpty) 'adjunto',
    ].join(' · ');
  }

  /// Short detail of one of the viewer's requests, by its status.
  static String myRequestDetail(Request request) {
    final String approver = shortName(request.approverName);
    final RequestHistoryEntry? change = request.lastChange;
    final String changeDate = change == null ? '' : ' el ${shortDate(change.occurredAt)}';
    switch (request.status) {
      case RequestStatus.inProgress:
        return 'Aprobador: $approver · Enviada el ${shortDate(request.submittedAt)}';
      case RequestStatus.underReview:
        return 'Aprobador: $approver · Se pidió más información';
      case RequestStatus.approved:
        final String? actor = change?.actorName;
        return 'Aprobada por ${actor == null ? approver : shortName(actor)}$changeDate';
      case RequestStatus.rejected:
        final String? comment = change?.comment;
        return comment == null ? 'Rechazada por $approver' : 'Rechazada: $comment';
      case RequestStatus.cancelled:
        return 'Cancelada$changeDate';
    }
  }

  /// "Aprobador: ..." line of a request.
  static String approverLine(Request request) {
    if (request.approverType == ApproverType.hrStaff) return 'Aprobador: RR.HH.';
    return 'Aprobador: ${shortName(request.approverName)}';
  }

  /// Hint shown under a request type in the new request form.
  static String typeHint(RequestType type, double? availableDays) {
    if (type.balanceDeduction == BalanceDeduction.vacationDays) {
      return 'Descuenta de tu saldo${availableDays == null ? '' : ' · ${balanceDays(availableDays)} disponibles'}';
    }
    if (type.balanceDeduction == BalanceDeduction.benefitBalance) return 'Usa tu saldo de beneficio';
    if (type.requiresAttachment) return 'Requiere documento adjunto';
    return type.description ?? 'Sin descuento de saldo';
  }

  /// Detail of a request type in the catalog.
  static String typeCatalogDetail(RequestType type) {
    final String main = type.requiresAttachment && type.balanceDeduction == BalanceDeduction.none
        ? 'Adjunto obligatorio'
        : type.balanceDeduction.catalogLabel;
    final int fields = type.fields.length;
    return '$main · $fields ${fields == 1 ? 'campo' : 'campos'}';
  }

  /// Data type and whether the field is required.
  static String fieldDetail(FieldDataType dataType, bool isRequired) {
    return '${dataType.label} · ${isRequired ? 'Obligatorio' : 'Opcional'}';
  }

  /// Readable value of a dynamic field.
  static String fieldValue(RequestField? field, String value) {
    final FieldDataType? dataType = field?.dataType;
    switch (dataType) {
      case FieldDataType.date:
        final DateTime? day = DateTime.tryParse(value);
        return day == null ? value : date(day);
      case FieldDataType.time:
        final RequestTime? clock = RequestTime.tryParse(value);
        return clock == null ? value : time(clock);
      case FieldDataType.boolean:
        return value.toLowerCase() == 'true' ? 'Sí' : 'No';
      case FieldDataType.money:
        final double? amountValue = double.tryParse(value);
        return amountValue == null ? value : 'S/ ${_money.format(amountValue)}';
      case FieldDataType.text:
      case FieldDataType.number:
      case null:
        return value;
    }
  }

  /// Format and size of a file, for example "PDF · 240 KB".
  static String fileDetail(FileReference file) => '${formatLabel(file.contentType)} · ${size(file.sizeInBytes)}';

  /// Short name of a MIME type.
  static String formatLabel(String contentType) => switch (contentType) {
        'application/pdf' => 'PDF',
        'image/jpeg' => 'JPG',
        'image/png' => 'PNG',
        _ => contentType,
      };

  /// Size in KB or MB.
  static String size(int bytes) {
    final double kb = bytes / 1024;
    return kb < 1024 ? '${kb.toStringAsFixed(0)} KB' : '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static List<String> _words(String name) =>
      name.trim().split(RegExp(r'\s+')).where((String word) => word.isNotEmpty).toList();
}
