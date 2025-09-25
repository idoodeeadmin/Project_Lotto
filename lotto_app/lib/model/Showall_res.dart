class Lotto {
  final int lottoId;
  final String number;
  final int round;
  final double price;
  final String status;

  Lotto({
    required this.lottoId,
    required this.number,
    required this.round,
    required this.price,
    required this.status,
  });

  factory Lotto.fromJson(Map<String, dynamic> json) {
    return Lotto(
      lottoId: json['lotto_id'],
      number: json['number'],
      round: json['round'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lotto_id': lottoId,
      'number': number,
      'round': round,
      'price': price,
      'status': status,
    };
  }
}
