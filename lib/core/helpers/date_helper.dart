import 'package:intl/intl.dart';

String formatDate(DateTime value) {
  return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(value);
}

DateTime parseDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
