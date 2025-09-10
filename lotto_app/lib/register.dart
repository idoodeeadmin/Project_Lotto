import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameCtl = TextEditingController();
  final TextEditingController phoneCtl = TextEditingController();
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();
  final TextEditingController walletCtl = TextEditingController();

  Future<void> register() async {
    if (nameCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        emailCtl.text.isEmpty ||
        passCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    var data = {
      "fullname": nameCtl.text,
      "phone": phoneCtl.text,
      "email": emailCtl.text,
      "password": passCtl.text,
      "wallet_balance": double.tryParse(walletCtl.text) ?? 0,
      "role": "user",
    };

    try {
      var url = Uri.parse("${AppConfig.apiEndpoint}/register");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("สมัครสมาชิกสำเร็จ")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครไม่สำเร็จ: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E46),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Image.asset(
                      'lib/assets/logo.webp',
                      width: 120,
                      height: 120,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    "สมัครสมาชิก",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'ชื่อ-นามสกุล',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtl,
                  decoration: InputDecoration(
                    hintText: 'กรอกชื่อ-นามสกุล',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'เบอร์โทรศัพท์',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtl,
                  decoration: InputDecoration(
                    hintText: 'กรอกเบอร์โทรศัพท์',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Email',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtl,
                  decoration: InputDecoration(
                    hintText: 'กรอก Email ของคุณ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Password',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'กรอกรหัสผ่าน',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Wallet Balance (optional)',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: walletCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'กรอกจำนวนเงิน',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 202, 29, 29),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "สมัครสมาชิก",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
