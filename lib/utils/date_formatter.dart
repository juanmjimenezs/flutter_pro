import 'package:intl/intl.dart';

/// Formats an ISO date string to a readable format (e.g., "15 March 2024")
/// Returns empty string if the date is null or invalid
String formatDate(String? iso) {
  if (iso == null) return '';
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  return DateFormat('dd MMMM yyyy').format(date);
}
