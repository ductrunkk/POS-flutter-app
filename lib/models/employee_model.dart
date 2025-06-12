import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_booking/helpers/supabase.helper.dart';

class EmployeeModel {
  final int employeeId;
  final String accountId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String role;

  static String tableName = "employee";
  EmployeeModel({
    required this.employeeId,
    required this.accountId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
    required this.role,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeid'] as int,
      fullName: json['fullname'] as String,
      email: json['email'] as String,
      accountId: json['account_id'] as String,
      phoneNumber: json['phonenumber'] as String?,
      password: json['password'] as String?,
      role: json['role'] as String,
    );
  }
}

class EmployeeSnapshot {
  static Future<String> getWaiterName(int waiterId) async {
    final response =
        await Supabase.instance.client
            .from('employee')
            .select('fullname')
            .eq('employeeid', waiterId)
            .maybeSingle();

    if (response == null) {
      print('Không tìm thấy nhân viên với ID $waiterId');
      throw Exception('Không tìm thấy nhân viên.');
    }
    print(' Nhân viên: ${response['fullname']}');
    return response['fullname'] as String;
  }

  static Future<EmployeeModel> getCurrentEmployee({required String id}) async {
    EmployeeModel emp = await SupabaseSnapshot.getById(
      table: EmployeeModel.tableName,
      fromJson: EmployeeModel.fromJson,
      idKey: "account_id",
      idValue: id,
    );
    return emp;
  }
}
