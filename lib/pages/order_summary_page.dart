import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_booking/pages/menu_page.dart';
import 'package:table_booking/pages/table_page.dart';
import '../controllers/order_summary_controller.dart';

class OrderSummaryPage extends StatelessWidget {
  final int orderId;
  final int tableId;

  const OrderSummaryPage({super.key,
    required this.orderId,
    required this.tableId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSummaryController>(
      builder: (c) => Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đơn')),
        body: c.loading
            ? const Center(child: CircularProgressIndicator())
            : c.error != null
            ? Center(child: Text('Error: ${c.error}'))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧾 Mã đơn: ${c.orderCode}', style: const TextStyle(fontSize: 16)),
              Text('🪑 Bàn: $tableId ', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30),
              const Text('📋 Danh sách món:', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: c.items.length,
                  itemBuilder: (_, i) {
                    final od = c.items[i];
                    return ListTile(
                      title: Text(od.dishname, style: TextStyle(fontSize: 20),),
                      subtitle: Text('x${od.quantity} - ${od.unitprice.toStringAsFixed(0)} \$',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
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
                  const Text('Tổng cộng:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${c.totalAmount.toStringAsFixed(0)} \$', style: const TextStyle(fontSize: 20, color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await c.handleCancel(orderId);
                        if (success) {
                          Get.back();
                        } else {
                          Get.snackbar("Lỗi", "Không thể hủy đơn hàng", backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('HỦY ĐƠN', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await c.printToKitchen(orderId);
                        // Get.offAll(() => TablePage());
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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