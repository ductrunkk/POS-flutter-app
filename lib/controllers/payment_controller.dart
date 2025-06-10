import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../models/order_detail_model.dart';
import 'package:table_booking/bindings/payment_binding.dart';

class PaymentController extends GetxController {
  var invoice = Rxn<InvoiceModel>();
  var orderDetails = <OrderDetailModel>[].obs;

  Future<void> fetchInvoice(int invoiceId) async {
    final res = await Supabase.instance.client
        .from('invoice')
        .select('invoiceid, cashierid, paymenttime, totalamount')
        .eq('invoiceid', invoiceId)
        .single();
    invoice.value = InvoiceModel.fromJson(res as Map<String, dynamic>);
  }

  Future<int?> fetchOrderIdByInvoice(int invoiceId) async {
    final res = await Supabase.instance.client
        .from('orders')
        .select('orderid')
        .eq('invoiceid', invoiceId)
        .maybeSingle();

    return res != null ? res['orderid'] as int : null;
  }

  Future<void> fetchOrderDetails(int orderId) async {
    final res = await Supabase.instance.client
        .from('orderdetail')
        .select('orderid, dishid,  quantity, unitprice, dish(dishname)')
        .eq('orderid', orderId);
    orderDetails.value = (res as List)
        .map((e) => OrderDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    const testInvoiceId = 1;
    fetchInvoice(testInvoiceId).then((_) async {
      final orderId = await fetchOrderIdByInvoice(testInvoiceId);
      if (orderId != null) {
        fetchOrderDetails(orderId);
      }
    });
  }
}

