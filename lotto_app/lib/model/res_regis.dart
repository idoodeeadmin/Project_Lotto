import 'dart:convert';

/// ----------------- Request Model -----------------
class RegisterRequest {
  final String fullname;
  final String phone;
  final String email;
  final String password;
  final double walletBalance;
  final String role;

  RegisterRequest({
    required this.fullname,
    required this.phone,
    required this.email,
    required this.password,
    this.walletBalance = 0.0,
    this.role = "user",
  });

  Map<String, dynamic> toJson() => {
    "fullname": fullname,
    "phone": phone,
    "email": email,
    "password": password,
    "wallet_balance": walletBalance,
    "role": role,
  };
}

/// ----------------- Response Model -----------------
RegisterResponse registerResponseFromJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));

class RegisterResponse {
  final String message;
  final User? user;

  RegisterResponse({required this.message, this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json["message"] ?? "",
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
    );
  }
}

class User {
  final String fullname;
  final String phone;
  final String email;
  final String password;
  final double walletBalance;
  final String role;

  User({
    required this.fullname,
    required this.phone,
    required this.email,
    required this.password,
    this.walletBalance = 0, // ค่า default
    this.role = "user",
  });

  // แปลง User -> JSON
  Map<String, dynamic> toJson() {
    return {
      "fullname": fullname,
      "phone": phone,
      "email": email,
      "password": password,
      "wallet_balance": walletBalance,
      "role": role,
    };
  }

  // เผื่อใช้เวลา API ส่ง user กลับมา
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullname: json['fullname'] ?? "",
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      role: json['role'] ?? "user",
    );
  }
}
