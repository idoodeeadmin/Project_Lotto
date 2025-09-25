import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Buy.dart';
import 'mylotto.dart';
import 'setting.dart';
import 'config.dart';
import 'model/random_model.dart';
import 'model/login_model.dart'; // Customer model

class HomePage extends StatefulWidget {
  final Customer customer; // รับ Customer object

  const HomePage({super.key, required this.customer});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Prize> prizeNumbers = []; // รางวัลงวดปัจจุบัน
  List<Prize> lastRoundPrizes = []; // รางวัลงวดก่อนหน้า
  bool isLoading = true;
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
        await fetchPrizes(currentRound);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPrizes(int round) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/prize/$round"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prizeRes = ResPrize.fromJson(data);
        setState(() {
          prizeNumbers = prizeRes.prizes;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // -----------------------------
    // ใช้ตัวแปร String + int แทน _getPrize()
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

    return Scaffold(
      backgroundColor: const Color(0xFF001E46),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'lib/assets/logo.webp',
                  width: 120,
                  height: 100,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'ล็อตเตอรี่เลขเด็ด',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'ผลรางวัลหวยงวดล่าสุด',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              // รางวัลที่ 1 ทีละหลัก
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        firstPrize.length == 6 ? firstPrize[index] : "-",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Wallet + Buy Lotto
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Wallet',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '฿ ${widget.customer.walletBalance.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyPage(customer: widget.customer),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.confirmation_number,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ซื้อลอตเตอรี่',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Prize section
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ชื่อรางวัล
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('รางวัลที่ 1'),
                                  const SizedBox(height: 4),
                                  Text(
                                    firstPrize,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('รางวัลที่ 2'),
                                  const SizedBox(height: 4),
                                  Text(
                                    secondPrize,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('รางวัลที่ 3'),
                                  const SizedBox(height: 4),
                                  Text(
                                    thirdPrize,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('เลขท้าย 3 ตัว'),
                                  const SizedBox(height: 4),
                                  Text(
                                    last3,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('เลขท้าย 2 ตัว'),
                                  const SizedBox(height: 4),
                                  Text(
                                    last2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              // เงินรางวัล
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('เงินรางวัล'),
                                  const SizedBox(height: 4),
                                  Text(
                                    firstPrizeAmount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    secondPrizeAmount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    thirdPrizeAmount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    last3Amount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    last2Amount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
          _footerItem(Icons.home, "Home", true, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(customer: widget.customer),
              ),
            );
          }),
          _footerItem(Icons.confirmation_number, "MyLotto", false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyLottoPage(customer: widget.customer),
              ),
            );
          }),
          _footerItem(Icons.person, "Setting", false, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SettingPage(customer: widget.customer),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _footerItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
