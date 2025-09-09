import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final double total;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  @override
  List<Object> get props => [name, quantity, price, total];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class Invoice extends Equatable {
  final String id;
  final String userId;
  final String invoiceNumber;
  final String customerName;
  final String? customerPhone;
  final List<InvoiceItem> items;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String? pdfUrl;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    this.pdfUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        invoiceNumber,
        customerName,
        customerPhone,
        items,
        subtotal,
        shippingCost,
        total,
        pdfUrl,
        createdAt,
      ];

  Invoice copyWith({
    String? id,
    String? userId,
    String? invoiceNumber,
    String? customerName,
    String? customerPhone,
    List<InvoiceItem>? items,
    double? subtotal,
    double? shippingCost,
    double? total,
    String? pdfUrl,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}