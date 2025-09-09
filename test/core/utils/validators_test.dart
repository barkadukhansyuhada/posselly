import 'package:flutter_test/flutter_test.dart';
import 'package:selly_clone/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        // Arrange
        const email = 'test@example.com';
        
        // Act
        final result = Validators.validateEmail(email);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for null email', () {
        // Act
        final result = Validators.validateEmail(null);
        
        // Assert
        expect(result, 'Email wajib diisi');
      });

      test('should return error for empty email', () {
        // Act
        final result = Validators.validateEmail('');
        
        // Assert
        expect(result, 'Email wajib diisi');
      });

      test('should return error for invalid email format', () {
        // Arrange
        const email = 'invalid-email';
        
        // Act
        final result = Validators.validateEmail(email);
        
        // Assert
        expect(result, 'Format email tidak valid');
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        // Arrange
        const password = 'password123';
        
        // Act
        final result = Validators.validatePassword(password);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for null password', () {
        // Act
        final result = Validators.validatePassword(null);
        
        // Assert
        expect(result, 'Kata sandi wajib diisi');
      });

      test('should return error for short password', () {
        // Arrange
        const password = '123';
        
        // Act
        final result = Validators.validatePassword(password);
        
        // Assert
        expect(result, 'Kata sandi minimal 6 karakter');
      });
    });

    group('validateConfirmPassword', () {
      test('should return null for matching passwords', () {
        // Arrange
        const password = 'password123';
        const confirmPassword = 'password123';
        
        // Act
        final result = Validators.validateConfirmPassword(password, confirmPassword);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for non-matching passwords', () {
        // Arrange
        const password = 'password123';
        const confirmPassword = 'different123';
        
        // Act
        final result = Validators.validateConfirmPassword(password, confirmPassword);
        
        // Assert
        expect(result, 'Kata sandi tidak cocok');
      });

      test('should return error for null confirm password', () {
        // Arrange
        const password = 'password123';
        
        // Act
        final result = Validators.validateConfirmPassword(password, null);
        
        // Assert
        expect(result, 'Konfirmasi kata sandi wajib diisi');
      });
    });

    group('validateRequired', () {
      test('should return null for valid value', () {
        // Arrange
        const value = 'Valid Value';
        const fieldName = 'Field';
        
        // Act
        final result = Validators.validateRequired(value, fieldName);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for null value', () {
        // Arrange
        const fieldName = 'Field';
        
        // Act
        final result = Validators.validateRequired(null, fieldName);
        
        // Assert
        expect(result, 'Field wajib diisi');
      });

      test('should return error for empty value', () {
        // Arrange
        const value = '   ';
        const fieldName = 'Field';
        
        // Act
        final result = Validators.validateRequired(value, fieldName);
        
        // Assert
        expect(result, 'Field wajib diisi');
      });
    });

    group('validatePrice', () {
      test('should return null for valid price', () {
        // Arrange
        const price = '100000';
        
        // Act
        final result = Validators.validatePrice(price);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for null price', () {
        // Act
        final result = Validators.validatePrice(null);
        
        // Assert
        expect(result, 'Harga wajib diisi');
      });

      test('should return error for invalid price', () {
        // Arrange
        const price = 'invalid';
        
        // Act
        final result = Validators.validatePrice(price);
        
        // Assert
        expect(result, 'Harga harus berupa angka positif');
      });

      test('should return error for negative price', () {
        // Arrange
        const price = '-100';
        
        // Act
        final result = Validators.validatePrice(price);
        
        // Assert
        expect(result, 'Harga harus berupa angka positif');
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone', () {
        // Arrange
        const phone = '08123456789';
        
        // Act
        final result = Validators.validatePhone(phone);
        
        // Assert
        expect(result, isNull);
      });

      test('should return null for null phone (optional)', () {
        // Act
        final result = Validators.validatePhone(null);
        
        // Assert
        expect(result, isNull);
      });

      test('should return error for invalid phone format', () {
        // Arrange
        const phone = 'invalid-phone';
        
        // Act
        final result = Validators.validatePhone(phone);
        
        // Assert
        expect(result, 'Format nomor telepon tidak valid');
      });
    });
  });
}