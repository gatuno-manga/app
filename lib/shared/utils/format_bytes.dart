import 'package:intl/intl.dart';

const List<String> _units = ['B', 'KB', 'MB', 'GB'];

/// Formats a storage size in binary units (base 1024), with the number
/// written for [locale] and joined to its unit by a no-break space:
/// `512 B`, `12 KB`, `1.5 MB`, in Portuguese `1,5 MB`.
///
/// Bytes and kilobytes are whole numbers; megabytes and up keep one
/// decimal, since that is where the difference matters to the reader.
String formatBytes(int bytes, String locale) {
  if (bytes < 0) {
    throw ArgumentError.value(bytes, 'bytes', 'must not be negative');
  }
  var value = bytes.toDouble();
  var unit = 0;
  while (unit < _units.length - 1 && _rounded(value, unit) >= 1024) {
    value /= 1024;
    unit++;
  }
  final pattern = unit >= 2 ? '0.0' : '0';
  // A no-break space keeps the number and its unit on one line.
  return '${NumberFormat(pattern, locale).format(value)}\u00A0${_units[unit]}';
}

/// [value] as it would print in [unit], so 1023.96 KB moves up to 1.0 MB
/// instead of showing as 1024 KB.
double _rounded(double value, int unit) =>
    unit >= 2 ? (value * 10).roundToDouble() / 10 : value.roundToDouble();
