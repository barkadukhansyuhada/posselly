import 'dart:convert';

import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required String id,
    required String userId,
    required String invoiceNumber,
    required String customerName,
    String? customerPhone,
    required List<InvoiceItem> items,
    required double subtotal,
    required double shippingCost,
    required double total,
    String? pdfUrl,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          invoiceNumber: invoiceNumber,
          customerName: customerName,
          customerPhone: customerPhone,
          items: items,
          subtotal: subtotal,
          shippingCost: shippingCost,
          total: total,
          pdfUrl: pdfUrl,
          createdAt: createdAt,
        );

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceItem> itemsList = [];
    
    if (json['items'] is String) {
      // If items is stored as JSON string (from SQLite)
      final itemsJson = jsonDecode(json['items'] as String);
      itemsList = (itemsJson as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();
    } else if (json['items'] is List) {
      // If items is already a List (from Supabase JSONB)
      itemsList = (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList();
    }

    return InvoiceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      items: itemsList,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num? ?? 0).toDouble(),
      total: (json['total'] as num).toDouble(),
      pdfUrl: json['pdf_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': jsonEncode(items.map((item) => item.toJson()).toList()),
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'pdf_url': pdfUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(), // JSONB format
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'pdf_url': pdfUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      userId: invoice.userId,
      invoiceNumber: invoice.invoiceNumber,
      customerName: invoice.customerName,
      customerPhone: invoice.customerPhone,
      items: invoice.items,
      subtotal: invoice.subtotal,
      shippingCost: invoice.shippingCost,
      total: invoice.total,
      pdfUrl: invoice.pdfUrl,
      createdAt: invoice.createdAt,
    );
  }
}