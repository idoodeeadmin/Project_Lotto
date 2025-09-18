import 'package:flutter/material.dart';
import 'home.dart';
import 'setting.dart';
import 'model/login_model.dart';

class MyLottoPage extends StatelessWidget {
  final Customer customer;

  const MyLottoPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    // จำลองผลรางวัลที่ออกแล้ว
    final String latestResultDate = "1 ส.ค. 2568"; // งวดนี้ประกาศผลแล้ว
    final List<String> winningNumbers = [
      "999 999", // ไม่มีใครถูกรางวัล
    ];

    // จำลองข้อมูลล็อตเตอรี่
    final Map<String, List<Map<String, String>>> lottoByDate = {
      "1 ส.ค. 2568": [
        {"number": "123 456", "price": "80"},
        {"number": "654 321", "price": "80"},
      ],
      "16 ส.ค. 2568": [
        {"number": "112 233", "price": "80"},
      ],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Lotto - ${customer.fullname}'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF001E46),
      ),
      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ค้นหาล็อตเตอรี่',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      print("ค้นหาเลขล็อตเตอรี่");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001E46),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'ค้นหา',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ล็อตเตอรี่
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: lottoByDate.entries.map((entry) {
                final date = entry.key;
                final lottos = entry.value;
                final isResultAnnounced = date == latestResultDate;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'งวดวันที่ $date',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...lottos.map((lotto) {
                      final number = lotto["number"]!;
                      final isWinner = winningNumbers.contains(number);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ฉลากกินเเบ่ง',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  isResultAnnounced
                                      ? (isWinner
                                            ? 'ถูกรางวัล!'
                                            : 'ไม่ถูกรางวัล')
                                      : 'รอผล',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isResultAnnounced
                                        ? (isWinner ? Colors.green : Colors.red)
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ราคา: ฿${lotto["price"]}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),

          // Footer
          _footer(context),
        ],
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
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.confirmation_number, color: Colors.blue),
                SizedBox(height: 4),
                Text(
                  'MyLotto',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ],
            ),
          ),
          // Setting
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingPage(customer: customer),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'Setting',
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
