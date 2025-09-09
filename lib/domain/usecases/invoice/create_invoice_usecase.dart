import 'package:dartz/dartz.dart';

import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';
import '../../../core/errors/failures.dart';

class CreateInvoiceUsecase {
  final InvoiceRepository repository;
  
  CreateInvoiceUsecase(this.repository);
  
  Future<Either<Failure, Invoice>> call({
    required String customerName,
    String? customerPhone,
    required List<InvoiceItem> items,
    required double subtotal,
    double shippingCost = 0,
    required double total,
  }) async {
    return await repository.createInvoice(
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: total,
    );
  }
}