import 'package:flutter_test/flutter_test.dart';
import 'package:selly_clone/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('should format rupiah correctly', () {
      // Arrange
      const amount = 150000.0;
      
      // Act
      final result = CurrencyFormatter.formatRupiah(amount);
      
      // Assert
      expect(result, 'Rp 150.000');
    });

    test('should format rupiah from string correctly', () {
      // Arrange
      const amount = '250000';
      
      // Act
      final result = CurrencyFormatter.formatRupiahFromString(amount);
      
      // Assert
      expect(result, 'Rp 250.000');
    });

    test('should return Rp 0 for invalid string', () {
      // Arrange
      const amount = 'invalid';
      
      // Act
      final result = CurrencyFormatter.formatRupiahFromString(amount);
      
      // Assert
      expect(result, 'Rp 0');
    });

    test('should parse rupiah string correctly', () {
      // Arrange
      const formatted = 'Rp 100.000';
      
      // Act
      final result = CurrencyFormatter.parseRupiah(formatted);
      
      // Assert
      expect(result, 100000.0);
    });

    test('should format number correctly', () {
      // Arrange
      const number = 1500000.0;
      
      // Act
      final result = CurrencyFormatter.formatNumber(number);
      
      // Assert
      expect(result, '1.500.000');
    });
  });
}