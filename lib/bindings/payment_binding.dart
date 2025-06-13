import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(() => PaymentController(
      invoiceId: Get.arguments['invoiceId'] as int,
      orderId:   Get.arguments['orderId']   as int,
      tableId:   Get.arguments['tableId']   as int,
    ));
  }
}