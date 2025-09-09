import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:selly_clone/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  
  group('DateFormatter', () {
    test('should format display date correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      
      // Act
      final result = DateFormatter.formatDisplay(date);
      
      // Assert
      expect(result, '15/01/2024');
    });

    test('should format timestamp correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15, 14, 30);
      
      // Act
      final result = DateFormatter.formatTimestamp(date);
      
      // Assert
      expect(result, '15/01/2024 14:30');
    });

    test('should format ISO date correctly', () {
      // Arrange
      final date = DateTime(2024, 1, 15);
      
      // Act
      final result = DateFormatter.formatIso(date);
      
      // Assert
      expect(result, '2024-01-15');
    });

    test('should parse display date correctly', () {
      // Arrange
      const dateString = '15/01/2024';
      
      // Act
      final result = DateFormatter.parseDisplay(dateString);
      
      // Assert
      expect(result, DateTime(2024, 1, 15));
    });

    test('should return null for invalid display date', () {
      // Arrange
      const dateString = 'invalid-date';
      
      // Act
      final result = DateFormatter.parseDisplay(dateString);
      
      // Assert
      expect(result, isNull);
    });

    test('should generate invoice number with correct format', () {
      // Act
      final result = DateFormatter.generateInvoiceNumber();
      
      // Assert
      expect(result, startsWith('INV'));
      expect(result.length, greaterThan(10));
    });

    test('should format relative time for days', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(days: 2));
      
      // Act
      final result = DateFormatter.formatRelative(date);
      
      // Assert
      expect(result, '2 hari yang lalu');
    });

    test('should format relative time for hours', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(hours: 3));
      
      // Act
      final result = DateFormatter.formatRelative(date);
      
      // Assert
      expect(result, '3 jam yang lalu');
    });

    test('should format relative time for recent time', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(seconds: 30));
      
      // Act
      final result = DateFormatter.formatRelative(date);
      
      // Assert
      expect(result, 'Baru saja');
    });
  });
}