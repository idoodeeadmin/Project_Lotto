import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'mylotto.dart';
import 'config.dart';
import 'model/global_data.dart';
import 'model/random_model.dart';
import 'model/login_model.dart';

class RandomPage extends StatefulWidget {
  final Customer customer;

  const RandomPage({super.key, required this.customer});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  bool isLoading = false;
  int get currentRound => globalCurrentRound;
  set currentRound(int value) => globalCurrentRound = value;

  List<String> get soldNumbers => globalSoldNumbers;
  List<Prize> get prizeNumbers => globalPrizeNumbers;

  @override
  void initState() {
    super.initState();
    if (globalPrizeNumbers.isEmpty) {
      fetchCurrentRound();
    }
  }

  Future<void> fetchCurrentRound() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/current-round"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roundRes = ResRound.fromJson(data);
        setState(() => currentRound = roundRes.round);
        fetchPrizes();
      }
    } catch (_) {
      showMessage("Error fetching current round");
    }
  }

  Future<void> fetchAllNumbers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/generate"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lottoNumbers'] != null) {
          setState(() {
            globalAllNumbers = List<String>.from(data['lottoNumbers']);
            globalSoldNumbers = [];
            currentRound = data['round'] ?? currentRound;
          });
          showMessage("สร้าง Lotto เสร็จแล้ว 🎉");
        } else {
          showMessage("Response ไม่ถูกต้องจาก server");
        }
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['message'] ?? "ไม่สามารถสร้าง Lotto ได้");
      }
    } catch (e) {
      showMessage("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSoldNumbers() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/sold-lotto/$currentRound"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final soldRes = ResSold.fromJson(data);
        setState(() => globalSoldNumbers = soldRes.soldNumbers);
        if (soldRes.soldNumbers.isEmpty) {
          showMessage('ยังไม่มีเลขขายเลย');
        }
      }
    } catch (_) {
      showMessage("Error fetching sold numbers");
    }
  }

  Future<void> fetchPrizes() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/prize/$currentRound"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prizeRes = ResPrize.fromJson(data);
        setState(() => globalPrizeNumbers = prizeRes.prizes);
      } else {
        showMessage("ไม่สามารถดึงรางวัลได้");
      }
    } catch (_) {
      showMessage("Error fetching prizes");
    }
  }

  Future<void> drawPrizes() async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/draw-prizes/$currentRound"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showMessage(data['message']);
        await fetchPrizes();
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['message'] ?? "ไม่สามารถสุ่มรางวัลได้");
      }
    } catch (_) {
      showMessage("Error drawing prizes");
    }
  }

  Future<void> drawFromSoldNumbers() async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/draw-from-sold/$currentRound"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showMessage(data['message']);
        // ดึงรางวัลล่าสุดจาก server
        await fetchPrizes();
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['message'] ?? "ไม่สามารถสุ่มรางวัลได้");
      }
    } catch (_) {
      showMessage("Error drawing prizes from sold numbers");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String displayNumber(String prizeType, String number) {
    if (prizeType.contains("เลขท้าย")) {
      return number; // โชว์เฉพาะเลขท้าย
    }
    return number; // รางวัลใหญ่ โชว์เลขเต็ม
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E46),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('lib/assets/logo.webp', width: 120, height: 100),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'สุ่มเลขรางวัลล็อตเตอรี่',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'หวยงวด $currentRound',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : fetchAllNumbers,
                icon: const Icon(Icons.add),
                label: Text(isLoading ? "กำลังสร้าง..." : 'สร้าง Lotto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 212, 209),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              if (soldNumbers.isNotEmpty) _buildSoldNumbersContainer(),
              const SizedBox(height: 20),
              if (prizeNumbers.isNotEmpty) _buildPrizeContainer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _footer(context),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ปุ่มสีเขียว: สุ่มรางวัลจาก server (เหมือนเดิม)
          GestureDetector(
            onTap: drawPrizes,
            child: Column(
              children: [
                _circleButton(
                  Icons.casino,
                  const Color.fromARGB(255, 26, 121, 14),
                ),
                const SizedBox(height: 8),
                const Text('สุ่มรางวัล', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          // ปุ่มสีแดง: สุ่มรางวัลจากเลขที่ขายแล้ว
          GestureDetector(
            onTap: drawFromSoldNumbers,
            child: Column(
              children: [
                _circleButton(
                  Icons.confirmation_number,
                  const Color.fromARGB(255, 172, 43, 43),
                ),
                const SizedBox(height: 8),
                const Text('สุ่มจากเลขขายแล้ว', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, size: 40, color: Colors.white),
    );
  }

  Widget _buildSoldNumbersContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'เลขล็อตเตอรี่ที่ขายแล้ว',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: soldNumbers
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeContainer() {
    if (prizeNumbers.isEmpty) return const SizedBox.shrink();

    Map<String, Prize> prizeMap = {for (var p in prizeNumbers) p.prizeType: p};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ผลสลากกินแบ่งรัฐบาล',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPrizeRow("รางวัลที่ 1", prizeMap["รางวัลที่ 1"]),
          _buildPrizeRow("รางวัลที่ 2", prizeMap["รางวัลที่ 2"]),
          _buildPrizeRow("รางวัลที่ 3", prizeMap["รางวัลที่ 3"]),
          _buildPrizeRow("เลขท้าย 3 ตัว", prizeMap["เลขท้าย 3 ตัว"]),
          _buildPrizeRow("เลขท้าย 2 ตัว", prizeMap["เลขท้าย 2 ตัว"]),
        ],
      ),
    );
  }

  Widget _buildPrizeRow(String title, Prize? prize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 4),
              Text(
                prize != null ? displayNumber(title, prize.number) : "-",
                style: _numberStyle,
              ),
            ],
          ),
          Text(
            prize != null ? prize.rewardAmount.toString() : "-",
            style: _numberStyle,
          ),
        ],
      ),
    );
  }

  static const TextStyle _numberStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  Widget _footer(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFF1F7F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.home, "Home", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(customer: widget.customer),
              ),
            );
          }),
          _footerItem(Icons.confirmation_number, "MyLotto", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyLottoPage(customer: widget.customer),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
