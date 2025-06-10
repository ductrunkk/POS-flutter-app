import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/menu_binding.dart';
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

      ),
      body: Obx(() {
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
              final isSelected = c.getSelectedTableId() == table.tableId;

              // Chọn màu nền theo trạng thái
              Color bg;
              switch (table.status.value) {
                case TableStatus.available:
                  bg = isSelected ? Colors.blue[200]! : Colors.white;
                  break;
                case TableStatus.reserved:
                  bg = Colors.amber[300]!;
                  break;
                case TableStatus.occupied:
                  bg = Colors.green[300]!;
                  break;
              }

              return GestureDetector(
                onTap: () {
                  // Khi tap vào tile → chuyển sang MenuPage, truyền tableId
                  Get.to(
                        () => MenuPage(),
                    binding: MenuBinding(),
                    arguments: {'tableId': table.tableId},
                  );
                },
                child: Stack(
                  children: [
                    // Tile chính
                    Container(
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: Colors.grey),
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
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.getStatusLabel(table.status.value),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
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
                            case 'reserve':
                              c.reserveTable(table.tableId);
                              break;
                            case 'cancel':
                              c.cancelReservation(table.tableId);
                              break;
                            case 'move':
                              c.moveTable(table.tableId);
                              break;
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'reserve', child: Text('Đặt bàn')),
                          PopupMenuItem(value: 'cancel', child: Text('Hủy bàn')),
                          PopupMenuItem(value: 'move',   child: Text('Chuyển bàn')),
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
    );
  }
}
