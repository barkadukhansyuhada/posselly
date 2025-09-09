import 'package:equatable/equatable.dart';

import '../../../domain/entities/invoice.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoading extends InvoiceState {
  const InvoiceLoading();
}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> invoices;

  const InvoiceLoaded(this.invoices);

  @override
  List<Object> get props => [invoices];
}

class InvoiceCreated extends InvoiceState {
  final Invoice invoice;

  const InvoiceCreated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoicePdfGenerated extends InvoiceState {
  final String pdfPath;

  const InvoicePdfGenerated(this.pdfPath);

  @override
  List<Object> get props => [pdfPath];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}