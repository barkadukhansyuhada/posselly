import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/invoice.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/errors/exceptions.dart';

class PdfGenerator {
  Future<String> generateInvoicePdf({
    required Invoice invoice,
    required String businessName,
    String? businessAddress,
    String? businessPhone,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Load font
      final font = await PdfGoogleFonts.robotoRegular();
      final boldFont = await PdfGoogleFonts.robotoBold();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(businessName, businessAddress, businessPhone, boldFont),
                pw.SizedBox(height: 30),
                
                // Invoice info
                _buildInvoiceInfo(invoice, font, boldFont),
                pw.SizedBox(height: 30),
                
                // Customer info
                _buildCustomerInfo(invoice, font, boldFont),
                pw.SizedBox(height: 30),
                
                // Items table
                _buildItemsTable(invoice, font, boldFont),
                pw.SizedBox(height: 30),
                
                // Total section
                _buildTotalSection(invoice, font, boldFont),
                
                pw.Spacer(),
                
                // Footer
                _buildFooter(font),
              ],
            );
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file.path;
    } catch (e) {
      throw PdfGenerationException('Gagal membuat PDF: $e');
    }
  }

  pw.Widget _buildHeader(String businessName, String? businessAddress, String? businessPhone, pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            businessName,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.blue900,
            ),
          ),
          if (businessAddress != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              businessAddress,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
          if (businessPhone != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Tel: $businessPhone',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceInfo(Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 28,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'No: ${invoice.invoiceNumber}',
              style: pw.TextStyle(font: boldFont, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Tanggal: ${DateFormatter.formatDisplay(invoice.createdAt)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerInfo(Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO:',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            invoice.customerName,
            style: pw.TextStyle(font: boldFont, fontSize: 14),
          ),
          if (invoice.customerPhone != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Tel: ${invoice.customerPhone}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Item', boldFont, isHeader: true),
            _buildTableCell('Qty', boldFont, isHeader: true),
            _buildTableCell('Harga', boldFont, isHeader: true),
            _buildTableCell('Total', boldFont, isHeader: true),
          ],
        ),
        // Items
        ...invoice.items.map((item) => pw.TableRow(
          children: [
            _buildTableCell(item.name, font),
            _buildTableCell(item.quantity.toString(), font),
            _buildTableCell(CurrencyFormatter.formatRupiah(item.price), font),
            _buildTableCell(CurrencyFormatter.formatRupiah(item.total), font),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 11,
        ),
        textAlign: text.contains('Rp') ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildTotalSection(Invoice invoice, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Container()),
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _buildTotalRow('Subtotal', CurrencyFormatter.formatRupiah(invoice.subtotal), font),
              if (invoice.shippingCost > 0)
                _buildTotalRow('Ongkos Kirim', CurrencyFormatter.formatRupiah(invoice.shippingCost), font),
              pw.Divider(color: PdfColors.grey400),
              _buildTotalRow('TOTAL', CurrencyFormatter.formatRupiah(invoice.total), boldFont, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, String value, pw.Font font, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: isTotal ? 14 : 12,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Text(
          'Terima kasih atas kepercayaan Anda!',
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Invoice ini dibuat menggunakan Selly Clone',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  Future<void> shareInvoice(String filePath) async {
    try {
      await Printing.sharePdf(
        bytes: File(filePath).readAsBytesSync(),
        filename: 'invoice.pdf',
      );
    } catch (e) {
      throw PdfGenerationException('Gagal membagikan PDF: $e');
    }
  }

  Future<void> printInvoice(String filePath) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => File(filePath).readAsBytesSync(),
      );
    } catch (e) {
      throw PdfGenerationException('Gagal mencetak PDF: $e');
    }
  }
}