import 'package:equatable/equatable.dart';

import '../../../domain/entities/invoice.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class InvoiceLoadRequested extends InvoiceEvent {
  const InvoiceLoadRequested();
}

class InvoiceCreateRequested extends InvoiceEvent {
  final String customerName;
  final String? customerPhone;
  final List<InvoiceItem> items;
  final double subtotal;
  final double shippingCost;
  final double total;

  const InvoiceCreateRequested({
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
  });

  @override
  List<Object?> get props => [
        customerName,
        customerPhone,
        items,
        subtotal,
        shippingCost,
        total,
      ];
}

class InvoiceGeneratePdfRequested extends InvoiceEvent {
  final String invoiceId;

  const InvoiceGeneratePdfRequested(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}

class InvoiceDeleteRequested extends InvoiceEvent {
  final String invoiceId;

  const InvoiceDeleteRequested(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}