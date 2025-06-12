import 'package:supabase_flutter/supabase_flutter.dart';

/// Trình bao bọc tiện ích Supabase cho các thao tác CRUD phổ biến
class SupabaseSnapshot {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Lấy danh sách bản ghi từ [table], ánh xạ từng mục bằng [fromJson].
  /// Tuỳ chọn lọc bằng [equalObject], và áp dụng [selectString] (ví dụ: '*, dish(*)').
  static Future<List<T>> getList<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? equalObject,
    String? selectString,
  }) async {
    var query = _client.from(table).select(selectString ?? '*');
    if (equalObject != null) {
      equalObject.forEach((field, value) {
        query = query.eq(field, value);
      });
    }
    final response = await query;
    final data = response as List<dynamic>;
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<T> getById<T>({
    required String table,
    required T Function(Map<String, dynamic> json) fromJson,
    String selectString = "",
    required String idKey,
    required String idValue,
  }) async {
    var data =
        await _client
            .from(table)
            .select(selectString)
            .eq(idKey, idValue)
            .single();

    return fromJson(data);
  }

  /// Lấy bản đồ các bản ghi với khoá được chỉ định bởi [getId] từ [table].
  static Future<Map<K, T>> getMapT<K, T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    required K Function(T) getId,
    Map<String, dynamic>? equalObject,
    String? selectString,
  }) async {
    final list = await getList(
      table: table,
      fromJson: fromJson,
      equalObject: equalObject,
      selectString: selectString,
    );
    final map = <K, T>{};
    for (var item in list) {
      map[getId(item)] = item;
    }
    return map;
  }

  /// Thêm một bản ghi vào [table] với [insertObject].
  static Future<void> insert({
    required String table,
    required Map<String, dynamic> insertObject,
  }) async {
    final response = await _client.from(table).insert(insertObject);
  }

  /// Cập nhật các bản ghi trong [table] khớp với [equalObject] bằng [updateObject].
  static Future<void> update({
    required String table,
    required Map<String, dynamic> updateObject,
    required Map<String, dynamic> equalObject,
  }) async {
    var query = _client.from(table).update(updateObject);
    equalObject.forEach((field, value) {
      query = query.eq(field, value);
    });
    await query;
  }

  /// Xoá các bản ghi từ [table] khớp với [equalObject].
  static Future<void> delete({
    required String table,
    required Map<String, dynamic> equalObject,
  }) async {
    var query = _client.from(table).delete();
    equalObject.forEach((field, value) {
      query = query.eq(field, value);
    });
    await query;
  }
}
