import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_booking/pages/menu_page.dart';
import 'package:table_booking/pages/payment_page.dart';
import 'package:table_booking/pages/table_page.dart';
import '../bindings/menu_binding.dart';
import '../bindings/payment_binding.dart';
import '../controllers/order_summary_controller.dart';
import '../models/invoice_model.dart';

class OrderSummaryPage extends StatelessWidget {
  final int orderId;
  final int tableId;
  final bool isConfirmationMode;

  const OrderSummaryPage({
    super.key,
    required this.orderId,
    required this.tableId,
    required this.isConfirmationMode,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSummaryController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(
            isConfirmationMode ? 'Xác nhận đơn' : 'Đơn đang phục vụ',
          ),
        ),
        body: c.loading
            ? const Center(child: CircularProgressIndicator())
            : c.error != null
            ? Center(child: Text('Error: ${c.error}'))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn: ${c.orderCode}', style: const TextStyle(fontSize: 16)),
              Text('Bàn: $tableId ', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30),
              const Text('Danh sách món:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: c.items.length,
                  itemBuilder: (_, i) {
                    final od = c.items[i];
                    return ListTile(
                      title: Text(
                        od.dishname,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        'x${od.quantity} - ${od.unitprice.toStringAsFixed(0)} \$',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${(od.unitprice * od.quantity).toStringAsFixed(0)} \$',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng cộng:',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('${c.totalAmount.toStringAsFixed(0)} \$',
                      style: const TextStyle(
                          fontSize: 30, color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: isConfirmationMode
                        ? ElevatedButton.icon(
                      onPressed: () async {
                        final success = await c.handleCancel(orderId);
                        if (success) {
                          Get.back();
                        } else {
                          Get.snackbar("Lỗi", "Không thể hủy đơn hàng",
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('HỦY ĐƠN',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                        : ElevatedButton.icon(
                      onPressed: () async {
                        await Get.to(
                              () => MenuPage(),
                          binding: MenuBinding(),
                          arguments: {
                            'tableId': tableId,
                            'orderId': orderId,
                          },
                        );
                        await c.loadOrderDetails();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('THÊM MÓN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (isConfirmationMode) {
                          await c.printToKitchen(orderId);
                        } else {
                          final amount = c.totalAmount;
                          final invoiceId = await InvoiceSnapshot.createInvoice(
                            orderId: orderId,
                            cashierId: 7,
                            totalAmount: amount,
                          );
                          Get.to(
                                () => PaymentPage(),
                            binding: PaymentBinding(),
                            arguments: {
                              'invoiceId': invoiceId,
                              'orderId': orderId,
                              'tableId': tableId,
                            },
                          );
                        }
                      },
                      icon: Icon(isConfirmationMode
                          ? Icons.check_circle
                          : Icons.payment),
                      label: Text(
                        isConfirmationMode ? 'XÁC NHẬN' : 'THANH TOÁN',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isConfirmationMode ? Colors.green : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
