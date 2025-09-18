// model/random_model.dart

class ResRound {
  final int round;

  ResRound({required this.round});

  factory ResRound.fromJson(Map<String, dynamic> json) {
    return ResRound(round: json['round']);
  }
}

class ResGenerate {
  final int round;
  final List<String> lottoNumbers;
  final String message;

  ResGenerate({
    required this.round,
    required this.lottoNumbers,
    required this.message,
  });

  factory ResGenerate.fromJson(Map<String, dynamic> json) {
    return ResGenerate(
      round: json['round'],
      lottoNumbers: List<String>.from(json['lottoNumbers']),
      message: json['message'] ?? '',
    );
  }
}

class ResSold {
  final List<String> soldNumbers;

  ResSold({required this.soldNumbers});

  factory ResSold.fromJson(Map<String, dynamic> json) {
    return ResSold(soldNumbers: List<String>.from(json['soldNumbers']));
  }
}

class Prize {
  final String prizeType;
  final String number;
  final int rewardAmount;

  Prize({
    required this.prizeType,
    required this.number,
    required this.rewardAmount,
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      prizeType: json['prize_type'], // แก้ตรงนี้
      number: json['number'],
      rewardAmount: (json['reward_amount'] as num).toInt(), // แก้ตรงนี้
    );
  }
}

class ResPrize {
  final List<Prize> prizes;

  ResPrize({required this.prizes});

  factory ResPrize.fromJson(Map<String, dynamic> json) {
    return ResPrize(
      prizes: (json['prizes'] as List).map((e) => Prize.fromJson(e)).toList(),
    );
  }
}
