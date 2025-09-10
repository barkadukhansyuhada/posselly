import 'package:flutter_test/flutter_test.dart';
import 'package:selly_clone/services/shipping/shipping_calculator.dart';

void main() {
  group('ShippingResult', () {
    test('should create shipping result correctly', () {
      // Arrange & Act
      const result = ShippingResult(
        courier: 'JNE',
        service: 'REG',
        description: 'Layanan Reguler',
        cost: 15000,
        estimatedTime: '2-3 hari',
      );

      // Assert
      expect(result.courier, 'JNE');
      expect(result.service, 'REG');
      expect(result.description, 'Layanan Reguler');
      expect(result.cost, 15000);
      expect(result.estimatedTime, '2-3 hari');
    });

    // Note: _parseEtd is private, tested through factory method
  });

  group('ShippingCalculator', () {
    late ShippingCalculator calculator;

    setUp(() {
      calculator = ShippingCalculator();
    });

    test('should return available couriers', () {
      // Act
      final couriers = calculator.availableCouriers;

      // Assert
      expect(couriers, contains('JNE'));
      expect(couriers, contains('POS'));
      expect(couriers, contains('TIKI'));
      expect(couriers.length, 3);
    });

    test('should format shipping text correctly', () {
      // Act
      final result = calculator.formatShippingText(
        courier: 'JNE',
        service: 'REG',
        description: 'Layanan Reguler',
        cost: 15000,
        weight: 1.0,
        estimatedTime: '2-3 hari',
        originCity: 'Jakarta',
        destinationCity: 'Bandung',
      );

      // Assert
      expect(result, contains('🚚 *Detail Pengiriman*'));
      expect(result, contains('Rute: Jakarta → Bandung'));
      expect(result, contains('Kurir: JNE (REG)'));
      expect(result, contains('Layanan: Layanan Reguler'));
      expect(result, contains('Berat: 1.0kg'));
      expect(result, contains('Ongkos Kirim: Rp 15000'));
      expect(result, contains('Estimasi: 2-3 hari'));
      expect(result, contains('_Tarif resmi dari kurir terpercaya_'));
    });

    test('should format shipping text without origin/destination', () {
      // Act
      final result = calculator.formatShippingText(
        courier: 'JNE',
        service: 'REG',
        description: 'Layanan Reguler',
        cost: 15000,
        weight: 1.0,
        estimatedTime: '2-3 hari',
      );

      // Assert
      expect(result, contains('🚚 *Detail Pengiriman*'));
      expect(result, isNot(contains('Rute:')));
      expect(result, contains('Kurir: JNE (REG)'));
    });

    // Note: Real API tests would require mocking or integration tests
    // Here we test the business logic and formatting functions
  });
}