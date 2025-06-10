import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_summary_controller.dart';

class ServingPage extends StatelessWidget {
  final int orderId;
  final int tableId;

  const ServingPage({
    super.key,
    required this.orderId,
    required this.tableId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSummaryController>(
      builder: (c) => Scaffold(
        appBar: AppBar(title: const Text('Đơn đang phục vụ')),
        body: c.loading
            ? const Center(child: CircularProgressIndicator())
            : c.error != null
            ? Center(child: Text('Lỗi: ${c.error}'))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧾 Mã đơn: ${c.orderCode}', style: const TextStyle(fontSize: 16)),
              Text('🪑 Bàn: $tableId', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30),
              const Text('📋 Danh sách món:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: c.items.length,
                  itemBuilder: (_, i) {
                    final od = c.items[i];
                    return ListTile(
                      title: Text(od.dishname, style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                        'x${od.quantity} - ${od.unitprice.toStringAsFixed(0)} đ',
                        style: const TextStyle(fontSize: 20),
                      ),
                      trailing: Text(
                        '${(od.unitprice * od.quantity).toStringAsFixed(0)} đ',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${c.totalAmount.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                          fontSize: 20, color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: xử lý tạm tính
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('TẠM TÍNH'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: xử lý thanh toán
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('THANH TOÁN', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Mở trang thêm món
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
