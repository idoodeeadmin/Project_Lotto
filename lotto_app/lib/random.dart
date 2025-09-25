import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'mylotto.dart';
import 'config.dart';
import 'model/global_data.dart';
import 'model/random_model.dart';
import 'model/login_model.dart';
import 'setting.dart';

class RandomPage extends StatefulWidget {
  final Customer customer;

  const RandomPage({super.key, required this.customer});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  bool isLoading = false; // Controls the "Create Lotto" button state
  bool isDrawing = false; // Controls the state for all drawing actions

  int get currentRound => globalCurrentRound;
  set currentRound(int value) => globalCurrentRound = value;

  List<String> get soldNumbers => globalSoldNumbers;
  List<Prize> get prizeNumbers => globalPrizeNumbers;

  @override
  void initState() {
    super.initState();
    if (globalCurrentRound == 0) {
      fetchCurrentRound();
    } else {
      fetchPrizes();
    }
  }

  Future<void> fetchCurrentRound() async {
    // No need for global loading state here, as it only runs on init
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/current-round"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roundRes = ResRound.fromJson(data);
        // ใช้ if (mounted) เพื่อป้องกัน setState หลังจาก Widget ถูก dispose
        if (mounted) setState(() => currentRound = roundRes.round);
        fetchPrizes();
      }
    } catch (_) {
      showMessage("Error fetching current round");
    }
  }

  Future<void> fetchAllNumbers() async {
    if (mounted)
      setState(() => isLoading = true); // Set loading for "Create Lotto"
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/generate"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lottoNumbers'] != null) {
          if (mounted) {
            setState(() {
              globalAllNumbers = List<String>.from(data['lottoNumbers']);
              globalSoldNumbers = [];
              currentRound = data['round'] ?? currentRound;
            });
          }
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
      if (mounted) setState(() => isLoading = false); // Clear loading
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
        if (mounted) setState(() => globalSoldNumbers = soldRes.soldNumbers);
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
        if (mounted) setState(() => globalPrizeNumbers = prizeRes.prizes);
      } else {
        showMessage("ไม่สามารถดึงรางวัลได้");
      }
    } catch (_) {
      showMessage("Error fetching prizes");
    }
  }

  // ✅ FIX: ปรับปรุง Common function ให้ป้องกัน Race Condition ที่ต้นทาง
  Future<void> _safeDrawAction(Future<void> Function() action) async {
    // 1. ตรวจสอบสถานะก่อนเริ่ม
    if (isLoading) {
      showMessage("โปรดรอให้การสร้าง Lotto เสร็จสิ้นก่อน");
      return;
    }
    // **✅ การตรวจสอบซ้ำก่อนเรียก setState คือหัวใจของการแก้ Race Condition**
    if (isDrawing) return;

    // 2. ตั้งค่าสถานะและเริ่มดำเนินการ
    if (mounted) setState(() => isDrawing = true);
    try {
      await action();
    } finally {
      // 3. เคลียร์สถานะ
      if (mounted) setState(() => isDrawing = false);
    }
  }

  Future<void> drawPrizes() async {
    await _safeDrawAction(() async {
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
    });
  }

  Future<void> drawFromSoldNumbers() async {
    await _safeDrawAction(() async {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/draw-from-sold/$currentRound"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showMessage(data['message']);
        await fetchPrizes();
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['message'] ?? "ไม่สามารถสุ่มรางวัลได้");
      }
    });
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String displayNumber(String prizeType, String number) {
    // This logic seems redundant, but kept as in original code
    if (prizeType.contains("เลขท้าย")) {
      return number;
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    // Disable all actions if either lotto generation or a draw is in progress
    final bool isActionDisabled =
        isLoading || isDrawing; // ✅ isDrawing ถูกใช้แล้ว

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
                    onPressed: isActionDisabled
                        ? null
                        : () => Navigator.pop(
                            context,
                          ), // Disable back button while loading
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
                // ✅ ใช้ isLoading ตรงนี้
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
              // ส่ง isActionDisabled เข้าไป
              _buildActionButtons(isActionDisabled),
              const SizedBox(height: 20),
              if (soldNumbers.isNotEmpty) _buildSoldNumbersContainer(),
              const SizedBox(height: 20),
              if (prizeNumbers.isNotEmpty) _buildPrizeContainer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _footer(context, isActionDisabled),
    );
  }

  // Modified to accept a disabled flag
  Widget _buildActionButtons(bool isDisabled) {
    final Color disabledColor = Colors.grey.withOpacity(0.5);

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
            // ✅ ใช้ isDisabled ตรงนี้
            onTap: isDisabled ? null : drawPrizes,
            child: Column(
              children: [
                _circleButton(
                  Icons.casino,
                  isDisabled
                      ? disabledColor
                      : const Color.fromARGB(255, 26, 121, 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'สุ่มรางวัล',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // ปุ่มสีแดง: สุ่มรางวัลจากเลขที่ขายแล้ว
          GestureDetector(
            // ✅ ใช้ isDisabled ตรงนี้
            onTap: isDisabled ? null : drawFromSoldNumbers,
            child: Column(
              children: [
                _circleButton(
                  Icons.confirmation_number,
                  isDisabled
                      ? disabledColor
                      : const Color.fromARGB(255, 172, 43, 43),
                ),
                const SizedBox(height: 8),
                Text(
                  'สุ่มจากเลขขายแล้ว',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDisabled ? Colors.grey : Colors.black,
                  ),
                ),
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

  // Modified to accept a disabled flag and conditionally disable footers
  Widget _footer(BuildContext context, bool isDisabled) {
    return Container(
      height: 70,
      color: const Color(0xFFF1F7F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _footerItem(
            Icons.home,
            "Home",
            isDisabled
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(customer: widget.customer),
                      ),
                    );
                  },
            false,
          ),
          // MyLotto
          _footerItem(
            Icons.confirmation_number,
            "MyLotto",
            isDisabled
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyLottoPage(customer: widget.customer),
                      ),
                    );
                  },
            false,
          ),
          // Setting (active)
          _footerItem(
            Icons.settings,
            "Setting",
            isDisabled
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingPage(customer: widget.customer),
                      ),
                    );
                  },
            true, // Active highlight
          ),
        ],
      ),
    );
  }

  Widget _footerItem(
    IconData icon,
    String label,
    VoidCallback? onTap,
    bool isActive,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
