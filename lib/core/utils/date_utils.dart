import 'package:intl/intl.dart';

class AppDateUtils {
  static String getFormattedDate([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
  
  static int getDaysOld(DateTime stockingDate) {
    final today = DateTime.now();
    final start = DateTime(
      stockingDate.year,
      stockingDate.month,
      stockingDate.day,
    );
    final now = DateTime(today.year, today.month, today.day);
    return now.difference(start).inDays;
  }
  
  static String getDisplayDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
  
  static String getShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}