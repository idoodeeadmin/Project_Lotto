import 'package:flutter/material.dart';
import 'home.dart';
import 'mylotto.dart';
import 'login.dart';
import 'random.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import 'model/login_model.dart';
import 'model/global_data.dart';
import 'ShowallLotto.dart';

class SettingPage extends StatelessWidget {
  final Customer customer;

  const SettingPage({super.key, required this.customer});

  Future<void> _resetSystem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยัน"),
        content: const Text(
          "คุณต้องการรีเซ็ตระบบใช่หรือไม่? ข้อมูลทั้งหมด (ยกเว้น admin) จะถูกลบ",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/reset-system"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ล้าง global state หลัง reset
        globalPrizeNumbers = [];
        globalAllNumbers = [];
        globalSoldNumbers = [];
        globalCurrentRound = 1; // หรือ 0 ถ้าอยากให้ไม่มีงวดเลย

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "รีเซ็ตระบบเรียบร้อยแล้ว")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("รีเซ็ตระบบล้มเหลว")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ฟังก์ชันใหม่สำหรับลบข้อมูลลอตโต้ทั้งหมด
  Future<void> _resetLottoData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการล้างข้อมูลลอตโต้"),
        content: const Text(
          "คุณต้องการลบสลาก, รายการซื้อ และรางวัลทั้งหมดใช่หรือไม่? ข้อมูลลูกค้าจะยังคงอยู่",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/reset-lotto"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ล้าง global state ที่เกี่ยวข้อง
        globalPrizeNumbers = [];
        globalAllNumbers = [];
        globalSoldNumbers = [];
        globalCurrentRound = 1;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "ล้างข้อมูลลอตโต้เรียบร้อยแล้ว"),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("การล้างข้อมูลล้มเหลว")));
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
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            color: const Color(0xFF001E46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "Setting",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ชื่อผู้ใช้: ${customer.fullname}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.role == 'admin'
                              ? "ผู้ใช้งานระดับผู้ดูแลระบบ"
                              : "ผู้ใช้งานทั่วไป",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 229, 231, 236),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  if (customer.role == 'admin') ...[
                    // ✅ ปุ่มใหม่สำหรับนำทางไปหน้าดูสลากทั้งหมด
                    _menuItem(context, "ดูสลากทั้งหมด", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShowAllLotto(customer: customer),
                        ),
                      );
                    }),
                    const Divider(height: 1, color: Colors.grey),

                    _menuItem(context, "สุ่มออกรางวัล", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RandomPage(customer: customer),
                        ),
                      );
                    }),
                    const Divider(height: 1, color: Colors.grey),

                    _menuItem(
                      context,
                      "รีเซ็ตระบบ",
                      () => _resetSystem(context),
                    ),
                    const Divider(height: 1, color: Colors.grey),

                    _menuItem(
                      context,
                      "รีเซ็ตลอตโต้",
                      () => _resetLottoData(context),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                  ],

                  const SizedBox(height: 30),

                  // Logout button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 194, 24, 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "ออกจากระบบ",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _footer(context),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFF1F7F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(customer: customer)),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.home, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'Home',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // MyLotto
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MyLottoPage(customer: customer),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.confirmation_number, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'MyLotto',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Setting
          InkWell(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(height: 4),
                Text(
                  'Setting',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
