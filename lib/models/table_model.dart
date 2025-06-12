// model/table_model.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TableStatus { available, reserved, occupied;
static TableStatus fromString(String status) {
  switch(status) {
    case "available":
      return TableStatus.available;
    case "occupied":
      return TableStatus.occupied;
    case "reserved":
      return TableStatus.reserved;
    default:
      return TableStatus.available;
  }
}

}

class TableModel {
  final int tableId;
  final String tableName;
  final TableStatus status;

  TableModel({
    required this.tableId,
    required this.tableName,
    required this.status,
  });

  /// Tạo đối tượng từ JSON (map từ DB)
  factory TableModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String;
    return TableModel(
      tableId: json['tableid'] as int,
      tableName: json['tablename'] as String,
      status: TableStatus.fromString(json["status"]),

    );
  }
}

class TableSnapshot{
  TableModel tableModel;
  TableSnapshot(this.tableModel);

  static Future<int?> getOrderIdForTable(int tableId) async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('tableid', tableId).filter('invoiceid', 'is', null)
          .limit(1);

      if (data.isNotEmpty) {
        return data[0]['orderid'] as int;
      }
      return null;
    } catch (e) {
      print('Error getting orderId for table: $e');
      return null;
    }
  }

}