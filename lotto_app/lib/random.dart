import 'package:flutter/material.dart';
import 'mylotto.dart';
import 'home.dart';

class RandomPage extends StatelessWidget {
  final String role;
  final String fullname;

  const RandomPage({super.key, required this.role, required this.fullname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001E46),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              const Text(
                'หวยงวด 1 ส.ค. 2568',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  print("สร้าง Lotto");
                },
                icon: const Icon(Icons.add),
                label: const Text('สร้าง Lotto'),
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
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("สุ่มเลขที่ขายเเล้ว");
                      },
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
                            'สุ่มเลขที่ขายเเล้ว',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("สุ่มเลขทั้งหมด");
                      },
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
                            'สุ่มเลขทั้งหมด',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('รางวัลที่ 1'),
                            SizedBox(height: 4),
                            Text(
                              '123 446',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text('รางวัลที่ 2'),
                            SizedBox(height: 4),
                            Text(
                              '654 321',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text('รางวัลที่ 3'),
                            SizedBox(height: 4),
                            Text(
                              '789 012',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text('เลขท้าย 3 ตัว'),
                            SizedBox(height: 4),
                            Text(
                              '446',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('เลขท้าย 2 ตัว'),
                            SizedBox(height: 4),
                            Text(
                              '44',
                              style: TextStyle(
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
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(role: role, fullname: fullname),
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
                  builder: (_) => MyLottoPage(role: role, fullname: fullname),
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
