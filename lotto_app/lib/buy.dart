import 'package:flutter/material.dart';

class BuyPage extends StatelessWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> lottoList = [
      {"number": "123 456", "price": "80"},
      {"number": "654 321", "price": "80"},
      {"number": "112 233", "price": "80"},
      {"number": "445 566", "price": "80"},
      {"number": "778 999", "price": "80"},
      {"number": "123 056", "price": "80"},
      {"number": "654 121", "price": "80"},
      {"number": "112 223", "price": "80"},
      {"number": "445 466", "price": "80"},
      {"number": "778 899", "price": "80"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ซื้อสลากกินแบ่ง',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF001E46),
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้า Home
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 221, 227, 233),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row: ช่องค้นหา + ปุ่มค้นหา
            Row(
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
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      print("ค้นหาเลขล็อตเตอรี่");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001E46),
                      minimumSize: const Size(double.infinity, 58),
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
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: lottoList.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white, thickness: 1),
                itemBuilder: (context, index) {
                  final lotto = lottoList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // เลขล็อตเตอรี่ + ราคา
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ฉลากกินเเบ่ง',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),

                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${lotto["number"]}',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ราคา: ฿${lotto["price"]}',
                              style: const TextStyle(
                                color: Color.fromARGB(179, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // ปุ่มซื้อ
                        ElevatedButton(
                          onPressed: () {
                            print("ซื้อเลข ${lotto["number"]}");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              39,
                              226,
                              55,
                            ),
                          ),
                          child: const Text(
                            'ซื้อ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
