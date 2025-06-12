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
  final RxMap<int, int?> currentOrders = <int, int?>{}.obs; // tableId → orderId

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

   Future<int?> getOrderIdForTable(int tableId) async {
    final orderId = await TableSnapshot.getOrderIdForTable(tableId);
    return orderId;
  }
  /// Lấy danh sách bàn từ Supabase
  Future<void> fetchTables() async {
    try {
      final data = await Supabase.instance.client
          .from('tablerestaurant')
          .select('tableid, tablename, status').order('tableid', ascending: true);

      tables.value = data.map((json) {

        return TableModel(
          tableId: json['tableid'] as int,
          tableName: json['tablename'] as String,
          status: TableStatus.fromString(json["status"]),
        );
      }).toList();
    } catch (e) {
      print('Error fetching tables: $e');
    }
  }

  /// Cập nhật status lên Supabase
    Future<void> updateTableStatus(int tableId, String status) async {
    try {
      await Supabase.instance.client
          .from('tablerestaurant')
          .update({
        'status': status
      })
          .eq('tableid', tableId);
      await fetchTables();
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


}
