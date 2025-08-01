import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_booking/controllers/employee_controller.dart';
import 'package:table_booking/pages/login_page.dart';
import 'package:table_booking/pages/table_page.dart';

import '../helpers/my_helper.dart';

class AuthController {
  static Future<void> login({
    required String email,
    required String pwd,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: pwd,
      );

      final User user = res.user!;
      if (user != null) {
        final employeeController = EmployeeController.get();

        await employeeController.getEmployee();

        Get.offAll(() => TablePage());
      }
    } on AuthException catch (e) {
      // if (e.message == "Email not confirmed") {
      //   await supabase.auth.signInWithOtp(email: email);
      //   Get.back();
      //   Get.to(() => PageVerifyEmail(email: email));
      // }

      if (e.message == "Invalid login credentials") {
        Get.back();
        showSnackBar(success: false, desc: "Incorrect password or email");
      }
    }
  }

  static Future<void> signOut() async {
    // final userController = UserController.get();
    final supabase = Supabase.instance.client;
    final employeeController = EmployeeController.get();

    await supabase.auth.signOut();
    employeeController.emp = null;
    Get.offAll(() => PageLogin());

    // await SupabaseSnapshot.update(
    //   table: AppUser.tableName,
    //   updateObject: {"is_active": false},
    //   equalObject: {"user_id": userController.appUser!.userId},
    // );

    // Reset controllers

    // userController.appUser = null;
    //
    // HomePizzaStoreController.get().refreshHome();
  }
}
