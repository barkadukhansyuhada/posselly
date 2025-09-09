import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/invoice/create_invoice_usecase.dart';
import '../../../domain/usecases/invoice/generate_pdf_usecase.dart';
import '../../../domain/repositories/invoice_repository.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final CreateInvoiceUsecase _createInvoiceUsecase;
  final GeneratePdfUsecase _generatePdfUsecase;
  final InvoiceRepository _invoiceRepository;

  InvoiceBloc(
    this._createInvoiceUsecase,
    this._generatePdfUsecase,
    this._invoiceRepository,
  ) : super(const InvoiceInitial()) {
    on<InvoiceLoadRequested>(_onLoadRequested);
    on<InvoiceCreateRequested>(_onCreateRequested);
    on<InvoiceGeneratePdfRequested>(_onGeneratePdfRequested);
    on<InvoiceDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    InvoiceLoadRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());

    final result = await _invoiceRepository.getInvoices();

    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (invoices) => emit(InvoiceLoaded(invoices)),
    );
  }

  Future<void> _onCreateRequested(
    InvoiceCreateRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());

    final result = await _createInvoiceUsecase(
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      items: event.items,
      subtotal: event.subtotal,
      shippingCost: event.shippingCost,
      total: event.total,
    );

    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (invoice) => emit(InvoiceCreated(invoice)),
    );
  }

  Future<void> _onGeneratePdfRequested(
    InvoiceGeneratePdfRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());

    final result = await _generatePdfUsecase(event.invoiceId);

    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (pdfPath) => emit(InvoicePdfGenerated(pdfPath)),
    );
  }

  Future<void> _onDeleteRequested(
    InvoiceDeleteRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());

    final result = await _invoiceRepository.deleteInvoice(event.invoiceId);

    result.fold(
      (failure) => emit(InvoiceError(failure.message)),
      (_) {
        // Reload invoices after deletion
        add(const InvoiceLoadRequested());
      },
    );
  }
}