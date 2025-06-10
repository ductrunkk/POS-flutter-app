import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_booking/bindings/order_summary_binding.dart';
import 'package:table_booking/controllers/menu_controller.dart';
import 'package:table_booking/pages/order_summary_page.dart';

import '../models/dish_model.dart';

class MenuPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final MenuControllers c = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Column(
        children: [
          // Category filter bar
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: c.categories.map((cat) {
                  final selected = cat.categoryId == c.selectedCategoryId.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat.categoryName),
                      selected: selected,
                      onSelected: (_) {
                        c.selectedCategoryId.value = cat.categoryId;
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          // Dishes grid
          Expanded(
            child: Obx(() {
              final list = c.filteredDishes;
              if (list.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final DishModel d = list[i];
                  final qty = c.getQuantity(d.dishId);
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Image chiếm flex = 3
                        Expanded(
                          flex:2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: d.imageUrl != null
                                ? Image.network(d.imageUrl!, fit: BoxFit.cover)
                                : Container(color: Colors.grey[200]),
                          ),
                        ),
                        // 2. Phần info cố định chiều cao
                        SizedBox(
                          height: 50, // giảm xuống cho vừa đủ tên + giá
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.dishName,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${d.price.toStringAsFixed(2)} ₫'),
                              ],
                            ),
                          ),
                        ),
                        // 3. Phần selector số lượng cố định
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

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GetBuilder<MenuControllers>(
              builder: (c) {
                final isEnabled = c.quantities.values.any((q) => q > 0);
                return ElevatedButton(
                  onPressed: isEnabled
                      ? () async {
                    final args = Get.arguments as Map<String, dynamic>;
                    final tableId = args['tableId'] as int;
                    final orderId = await c.placeOrder(tableId);
                    Get.to(
                          () => OrderSummaryPage(orderId: orderId, tableId: tableId),
                      binding: OrderSummaryBinding(),
                      arguments: {'orderId': orderId, 'tableId': tableId},
                    );
                  }
                      : null,
                  child: const Text('Thêm vào đơn'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
