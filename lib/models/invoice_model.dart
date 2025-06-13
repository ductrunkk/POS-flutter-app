import 'package:supabase_flutter/supabase_flutter.dart';

class InvoiceModel {
  final int invoiceid;
  final int cashierid;
  final DateTime paymenttime;
  final double totalamount;

  InvoiceModel({
    required this.invoiceid,
    required this.cashierid,
    required this.paymenttime,
    required this.totalamount,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceid: json['invoiceid'],
      cashierid: json['cashierid'],
      paymenttime: DateTime.parse(json['paymenttime']),
      totalamount: (json['totalamount'] as num).toDouble(),
    );
  }
}

class InvoiceSnapshot{
  static Future<int> createInvoice({
    required int orderId,
    required int cashierId,
    required double totalAmount,
  }) async {
    try {
      // 1. Chèn vào bảng invoice
      final inserted = await Supabase.instance.client
          .from('invoice')
          .insert({
        'cashierid': cashierId,
        'paymenttime': DateTime.now().toIso8601String(),
        'totalamount': totalAmount,
      })
          .select('invoiceid')
          .single();

      final invoiceId = inserted['invoiceid'] as int;

      // 2. Cập nhật cột invoiceid trên bảng orders
      await Supabase.instance.client
          .from('orders')
          .update({'invoiceid': invoiceId})
          .eq('orderid', orderId);

      return invoiceId;
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  Future<InvoiceModel> fetchInvoice(int invoiceId) async {
    final res = await Supabase.instance.client
        .from('invoice')
        .select('invoiceid, cashierid, paymenttime, totalamount')
        .eq('invoiceid', invoiceId)
        .single();

    return InvoiceModel.fromJson(res as Map<String, dynamic>);
  }

  Future<int?> fetchOrderIdByInvoice(int invoiceId) async {
    final res = await Supabase.instance.client
        .from('orders')
        .select('orderid')
        .eq('invoiceid', invoiceId)
        .maybeSingle();

    return res != null ? res['orderid'] as int : null;
  }
}
