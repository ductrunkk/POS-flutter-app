// controller/table_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/table_model.dart';

class TableController extends GetxController {
  /// Table hiện tại được chọn
  var selectedTable = Rxn<TableModel>();
  /// Danh sách bàn
  final tables = <TableModel>[].obs;
  final selectedTableId = (-1).obs; // Mặc định không chọn bàn nào


  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  /// Lấy danh sách bàn từ Supabase
  Future<void> fetchTables() async {
    try {
      final data = await Supabase.instance.client
          .from('tablerestaurant')
          .select('tableid, tablename, status');

      tables.value = data.map((json) {
        final statusStr = (json['status'] as String).toLowerCase();
        final statusEnum = TableStatus.values.firstWhere(
              (e) => e.toString().split('.').last == statusStr,
          orElse: () => TableStatus.available,
        );
        return TableModel(
          tableId: json['tableid'] as int,
          tableName: json['tablename'] as String,
          initialStatus: statusEnum,
        );
      }).toList();
    } catch (e) {
      print('Error fetching tables: $e');
    }
  }

  /// Chọn bàn (available hoặc reserved)
  void selectTable(int index) {
    final table = tables[index];
    if (table.status.value == TableStatus.available ||
        table.status.value == TableStatus.reserved) {
      selectedTable.value = table;
    }
  }

  /// Đặt bàn
  void reserveSelectedTable() {
    final table = selectedTable.value;
    if (table != null && table.status.value == TableStatus.available) {
      table.status.value = TableStatus.reserved;
      updateTableStatus(table);
    }
  }

  /// Đánh dấu bàn occupied
  // void markTableOccupied(int index) {
  //   tables[index].status.value = TableStatus.occupied;
  //   updateTableStatus(tables[index]);
  // }

  //Future<void> updateTableStatus(TableModel table) async
  Future<void> occupyTable(int tableId) async {
    final t = tables.firstWhere((t) => t.tableId == tableId);
    t.status.value = TableStatus.occupied;
  }

  /// Thoát bàn (occupied -> available)
  void exitTable(int index) {
    final table = tables[index];
    if (table.status.value == TableStatus.occupied) {
      table.status.value = TableStatus.available;
      updateTableStatus(table);
    }
  }

  /// Hủy đặt (reserved -> available)
  // void cancelReservation(int index) {
  //   final table = tables[index];
  //   if (table.status.value == TableStatus.reserved) {
  //     table.status.value = TableStatus.available;
  //     updateTableStatus(table);
  //   }
  // }

  void reserveTable(int tableId) {
    final index = tables.indexWhere((t) => t.tableId == tableId);
    if (index != -1 && tables[index].status.value == TableStatus.available) {
      tables[index].status.value = TableStatus.reserved;
      selectedTableId.value = tableId;
      print('Đã đặt bàn $tableId');
    } else {
      Get.snackbar('Lỗi', 'Bàn không thể đặt');
    }
  }

  void cancelReservation(int tableId) {
    final index = tables.indexWhere((t) => t.tableId == tableId);
    if (index != -1 && tables[index].status.value == TableStatus.reserved) {
      tables[index].status.value = TableStatus.available;
      if (selectedTableId.value == tableId) {
        selectedTableId.value = -1;
      }
      print('Đã hủy đặt bàn $tableId');
    } else {
      Get.snackbar('Lỗi', 'Bàn chưa được đặt');
    }
  }

  void moveTable(int fromTableId) {
    final fromIndex = tables.indexWhere((t) => t.tableId == fromTableId);
    if (fromIndex == -1 || tables[fromIndex].status.value != TableStatus.occupied) {
      Get.snackbar('Lỗi', 'Bàn này không thể chuyển');
      return;
    }

    final availableTable = tables.firstWhereOrNull((t) => t.status.value == TableStatus.available);
    if (availableTable == null) {
      Get.snackbar('Không có bàn trống', 'Vui lòng thử lại sau');
      return;
    }

    // Chuyển trạng thái
    tables[fromIndex].status.value = TableStatus.available;
    final toIndex = tables.indexOf(availableTable);
    tables[toIndex].status.value = TableStatus.occupied;

    selectedTableId.value = availableTable.tableId;
    print('Chuyển bàn $fromTableId sang bàn ${availableTable.tableId}');
  }


  /// Cập nhật status lên Supabase
  Future<void> updateTableStatus(TableModel table) async {
    try {
      await Supabase.instance.client
          .from('tablerestaurant')
          .update({
        'status': table.status.value.toString().split('.').last
      })
          .eq('tableid', table.tableId);
    } catch (e) {
      print('Error updating table status: $e');
    }
  }

  /// Nhãn hiển thị cho UI
  String getStatusLabel(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.occupied:
        return 'Occupied';
    }
  }

  /// Lấy ID bàn đang chọn
  int? getSelectedTableId() => selectedTable.value?.tableId;
}
