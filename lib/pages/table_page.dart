import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_booking/controllers/employee_controller.dart';
import 'package:table_booking/pages/order_summary_page.dart';
import 'package:table_booking/pages/profile_page.dart';
import '../bindings/menu_binding.dart';
import '../bindings/order_summary_binding.dart';
import '../controllers/table_controller.dart';
import '../models/table_model.dart';
import 'menu_page.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<TableController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Bàn'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              icon: const Icon(Icons.person, size: 35),
              onPressed: () {
                Get.to(
                  () => ProfilePage(),
                  binding: BindingsEmployeeController(),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => c.fetchTables(),
        child: Obx(() {
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: c.tables.length,
            itemBuilder: (context, index) {
              // mỗi ô bàn tự observe selectedTable và status
              return Obx(() {
                final table = c.tables[index];
                // final isSelected = c.getSelectedTableId() == table.tableId;

                // Chọn màu nền theo trạng thái
                Color bg;
                switch (table.status.name) {
                  case "available":
                    bg = Colors.white;
                    break;
                  case "reserved":
                    bg = Colors.amber[300]!;
                    break;
                  case "occupied":
                    bg = Colors.green[300]!;
                    break;
                  default:
                    bg = Colors.white;
                }

                return GestureDetector(
                  onTap: () async {
                    if (table.status.name == TableStatus.occupied.name) {
                      final orderId = await c.getOrderIdForTable(table.tableId);

                      if (orderId != null) {
                        Get.to(
                          () => OrderSummaryPage(
                            orderId: orderId,
                            tableId: table.tableId,
                            isConfirmationMode: false,
                          ),
                          binding: OrderSummaryBinding(),
                          arguments: {
                            'orderId': orderId,
                            'tableId': table.tableId,
                            'isConfirmationMode': false,
                          },
                        );
                      } else {
                        // Optional: báo lỗi hoặc fallback
                      }
                    } else {
                      Get.to(
                        () => MenuPage(),
                        binding: MenuBinding(),
                        arguments: {'tableId': table.tableId},
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      // Tile chính
                      Container(
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: Colors.grey, width: 2.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                table.tableName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                table.status.name,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Icon 3 chấm góc trên bên phải
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            switch (value) {
                              case 'reserved':
                                if (table.status.name ==
                                    TableStatus.occupied.name) {
                                  break;
                                }
                                c.updateTableStatus(
                                  table.tableId,
                                  TableStatus.reserved.name,
                                );
                                break;
                              case 'cancel':
                                if (table.status.name ==
                                    TableStatus.occupied.name) {
                                  break;
                                }
                                c.updateTableStatus(
                                  table.tableId,
                                  TableStatus.available.name,
                                );
                                break;
                            }
                          },
                          itemBuilder:
                              (_) => const [
                                PopupMenuItem(
                                  value: 'reserved',
                                  child: Text('Đặt bàn'),
                                ),
                                PopupMenuItem(
                                  value: 'cancel',
                                  child: Text('Hủy bàn'),
                                ),
                              ],
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          );
        }),
      ),
    );
  }
}
