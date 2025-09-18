// global_data.dart

import 'random_model.dart';

// ------------------------
// Global Prize Numbers
// ------------------------
List<Prize> globalPrizeNumbers = [];

// ------------------------
// Global Customer Data (ถ้าต้องการเก็บ)
// ------------------------
/*
class GlobalCustomer {
  static Customer? currentCustomer;
}
*/

// ------------------------
// Global Lotto Numbers
// ------------------------
List<String> globalAllNumbers = [];
List<String> globalSoldNumbers = [];
int globalCurrentRound = 1; // เพิ่มตัวนี้

// ------------------------
// ฟังก์ชันช่วยเหลือ (Optional)
// ------------------------

// เพิ่มรางวัลใหม่เข้า global
void addPrizeToGlobal(Prize prize) {
  globalPrizeNumbers.add(prize);
}

// เคลียร์รางวัลทั้งหมด
void clearGlobalPrizes() {
  globalPrizeNumbers.clear();
}

// เพิ่มเลขล็อตเตอรี่
void addLottoNumber(String number) {
  globalAllNumbers.add(number);
}

// เคลียร์เลขล็อตเตอรี่
void clearLottoNumbers() {
  globalAllNumbers.clear();
}
