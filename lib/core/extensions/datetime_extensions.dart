extension SafeTimestamp on DateTime {
  String get utcIso => toUtc().toIso8601String();
}
