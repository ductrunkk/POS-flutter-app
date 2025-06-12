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
