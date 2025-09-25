import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/global_data.dart';
import 'model/login_model.dart';
import 'home.dart';
import 'config.dart';

class BuyPage extends StatefulWidget {
  final Customer customer;

  const BuyPage({super.key, required this.customer});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  late double walletBalance;
  int currentRound = 0;
  List<Map<String, dynamic>> lottoList = [];
  List<Map<String, dynamic>> filteredLottoList = [];
  bool isLoading = true;
  bool isRoundClosed = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    walletBalance = widget.customer.walletBalance;
    fetchCurrentRoundAndLotto();
  }

  Future<void> fetchCurrentRoundAndLotto() async {
    setState(() {
      isLoading = true;
      lottoList = [];
      filteredLottoList = [];
      currentRound = 0;
      isRoundClosed = false;
    });

    try {
      final roundResponse = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/last-round"),
      );

      if (roundResponse.statusCode != 200) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถดึงงวดล่าสุดได้')),
        );
        return;
      }

      final roundData = json.decode(roundResponse.body);
      int round = roundData['round'] ?? 0;

      if (round == 0) {
        setState(() {
          currentRound = 0;
          lottoList = [];
          filteredLottoList = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ยังไม่มีล็อตเตอรี่ให้ซื้อ — กรุณาให้ผู้ดูแลสร้างงวดก่อน',
            ),
          ),
        );
        return;
      }

      setState(() => currentRound = round);
      final prizeResponse = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/prize/$currentRound"),
      );

      if (prizeResponse.statusCode == 200) {
        final prizeData = json.decode(prizeResponse.body);
        final prizes = prizeData['prizes'] as List? ?? [];
        if (prizes.isNotEmpty) {
          setState(() {
            isRoundClosed = true;
            lottoList = [];
            filteredLottoList = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('งวดนี้ออกผลรางวัลแล้ว กรุณารอสุ่มรางวัลงวดหน้า'),
            ),
          );
          return;
        }
      }

      // ดึงล็อตเตอรี่ที่ยังไม่ขายของงวดนี้
      final lottoResponse = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/lotto/$currentRound"),
      );

      if (lottoResponse.statusCode != 200) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถดึงล็อตเตอรี่ได้')),
        );
        return;
      }

      final lottoData = json.decode(lottoResponse.body);
      final list = List<Map<String, dynamic>>.from(lottoData['lotto'] ?? []);
      setState(() {
        lottoList = list;
        filteredLottoList = List.from(lottoList);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching lotto: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  void searchLotto(String query) {
    final results = lottoList.where((lotto) {
      final number = lotto['number'].toString();
      return number.contains(query);
    }).toList();

    setState(() {
      filteredLottoList = results;
    });
  }

  Future<void> buyLotto(Map<String, dynamic> lotto) async {
    final lottoId = lotto['lotto_id'];
    final price = (lotto['price'] ?? 80).toDouble();

    if (walletBalance < price) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยอดเงินไม่เพียงพอ')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการซื้อ'),
        content: Text(
          'คุณต้องการซื้อสลากหมายเลข ${lotto['number']} ใช่หรือไม่? ราคา ฿${price.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ซื้อ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.apiEndpoint}/buy"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cus_id': widget.customer.cusId,
          'lotto_id': lottoId,
          'round': currentRound,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['wallet_balance'] != null) {
          setState(() {
            walletBalance = (data['wallet_balance'] as num).toDouble();
            widget.customer.walletBalance = walletBalance;
          });
        } else {
          setState(() {
            walletBalance -= price;
            widget.customer.walletBalance = walletBalance;
          });
        }

        setState(() {
          lottoList.removeWhere((l) => l['lotto_id'] == lottoId);
          filteredLottoList.removeWhere((l) => l['lotto_id'] == lottoId);
        });

        setState(() {
          globalSoldNumbers.add(lotto['number']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ซื้อสลาก ${lotto['number']} เรียบร้อย! เงินคงเหลือ: ฿${walletBalance.toStringAsFixed(2)}',
            ),
          ),
        );
      } else {
        final msg = data['message'] ?? 'ซื้อไม่สำเร็จ';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      print("Buy error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดขณะซื้อ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ซื้อสลากกินแบ่ง',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF001E46),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(customer: widget.customer),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!isRoundClosed) ...[
                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'ค้นหาล็อตเตอรี่',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: searchLotto,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => searchLotto(searchController.text),
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

                    // Wallet balance
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ยอดเงินคงเหลือ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '฿${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lotto list
                    Expanded(
                      child: filteredLottoList.isEmpty
                          ? const Center(
                              child: Text('ไม่มีล็อตเตอรี่ที่ว่างให้ซื้อ'),
                            )
                          : ListView.separated(
                              itemCount: filteredLottoList.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final lotto = filteredLottoList[index];
                                final price = (lotto['price'] ?? 80).toDouble();
                                return ListTile(
                                  title: Text(
                                    lotto['number'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ราคา: ฿${price.toStringAsFixed(2)}',
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => buyLotto(lotto),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text(
                                      'ซื้อ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ] else ...[
                    // ถ้างวดนี้ออกผลแล้ว
                    Expanded(
                      child: Center(
                        child: Text(
                          'งวดนี้ออกผลรางวัลแล้ว กรุณารอสุ่มรางวัลงวดหน้า',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
