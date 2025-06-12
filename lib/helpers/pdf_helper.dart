// File: lib/helpers/pdf_helper.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import '../models/order_detail_model.dart';
import 'date_helper.dart';

// Invoice
Future<void> generateInvoicePDF(
    InvoiceModel invoice,
    List<OrderDetailModel> details,
    ) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Invoice ID: ${invoice.invoiceid}', style: pw.TextStyle(fontSize: 18)),
            pw.Text(
              'Date: ${Formatters.dateTime.format(invoice.paymenttime)}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Items:',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Item Name', 'Quantity', 'Unit Price', 'Amount'],
              data: details.map((d) => [
                d.dishname,
                d.quantity.toString(),
                d.unitprice.toStringAsFixed(2),
                (d.quantity * d.unitprice).toStringAsFixed(2),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            ),
            pw.Divider(height: 32),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: \$${invoice.totalamount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// Kitchen Order
Future<void> generateKitchenOrderPDF({
  required int orderId,
  required String tableName,
  required String waiterName,
  required DateTime orderTime,
  required List<OrderDetailModel> details,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ORDER FOR KITCHEN',
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Order ID: $orderId', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Table: $tableName', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Waiter: $waiterName', style: pw.TextStyle(fontSize: 16)),
            pw.Text(
              'Time: ${Formatters.dateTime.format(orderTime)}',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.SizedBox(height: 24),
                pw.Text('Ordered Items:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Dish', 'Qty'],
              data: details.map((d) => [
                d.dishname,
                d.quantity.toString(),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

Future<void> generateNewItemsOnlyPDF({
  required int orderId,
  required String tableName,
  required String waiterName,
  required DateTime orderTime,
  required List<OrderDetailModel> newItems,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('UPDATED ORDER - NEW ITEMS ONLY',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('Order ID: $orderId'),
            pw.Text('Table: $tableName'),
            pw.Text('Waiter: $waiterName'),
            pw.Text('Time: ${Formatters.dateTime.format(orderTime)}'),
            pw.SizedBox(height: 16),
            pw.Text('Newly Added Items:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Dish', 'Qty'],
              data: newItems.map((d) => [
                d.dishname,
                d.quantity.toString(),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
