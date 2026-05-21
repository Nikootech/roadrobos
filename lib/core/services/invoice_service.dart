import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/pricing_service.dart';

class InvoiceService {
  static Future<void> generateAndShareInvoice({
    required String bookingId,
    required String customerName,
    required String vehicleName,
    required double baseAmount,
    required DateTime date,
  }) async {
    final pdf = pw.Document();
    final breakdown = PricingService.calculateBill(baseAmount);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RoAdRoBos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Vehicle Service & Mobility Solutions', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('ID: #$bookingId', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Billing Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILLED TO:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(customerName, style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Date: ${dateFormat.format(date)}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('FROM:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('RoAdRoBos Services Pvt Ltd', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Tech Park, Block B, Delhi, IN', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Item Table Header
              pw.Container(
                decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Items
              _invoiceItem('Base Fare ($vehicleName)', breakdown.baseAmount),
              _invoiceItem('Platform Fee', breakdown.platformFee),
              _invoiceItem('Handling Charges', breakdown.handlingCharges),
              _invoiceItem('GST (18%)', breakdown.gstAmount),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('GRAND TOTAL: ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('INR ${breakdown.totalPayable.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                ],
              ),

              pw.Spacer(),
              
              // Footer
              pw.Center(child: pw.Text('Thank you for choosing RoAdRoBos!', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic))),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Center(child: pw.Text('This is a computer-generated invoice and requires no signature.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500))),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/RoAdRoBos_Invoice_$bookingId.pdf");
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Your RoAdRoBos Invoice for #$bookingId');
  }

  static pw.Widget _invoiceItem(String desc, double amt) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: pw.Text(desc)),
          pw.Expanded(child: pw.Text('INR ${amt.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }
}
