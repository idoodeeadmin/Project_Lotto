import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'model/Showall_res.dart';
import 'home.dart';
import 'mylotto.dart';
import 'setting.dart'; // สำหรับกลับไป Setting
import 'model/login_model.dart';

class ShowAllLotto extends StatefulWidget {
  final Customer customer;

  const ShowAllLotto({Key? key, required this.customer}) : super(key: key);

  @override
  _ShowAllLottoState createState() => _ShowAllLottoState();
}

class _ShowAllLottoState extends State<ShowAllLotto> {
  List<Lotto> lottoList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLotto();
  }

  Future<void> fetchLotto() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiEndpoint}/show-all-lotto"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lottoList = (data['lotto'] as List)
              .map((json) => Lotto.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load lotto");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สลากทั้งหมด")),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : lottoList.isEmpty
                ? const Center(child: Text("ไม่มีข้อมูลสลาก"))
                : ListView.builder(
                    itemCount: lottoList.length,
                    itemBuilder: (context, index) {
                      final lotto = lottoList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: ListTile(
                          leading: Text("ID: ${lotto.lottoId}"),
                          title: Text("เลข: ${lotto.number}"),
                          subtitle: Text(
                            "งวด: ${lotto.round} | ราคา: ${lotto.price} บาท",
                          ),
                          trailing: Text(
                            lotto.status == "available" ? "ว่าง" : "ขายแล้ว",
                            style: TextStyle(
                              color: lotto.status == "available"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _tabToolbar(context),
        ],
      ),
    );
  }

  Widget _tabToolbar(BuildContext context) {
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
                MaterialPageRoute(
                  builder: (_) => HomePage(customer: widget.customer),
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
          // MyLotto
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MyLottoPage(customer: widget.customer),
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
          // Setting (active)
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingPage(customer: widget.customer),
                ),
              );
            },
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
