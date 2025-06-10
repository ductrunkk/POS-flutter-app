import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_booking/controllers/table_controller.dart';
import 'package:table_booking/helpers/supabase.helper.dart';
import 'package:table_booking/models/order_detail_model.dart';

import '../models/category_model.dart';
import '../models/dish_model.dart';

class MenuControllers extends GetxController {
  // List of categories
  final categories = <CategoryModel>[
    CategoryModel(categoryId: 0, categoryName: 'All')
  ].obs;
  // List of all dishes
  final dishes = <DishModel>[].obs;

  // Selected category ID, null = show all
  final selectedCategoryId = 0.obs;

  // Map dishId -> quantity selected
  final quantities = <int, int>{}.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchDishes();
  }

  // Fetch categories from Supabase
  Future<void> fetchCategories() async {
    final data = await Supabase.instance.client
        .from('category')
        .select()
        .order('categoryname');
    final fetched = (data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    categories
      ..clear()
      ..add(CategoryModel(categoryId: 0, categoryName: 'All'))
      ..addAll(fetched);
    // Set first category as selected by default
    if (categories.isNotEmpty) selectedCategoryId.value = categories.first.categoryId;
  }

  // Fetch dishes from Supabase
  Future<void> fetchDishes() async {
    final data = await Supabase.instance.client
        .from('dish')
        .select()
        .order('dishname');
    dishes.value = (data as List)
        .map((e) => DishModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Filtered dishes by selected category
  List<DishModel> get filteredDishes {
    if (selectedCategoryId.value == 0) return dishes;
    return dishes.where((d) => d.categoryId == selectedCategoryId.value).toList();
  }

  // Increase quantity for a dish
  void increment(int dishId) {
    quantities[dishId] = (quantities[dishId] ?? 0) + 1;
    update();
  }

  // Decrease quantity for a dish
  void decrement(int dishId) {
    final current = quantities[dishId] ?? 0;
    if (current > 0) quantities[dishId] = current - 1;
    update();
  }

  // Get quantity for a dish
  int getQuantity(int dishId) => quantities[dishId] ?? 0;

  // Place order: occupy table and go back
  // void placeOrder(int tableId) {
  //   // Mark table occupied
  //   final tableController = Get.find<TableController>();
  //   tableController.occupyTable(tableId);
  //   // Return to TablePage
  //   Get.back();
  // }

  Future<int> placeOrder(int tableId) async {
    final tableController = Get.find<TableController>();

    // 1. Đánh dấu bàn đã được sử dụng
    await tableController.occupyTable(tableId);

    // 2. Insert order mới, không truyền orderid, lấy lại orderid do Supabase tạo
    final response = await Supabase.instance.client
        .from('orders')
        .insert({
      'tableid': tableId,
      'waiterid': 7,
      'ordertime': DateTime.now().toIso8601String(),
    })
        .select('orderid') // lấy trường orderid trả về
        .single();

    if (response == null || response['orderid'] == null) {
      throw Exception('Không tạo được order mới');
    }

    final int orderId = response['orderid'] as int;

    // 3. Thêm chi tiết order
    final selected = filteredDishes.where((d) => getQuantity(d.dishId) > 0).toList();
    for (var d in selected) {
      await OrderDetailSnapshot.addOrUpdate(
        orderId,
        d.dishId,
        getQuantity(d.dishId),
        d.price,
      );
    }
    return orderId;
  }

  bool hasSelectedDishes() {
    return quantities.values.any((qty) => qty > 0);
  }
}