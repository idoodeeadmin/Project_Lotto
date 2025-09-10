import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'register.dart';
import 'config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();

  Future<void> login() async {
    if (emailCtl.text.isEmpty || passCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    var data = {"email": emailCtl.text, "password": passCtl.text};

    try {
      var url = Uri.parse("${AppConfig.apiEndpoint}/login");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        var user = res["user"];
        String fullname = user["fullname"];
        String role = user["role"];

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("ยินดีต้อนรับ $fullname")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(fullname: fullname, role: role),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เข้าสู่ระบบไม่สำเร็จ: ${response.body}")),
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
                // ปุ่มสมัครสมาชิก
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 72, 74, 94),
                    ),
                    child: const Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // โลโก้ตรงกลาง
                Center(
                  child: Image.asset(
                    'lib/assets/logo.webp',
                    width: 300,
                    height: 300,
                  ),
                ),
                const SizedBox(height: 10),

                // Email
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

                // Password
                const Text(
                  'Password',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'กรอกรหัสผ่านของคุณ',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        //ไว้ก่อน
                      },
                      child: const Text(
                        'ลืมรหัสผ่าน?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 180, 14, 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
