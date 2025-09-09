import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/date_formatter.dart';
import '../models/invoice_model.dart';
import '../datasources/local/sqlite_datasource.dart';
import '../../services/pdf/pdf_generator.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final SqliteDatasource localDatasource;
  final PdfGenerator pdfGenerator;
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  InvoiceRepositoryImpl(
    this.localDatasource,
    this.pdfGenerator,
  );

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult != ConnectivityResult.none) {
        final user = _supabaseClient.auth.currentUser;
        if (user != null) {
          final response = await _supabaseClient
              .from(SupabaseConfig.invoicesTable)
              .select()
              .eq('user_id', user.id)
              .order('created_at', ascending: false);

          final invoices = (response as List)
              .map((json) => InvoiceModel.fromJson(json))
              .toList();

          await localDatasource.cacheInvoices(invoices);
          return Right(invoices);
        }
      }
      
      final cachedInvoices = await localDatasource.getInvoices();
      return Right(cachedInvoices);
    } on ServerException catch (e) {
      try {
        final cachedInvoices = await localDatasource.getInvoices();
        return Right(cachedInvoices);
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> createInvoice({
    required String customerName,
    String? customerPhone,
    required List<InvoiceItem> items,
    required double subtotal,
    double shippingCost = 0,
    required double total,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User tidak terautentikasi'));
      }

      final invoiceId = _uuid.v4();
      final invoiceNumber = DateFormatter.generateInvoiceNumber();

      final invoice = InvoiceModel(
        id: invoiceId,
        userId: user.id,
        invoiceNumber: invoiceNumber,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        total: total,
        createdAt: DateTime.now(),
      );

      await _supabaseClient
          .from(SupabaseConfig.invoicesTable)
          .insert(invoice.toSupabaseJson());

      await localDatasource.insertInvoice(invoice);
      
      return Right(invoice);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoice({
    required String id,
    String? customerName,
    String? customerPhone,
    List<InvoiceItem>? items,
    double? subtotal,
    double? shippingCost,
    double? total,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final updateData = <String, dynamic>{};
      if (customerName != null) updateData['customer_name'] = customerName;
      if (customerPhone != null) updateData['customer_phone'] = customerPhone;
      if (items != null) updateData['items'] = items.map((item) => item.toJson()).toList();
      if (subtotal != null) updateData['subtotal'] = subtotal;
      if (shippingCost != null) updateData['shipping_cost'] = shippingCost;
      if (total != null) updateData['total'] = total;

      final response = await _supabaseClient
          .from(SupabaseConfig.invoicesTable)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final invoice = InvoiceModel.fromJson(response);
      
      await localDatasource.updateInvoice(invoice);
      
      return Right(invoice);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInvoice(String id) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      await _supabaseClient
          .from(SupabaseConfig.invoicesTable)
          .delete()
          .eq('id', id);

      await localDatasource.deleteInvoice(id);
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generatePdf(String invoiceId) async {
    try {
      // Get invoice from local database first
      final invoices = await localDatasource.getInvoices();
      final invoice = invoices.firstWhere(
        (inv) => inv.id == invoiceId,
        orElse: () => throw const ServerException(message: 'Invoice tidak ditemukan'),
      );

      // Get current user info
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User tidak terautentikasi'));
      }

      // Generate PDF
      final pdfPath = await pdfGenerator.generateInvoicePdf(
        invoice: invoice,
        businessName: 'Toko Saya', // This should come from user profile
        businessAddress: 'Alamat Toko', // This should come from user profile
        businessPhone: '08123456789', // This should come from user profile
      );

      return Right(pdfPath);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on PdfGenerationException catch (e) {
      return Left(PdfGenerationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }
}