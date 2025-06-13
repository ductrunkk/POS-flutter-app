import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_booking/bindings/order_summary_binding.dart';
import 'package:table_booking/controllers/menu_controller.dart';
import 'package:table_booking/pages/order_summary_page.dart';
import '../controllers/order_summary_controller.dart';
import '../models/dish_model.dart';
import '../models/order_detail_model.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MenuControllers c = Get.find();
    final args = Get.arguments as Map<String, dynamic>;
    final int tableId = args['tableId'] as int;
    final int? existingOrderId = args['orderId'] as int?;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: Column(
        children: [
          // ... phần filter và grid giữ nguyên như trước ...
          Expanded(
            child: Obx(() {
              final list = c.filteredDishes;
              if (list.isEmpty) return const Center(child: CircularProgressIndicator());
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.7,
                  crossAxisSpacing: 10, mainAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final DishModel d = list[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: d.imageUrl != null
                                ? Image.network(d.imageUrl!, fit: BoxFit.cover)
                                : Container(color: Colors.grey[200]),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.dishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${d.price.toStringAsFixed(2)} ₫'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: Obx(() {
                            final qty = c.getQuantity(d.dishId);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => c.decrement(d.dishId),
                                ),
                                Text('$qty'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => c.increment(d.dishId),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // Nút "Tạo đơn & Thêm món" hoặc "Thêm món"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final isEnabled = c.quantities.values.any((q) => q > 0);
              return ElevatedButton(
                onPressed: isEnabled
                    ? () async {
                  // 1. Tạo mới order nếu cần
                  int orderId = existingOrderId ?? await c.placeOrder(tableId);

                  // 2. Upsert tất cả món user đã chọn
                  for (final entry in c.quantities.entries) {
                    final dishId = entry.key;
                    final qty = entry.value;
                    if (qty > 0) {
                      final dish = c.dishes.firstWhere((d) => d.dishId == dishId);
                      await OrderDetailSnapshot.addOrUpdate(
                        orderId,
                        dishId,
                        qty,
                        dish.price,
                      );
                    }
                  }

                  // 3. Điều hướng thẳng sang OrderSummaryPage
                  Get.off(
                        () => OrderSummaryPage(
                      orderId: orderId,
                      tableId: tableId,
                      isConfirmationMode: true,
                    ),
                    binding: OrderSummaryBinding(),
                    arguments: {
                      'orderId': orderId,
                      'tableId': tableId,
                      'isConfirmationMode': true,
                    },
                  );
                }
                    : null,
                child: Text(
                  existingOrderId != null ? 'Thêm món vào đơn' : 'Tạo đơn & thêm món',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
