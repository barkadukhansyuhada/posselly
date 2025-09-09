import 'package:flutter_test/flutter_test.dart';
import 'package:selly_clone/domain/entities/invoice.dart';

void main() {
  group('InvoiceItem', () {
    test('should create invoice item correctly', () {
      // Arrange & Act
      const invoiceItem = InvoiceItem(
        name: 'Product 1',
        quantity: 2,
        price: 50000,
        total: 100000,
      );

      // Assert
      expect(invoiceItem.name, 'Product 1');
      expect(invoiceItem.quantity, 2);
      expect(invoiceItem.price, 50000);
      expect(invoiceItem.total, 100000);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const invoiceItem = InvoiceItem(
        name: 'Product 1',
        quantity: 2,
        price: 50000,
        total: 100000,
      );

      // Act
      final json = invoiceItem.toJson();

      // Assert
      expect(json['name'], 'Product 1');
      expect(json['quantity'], 2);
      expect(json['price'], 50000);
      expect(json['total'], 100000);
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'name': 'Product 1',
        'quantity': 2,
        'price': 50000,
        'total': 100000,
      };

      // Act
      final invoiceItem = InvoiceItem.fromJson(json);

      // Assert
      expect(invoiceItem.name, 'Product 1');
      expect(invoiceItem.quantity, 2);
      expect(invoiceItem.price, 50000);
      expect(invoiceItem.total, 100000);
    });
  });

  group('Invoice', () {
    final testDate = DateTime(2024, 1, 15);
    final testItems = [
      const InvoiceItem(
        name: 'Product 1',
        quantity: 2,
        price: 50000,
        total: 100000,
      ),
      const InvoiceItem(
        name: 'Product 2',
        quantity: 1,
        price: 25000,
        total: 25000,
      ),
    ];

    test('should create invoice correctly', () {
      // Arrange & Act
      final invoice = Invoice(
        id: '123',
        userId: 'user123',
        invoiceNumber: 'INV001',
        customerName: 'John Doe',
        customerPhone: '08123456789',
        items: testItems,
        subtotal: 125000,
        shippingCost: 15000,
        total: 140000,
        pdfUrl: 'https://example.com/invoice.pdf',
        createdAt: testDate,
      );

      // Assert
      expect(invoice.id, '123');
      expect(invoice.userId, 'user123');
      expect(invoice.invoiceNumber, 'INV001');
      expect(invoice.customerName, 'John Doe');
      expect(invoice.customerPhone, '08123456789');
      expect(invoice.items, testItems);
      expect(invoice.subtotal, 125000);
      expect(invoice.shippingCost, 15000);
      expect(invoice.total, 140000);
      expect(invoice.pdfUrl, 'https://example.com/invoice.pdf');
      expect(invoice.createdAt, testDate);
    });

    test('should support equality comparison', () {
      // Arrange
      final invoice1 = Invoice(
        id: '123',
        userId: 'user123',
        invoiceNumber: 'INV001',
        customerName: 'John Doe',
        items: testItems,
        subtotal: 125000,
        shippingCost: 15000,
        total: 140000,
        createdAt: testDate,
      );

      final invoice2 = Invoice(
        id: '123',
        userId: 'user123',
        invoiceNumber: 'INV001',
        customerName: 'John Doe',
        items: testItems,
        subtotal: 125000,
        shippingCost: 15000,
        total: 140000,
        createdAt: testDate,
      );

      // Assert
      expect(invoice1, equals(invoice2));
    });

    test('should copy with updated values', () {
      // Arrange
      final originalInvoice = Invoice(
        id: '123',
        userId: 'user123',
        invoiceNumber: 'INV001',
        customerName: 'John Doe',
        items: testItems,
        subtotal: 125000,
        shippingCost: 15000,
        total: 140000,
        createdAt: testDate,
      );

      // Act
      final updatedInvoice = originalInvoice.copyWith(
        customerName: 'Jane Doe',
        total: 150000,
      );

      // Assert
      expect(updatedInvoice.customerName, 'Jane Doe');
      expect(updatedInvoice.total, 150000);
      expect(updatedInvoice.id, '123'); // Should remain unchanged
      expect(updatedInvoice.invoiceNumber, 'INV001'); // Should remain unchanged
    });
  });
}