import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  static String formatRupiah(double amount) {
    return _rupiahFormat.format(amount);
  }
  
  static String formatRupiahFromString(String amount) {
    final double? parsed = double.tryParse(amount);
    if (parsed == null) return 'Rp 0';
    return formatRupiah(parsed);
  }
  
  static double parseRupiah(String formatted) {
    final cleaned = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
  
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }
}