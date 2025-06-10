import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeModel{
  final int employeeId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String role;

  EmployeeModel({
    required this.employeeId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
    required this.role,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeid'] as int,
      fullName: json['fullname'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phonenumber'] as String?,
      password: json['password'] as String?,
      role: json['role'] as String,
    );
  }
}

class EmployeeSnapshot{
  static Future<String> getWaiterName(int waiterId) async {
    final response = await Supabase.instance.client
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
}