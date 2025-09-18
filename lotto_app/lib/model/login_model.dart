import 'dart:convert';

/// ----------------- Login Request -----------------
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

/// ----------------- Login Response -----------------
LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

class LoginResponse {
  final String message;
  final Customer? customer;

  LoginResponse({required this.message, this.customer});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json["message"] ?? "",
      customer: json["customer"] != null
          ? Customer.fromJson(json["customer"])
          : null,
    );
  }
}

/// ----------------- Customer Model -----------------
/// เก็บข้อมูลทุก field ยกเว้น password
class Customer {
  final int cusId;
  final String fullname;
  final String phone;
  final String email;
  double walletBalance;
  final String role;

  Customer({
    required this.cusId,
    required this.fullname,
    required this.phone,
    required this.email,
    required this.walletBalance,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "cus_id": cusId,
      "fullname": fullname,
      "phone": phone,
      "email": email,
      "wallet_balance": walletBalance,
      "role": role,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cusId: json['cus_id'] ?? 0,
      fullname: json['fullname'] ?? "",
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      role: json['role'] ?? "user",
    );
  }
}
