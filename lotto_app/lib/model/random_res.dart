// lib/model/random_res.dart

class ResRound {
  final int round;

  ResRound({required this.round});

  factory ResRound.fromJson(Map<String, dynamic> json) {
    return ResRound(round: json['round'] ?? 0);
  }
}

class ResGenerate {
  final List<String> lottoNumbers;
  final int round;
  final String message;

  ResGenerate({
    required this.lottoNumbers,
    required this.round,
    required this.message,
  });

  factory ResGenerate.fromJson(Map<String, dynamic> json) {
    return ResGenerate(
      lottoNumbers: List<String>.from(json['lotto_numbers'] ?? []),
      round: json['round'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class ResSold {
  final List<String> soldNumbers;

  ResSold({required this.soldNumbers});

  factory ResSold.fromJson(Map<String, dynamic> json) {
    return ResSold(soldNumbers: List<String>.from(json['sold_numbers'] ?? []));
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
      prizeType: json['prize_type'] ?? '',
      number: json['number'] ?? '',
      rewardAmount: (json['reward_amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ResPrize {
  final List<Prize> prizes;

  ResPrize({required this.prizes});

  factory ResPrize.fromJson(Map<String, dynamic> json) {
    return ResPrize(
      prizes: (json['prizes'] as List<dynamic>? ?? [])
          .map((e) => Prize.fromJson(e))
          .toList(),
    );
  }
}
