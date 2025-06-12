import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_booking/models/order_detail_model.dart';
import 'package:table_booking/models/table_model.dart';

class OrderModel {
  final int orderId;
  final int tableId;
  final int waiterId;
  final int? invoiceId;
  final DateTime orderTime;

  OrderModel({
    required this.orderId,
    required this.tableId,
    required this.waiterId,
    this.invoiceId,
    required this.orderTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {

    return OrderModel(
      orderId: json['orderid'] as int,
      tableId: json['tableid'] as int,
      waiterId: json['waiterid'] as int,
      invoiceId: json['invoiceid'] as int?,
      // Chuyển đổi chuỗi ISO 8601 từ JSON thành đối tượng DateTime
      orderTime: DateTime.parse(json['ordertime'] as String),
    );
  }
}

class OrderSnapshot {
  static const _table = 'orders';

  /// Lấy danh sách orders theo waiterId (ví dụ)
  static Future<List<OrderModel>> fetchByWaiterId(int waiterId) async {
    try {
      final data = await Supabase.instance.client
          .from(_table)
          .select()
          .eq('waiterid', waiterId)
          .order('ordertime', ascending: false) as List<dynamic>;

      return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Thêm order mới và trả về orderId
  static Future<int> insertOrder(int tableId, int waiterId) async {
    try {
      final data = await Supabase.instance.client.from(_table).insert({
        'tableid': tableId,
        'waiterid': waiterId,
        'ordertime': DateTime.now().toIso8601String(),
      }) as List<dynamic>;

      return data[0]['orderid'] as int;
    } catch (e) {
      throw Exception('Failed to insert order: $e');
    }
  }

  /// Cập nhật invoiceId cho order (ví dụ)
  // static Future<void> updateInvoiceId(int orderId, int invoiceId) async {
  //   try {
  //     await Supabase.instance.client.from(_table).update({
  //       'invoiceid': invoiceId,
  //     }).eq('orderid', orderId);
  //   } catch (e) {
  //     throw Exception('Failed to update invoiceId: $e');
  //   }
  // }

  /// Xóa order theo orderId
  static Future<void> deleteOrder(int orderId) async {
    try {
      await Supabase.instance.client
          .from(_table)
          .delete()
          .eq('orderid', orderId);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      await Supabase.instance.client
          .from(_table)
          .delete()
          .eq('orderid', orderId);
      return true;
    } catch (e) {
      print('Cancel order error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getOrderWithTableName(int orderId) async {
    try {
      final data = await Supabase.instance.client
          .from(_table)
          .select('orderid, tableid, waiterid, invoiceid, ordertime, tablerestaurant (tablename)')
          .eq('orderid', orderId)
          .single();

      final order = OrderModel.fromJson(data);
      final tableName = data['tablerestaurant']['tablename'] as String;

      return {
        'order': order,
        'tableName': tableName,
      };
    } catch (e) {
      throw Exception('Failed to fetch order with table name: $e');
    }
  }


}
