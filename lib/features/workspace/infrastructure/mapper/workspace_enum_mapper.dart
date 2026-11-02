/// Converts the enums of the domain to and from the UPPER_SNAKE_CASE names used by the API.
class WorkspaceEnumMapper {
  const WorkspaceEnumMapper._();

  /// API name of [value], for example `fixedTerm` becomes `FIXED_TERM`.
  static String toApi(Enum value) {
    return value.name
        .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (Match match) => '${match[1]}_${match[2]}')
        .toUpperCase();
  }

  /// Value of [values] whose API name is [raw]; throws [FormatException] when none matches.
  static T fromApi<T extends Enum>(List<T> values, String raw) {
    for (final T value in values) {
      if (toApi(value) == raw) return value;
    }
    throw FormatException('Valor desconocido: $raw');
  }
}
