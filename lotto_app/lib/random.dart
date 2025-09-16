import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'mylotto.dart';
import 'config.dart';

// ✅ import models
import 'model/random_res.dart';

class RandomPage extends StatefulWidget {
  final String role;
  final String fullname;

  const RandomPage({super.key, required this.role, required this.fullname});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  List<String> allNumbers = [];
  List<String> soldNumbers = [];
  List<Prize> prizeNumbers = []; // ✅ ใช้ Model แทน Map
  bool isLoading = false;
  int currentRound = 1;

  @override
  void initState() {
    super.initState();
    fetchCurrentRound();
  }

  Future<void> fetchCurrentRound() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/current-round"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roundRes = ResRound.fromJson(data);
        setState(() {
          currentRound = roundRes.round;
        });
        fetchPrizes();
      }
    } catch (e) {
      showMessage("Error fetching round");
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
        final genRes = ResGenerate.fromJson(data);
        setState(() {
          allNumbers = genRes.lottoNumbers;
          soldNumbers = [];
          currentRound = genRes.round;
        });
        showMessage(genRes.message);
      } else {
        final data = jsonDecode(response.body);
        showMessage(
          data['message'] ?? data['error'] ?? "ไม่สามารถสร้าง Lotto ได้",
        );
      }
    } catch (e) {
      showMessage("Error generating Lotto");
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
        if (soldRes.soldNumbers.isEmpty) {
          showMessage('ยังไม่มีเลขขายเลย');
          return;
        }
        setState(() => soldNumbers = soldRes.soldNumbers);
        fetchPrizes();
      }
    } catch (e) {
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
        setState(() {
          prizeNumbers = prizeRes.prizes; // ✅ ใช้ Model ตรงๆ
        });
      }
    } catch (e) {
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
        fetchPrizes();
      } else {
        final data = jsonDecode(response.body);
        showMessage(data['message'] ?? "ไม่สามารถสุ่มรางวัลได้");
      }
    } catch (e) {
      showMessage("Error drawing prizes");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPrizeContainer() {
    if (prizeNumbers.isEmpty) return const SizedBox.shrink();

    String firstPrize = '';
    String secondPrize = '';
    String thirdPrize = '';
    String last3 = '';
    String last2 = '';
    int firstPrizeAmount = 0;
    int secondPrizeAmount = 0;
    int thirdPrizeAmount = 0;
    int last3Amount = 0;
    int last2Amount = 0;

    for (var p in prizeNumbers) {
      switch (p.prizeType) {
        case 'รางวัลที่ 1':
          firstPrize = p.number;
          firstPrizeAmount = p.rewardAmount;
          break;
        case 'รางวัลที่ 2':
          secondPrize = p.number;
          secondPrizeAmount = p.rewardAmount;
          break;
        case 'รางวัลที่ 3':
          thirdPrize = p.number;
          thirdPrizeAmount = p.rewardAmount;
          break;
        case 'เลขท้าย 3 ตัว':
          last3 = p.number;
          last3Amount = p.rewardAmount;
          break;
        case 'เลขท้าย 2 ตัว':
          last2 = p.number;
          last2Amount = p.rewardAmount;
          break;
      }
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ฝั่งซ้าย (เลขรางวัล)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('รางวัลที่ 1'),
                  const SizedBox(height: 4),
                  Text(firstPrize, style: _numberStyle),
                  const SizedBox(height: 12),
                  const Text('รางวัลที่ 2'),
                  const SizedBox(height: 4),
                  Text(secondPrize, style: _numberStyle),
                  const SizedBox(height: 12),
                  const Text('รางวัลที่ 3'),
                  const SizedBox(height: 4),
                  Text(thirdPrize, style: _numberStyle),
                  const SizedBox(height: 12),
                  const Text('เลขท้าย 3 ตัว'),
                  const SizedBox(height: 4),
                  Text(last3, style: _numberStyle),
                  const SizedBox(height: 12),
                  const Text('เลขท้าย 2 ตัว'),
                  const SizedBox(height: 4),
                  Text(last2, style: _numberStyle),
                ],
              ),
              // ฝั่งขวา (เงินรางวัล)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('เงินรางวัล'),
                  const SizedBox(height: 4),
                  Text(firstPrizeAmount.toString(), style: _numberStyle),
                  const SizedBox(height: 40),
                  Text(secondPrizeAmount.toString(), style: _numberStyle),
                  const SizedBox(height: 40),
                  Text(thirdPrizeAmount.toString(), style: _numberStyle),
                  const SizedBox(height: 30),
                  Text(last3Amount.toString(), style: _numberStyle),
                  const SizedBox(height: 30),
                  Text(last2Amount.toString(), style: _numberStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _numberStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: drawPrizes,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 26, 121, 14),
                            ),
                            child: const Icon(
                              Icons.casino,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'สุ่มรางวัล',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: fetchSoldNumbers,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 172, 43, 43),
                            ),
                            child: const Icon(
                              Icons.confirmation_number,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'เลขที่ขายแล้ว',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (soldNumbers.isNotEmpty)
                Container(
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
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

  Widget _footer(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFFF1F7F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HomePage(role: widget.role, fullname: widget.fullname),
                ),
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
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MyLottoPage(role: widget.role, fullname: widget.fullname),
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
        ],
      ),
    );
  }
}
