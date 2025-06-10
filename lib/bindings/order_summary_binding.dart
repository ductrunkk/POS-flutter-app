import 'package:get/get.dart';
import '../controllers/order_summary_controller.dart';

class OrderSummaryBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final orderId = args['orderId'] as int;
    Get.lazyPut<OrderSummaryController>(() => OrderSummaryController(orderId));
  }
}