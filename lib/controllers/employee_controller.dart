import 'package:get/get.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:table_booking/models/employee_model.dart';

class EmployeeController extends GetxController {
  EmployeeModel? emp;
  bool isLoading = false;
  final supabase = Supabase.instance.client.auth;
  static EmployeeController get() => Get.find();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getEmployee();
  }

  Future<void> getEmployee() async {
    isLoading = true;
    update(["profile"]);
    emp = await EmployeeSnapshot.getCurrentEmployee(
      id: supabase.currentUser!.id,
    );
    isLoading = false;
    update(["profile"]);
  }
}

class BindingsEmployeeController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeController(), fenix: true);
  }
}
