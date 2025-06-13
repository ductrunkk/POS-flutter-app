import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailModel {
  final int orderid;
  final int dishid;
  final String dishname;
  final int quantity;
  final double unitprice;

  OrderDetailModel({
    required this.orderid,
    required this.dishid,
    required this.dishname,
    required this.quantity,
    required this.unitprice,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      orderid: json['orderid'],
      dishid: json['dishid'],
      dishname: json['dish']['dishname'],
      quantity: json['quantity'],
      unitprice: (json['unitprice'] as num).toDouble(),
    );
  }
}

class OrderDetailSnapshot {
  static const _table = 'orderdetail';

  // List<OrderDetailModel> orderDetails = [];
  // Future<void> fetchOrderDetails(int orderId) async {
  //   final res = await Supabase.instance.client
  //       .from('orderdetail')
  //       .select('orderid, dishid, quantity, unitprice, dish(dishname)')
  //       .eq('orderid', orderId);
  //
  //   orderDetails = (res as List)
  //       .map((e) => OrderDetailModel.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }

  /// Lấy danh sách order details cho 1 orderId (kèm dish nested)
  static Future<List<OrderDetailModel>> fetchByOrderId(int orderId) async {
    final data = await Supabase.instance.client
        .from(_table)
        .select('*, dish(*)')
        .eq('orderid', orderId);

    return (data as List)
        .map((e) => OrderDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addOrUpdate(int orderId, int dishId, int amount, double unitPrice) async {
    try {
      await Supabase.instance.client
          .from(_table)
          .upsert(
        {
          'orderid': orderId,
          'dishid': dishId,
          'quantity': amount,
          'unitprice': unitPrice,
        },
        onConflict: 'orderid,dishid', // chuỗi thay vì List
      );
    } catch (e) {
      print('Failed to add or update order detail: $e');
    }
  }

  //hàm thêm món mới cho order
  static Future<List<OrderDetailModel>> addNewItemsOnly(int orderId, List<OrderDetailModel> itemsToAdd) async {
    final List<OrderDetailModel> insertedItems = [];

    for (final item in itemsToAdd) {
      final existing = await Supabase.instance.client
          .from('OrderDetail')
          .select()
          .eq('orderid', orderId)
          .eq('dishid', item.dishid)
          .maybeSingle();

      if (existing == null) {
        final res = await Supabase.instance.client
            .from('OrderDetail')
            .insert({
          'orderid': orderId,
          'dishid': item.dishid,
          'quantity': item.quantity,
          'unitprice': item.unitprice,
        })
            .select('*, dish(dishname)')
            .single();

        insertedItems.add(OrderDetailModel.fromJson(res));
      } else {
        await Supabase.instance.client
            .from('OrderDetail')
            .update({
          'quantity': (existing['quantity'] as int) + item.quantity,
        })
            .eq('orderid', orderId)
            .eq('dishid', item.dishid);
      }
    }

    return insertedItems;
  }

  /// Xóa món khỏi order
  static Future<void> remove(int orderId, int dishId) async {
    await Supabase.instance.client
        .from(_table)
        .delete()
        .eq('orderid', orderId)
        .eq('dishid', dishId);
  }

  /// Xóa sạch tất cả chi tiết của một order
  static Future<void> clear(int orderId) async {
    await Supabase.instance.client
        .from(_table)
        .delete()
        .eq('orderid', orderId);
  }
}
