import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy', 'id_ID');
  static final DateFormat _timestampFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  
  static String formatDisplay(DateTime date) {
    return _displayFormat.format(date);
  }
  
  static String formatTimestamp(DateTime date) {
    return _timestampFormat.format(date);
  }
  
  static String formatIso(DateTime date) {
    return _isoFormat.format(date);
  }
  
  static DateTime? parseDisplay(String date) {
    try {
      return _displayFormat.parse(date);
    } catch (e) {
      return null;
    }
  }
  
  static DateTime? parseIso(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
  
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final dateString = DateFormat('yyyyMMdd').format(now);
    final timeString = DateFormat('HHmmss').format(now);
    return 'INV$dateString$timeString';
  }
}