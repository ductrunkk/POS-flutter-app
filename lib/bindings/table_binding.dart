import 'package:get/get.dart';

import '../controllers/table_controller.dart';

class TableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableController>(() => TableController(), fenix: true);
  }
}
