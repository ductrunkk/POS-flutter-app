import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_booking/controllers/table_controller.dart';
import '../helpers/pdf_helper.dart';
import '../models/invoice_model.dart';
import '../models/order_detail_model.dart';
import 'package:table_booking/bindings/payment_binding.dart';

import '../pages/table_page.dart';

class PaymentController extends GetxController {
  var invoice = Rxn<InvoiceModel>();
  var orderDetails = <OrderDetailModel>[].obs;

  final int invoiceId;
  final int orderId;
  final int tableId;

  PaymentController({
    required this.invoiceId,
    required this.orderId,
    required this.tableId,
  });

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

  Future<void> completePayment() async {
    final inv = invoice.value!;
    // 1. In PDF
    await generateInvoicePDF(inv, orderDetails);

    // 2. Cập nhật lại status bàn về 'available'
    await Supabase.instance.client
        .from('tablerestaurant')
        .update({'status': 'available'})
        .eq('tableid', tableId);

    // 3. Quay về TablePage, xóa hết navigation stack cũ
    Get.offAll(() => TablePage());

    Get.find<TableController>().fetchTables();

    Get.snackbar("Hoàn tất", "Bàn $tableId đã sẵn sàng", backgroundColor: Colors.green, colorText: Colors.white);
  }
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    final invoiceId = args['invoiceId'];
    final orderId = args['orderId'];

    if (invoiceId != null) {
      fetchInvoice(invoiceId).then((_) async {
        if (orderId != null) {
          fetchOrderDetails(orderId);
        }
      });
    }
  }
}

