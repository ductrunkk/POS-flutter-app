// model/table_model.dart
import 'package:get/get.dart';

enum TableStatus { available, reserved, occupied }

class TableModel {
  final int tableId;
  final String tableName;
  final Rx<TableStatus> status;

  TableModel({
    required this.tableId,
    required this.tableName,
    required TableStatus initialStatus,
  }) : status = Rx<TableStatus>(initialStatus);

  /// Tạo đối tượng từ JSON (map từ DB)
  factory TableModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String;
    return TableModel(
      tableId: json['tableid'] as int,
      tableName: json['tablename'] as String,
      initialStatus: TableStatus.values.firstWhere(
            (e) => e.toString().split('.').last == statusStr,
        orElse: () => TableStatus.available,
      ),
    );
  }
}