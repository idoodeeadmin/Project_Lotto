import 'dart:convert';

/// ----------------- Request Models -----------------

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

  // เผื่อใช้ parse ข้อมูลจาก local storage
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      fullname: json["fullname"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      walletBalance: (json["wallet_balance"] ?? 0).toDouble(),
      role: json["role"] ?? "user",
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {"email": email, "password": password};

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json["email"] ?? "",
      password: json["password"] ?? "",
    );
  }
}

/// ----------------- Response Models -----------------

RegisterResponse registerResponseFromJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

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

class LoginResponse {
  final String message;
  final String? token; // เผื่อ backend ส่ง token กลับมา
  final User? user;

  LoginResponse({required this.message, this.token, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json["message"] ?? "",
      token: json["token"], // ถ้า backend ส่ง token มาก็เก็บ
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
    );
  }
}

/// ----------------- User Model -----------------

class User {
  final String fullname;
  final String phone;
  final String email;
  final double walletBalance;
  final String role;

  User({
    required this.fullname,
    required this.phone,
    required this.email,
    this.walletBalance = 0.0,
    this.role = "user",
  });

  Map<String, dynamic> toJson() => {
    "fullname": fullname,
    "phone": phone,
    "email": email,
    "wallet_balance": walletBalance,
    "role": role,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullname: json["fullname"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      walletBalance: (json["wallet_balance"] ?? 0).toDouble(),
      role: json["role"] ?? "user",
    );
  }
}
