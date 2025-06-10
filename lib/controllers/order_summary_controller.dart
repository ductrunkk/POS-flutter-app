import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:table_booking/helpers/pdf_helper.dart';
import 'package:table_booking/models/employee_model.dart';
import 'package:table_booking/models/order_detail_model.dart';
import 'package:table_booking/models/order_model.dart';
import 'package:table_booking/pages/table_page.dart';
class OrderSummaryController extends GetxController {
  final int orderId;
  List<OrderDetailModel> items = [];
  bool loading = false;
  String? error;

  OrderSummaryController(this.orderId);

  @override
  void onInit() {
    super.onInit();
    loadOrderDetails();
  }

  Future<void> loadOrderDetails() async {
    loading = true;
    update();
    try {
      items = await OrderDetailSnapshot.fetchByOrderId(orderId);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      update();
    }
  }

  final OrderSnapshot _orderService = OrderSnapshot();
  Future<bool> handleCancel(int orderId) async {
    final success = await _orderService.cancelOrder(orderId);
    if (!success) {
      error = 'Hủy đơn thất bại.';
    } else {
      error = null;
    }
    update(); // cập nhật UI
    return success;
  }

  Future<void> printToKitchen(int orderId) async {
    try {
      // 1. Lấy order + table name từ snapshot
      final result = await OrderSnapshot.getOrderWithTableName(orderId);
      final order = result['order'] as OrderModel;
      final tableName = result['tableName'] as String;

      // 2. Lấy tên nhân viên
      final waiterName = await EmployeeSnapshot.getWaiterName(order.waiterId);

      // 3. Lấy chi tiết món ăn
      final details = await OrderDetailSnapshot.fetchByOrderId(orderId);

      // 4. In PDF cho bếp
      await generateKitchenOrderPDF(
        orderId: order.orderId,
        tableName: tableName,
        waiterName: waiterName,
        orderTime: order.orderTime,
        details: details,
      );

      // 5. Quay về trang chính
      Get.offAll(() => TablePage());
      Get.snackbar("Thành công", "Đã gửi đơn tới bếp!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Không thể in đơn cho bếp: $e');
    }
  }

  double get totalAmount => items.fold(0.0, (sum, od) => sum + od.unitprice * od.quantity);

  String get orderCode => 'ORD' + orderId.toString();
}
