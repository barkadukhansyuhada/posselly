import 'package:dartz/dartz.dart';

import '../entities/invoice.dart';
import '../../core/errors/failures.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, List<Invoice>>> getInvoices();
  Future<Either<Failure, Invoice>> createInvoice({
    required String customerName,
    String? customerPhone,
    required List<InvoiceItem> items,
    required double subtotal,
    double shippingCost = 0,
    required double total,
  });
  Future<Either<Failure, Invoice>> updateInvoice({
    required String id,
    String? customerName,
    String? customerPhone,
    List<InvoiceItem>? items,
    double? subtotal,
    double? shippingCost,
    double? total,
  });
  Future<Either<Failure, void>> deleteInvoice(String id);
  Future<Either<Failure, String>> generatePdf(String invoiceId);
}