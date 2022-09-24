import 'package:charts_common/common.dart' as common show DateTimeFactory;
import 'package:intl/intl.dart';
import 'dart:ui';

/// A class to localize the date
class LocalizedTimeFactory implements common.DateTimeFactory {
  final Locale locale;

  const LocalizedTimeFactory(this.locale);

  DateTime createDateTimeFromMilliSecondsSinceEpoch(
      int millisecondsSinceEpoch) {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  DateTime createDateTime(int year,
      [int month = 1,
        int day = 1,
        int hour = 0,
        int minute = 0,
        int second = 0,
        int millisecond = 0,
        int microsecond = 0]) {
    return DateTime(
        year, month, day, hour, minute, second, millisecond, microsecond);
  }

  /// Returns a [DateFormat].
  DateFormat createDateFormat(String pattern) {
    return DateFormat(pattern, locale.languageCode);
  }
}