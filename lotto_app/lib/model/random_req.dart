// lib/model/random_req.dart

class RandomGenerateRequest {
  final int round;

  RandomGenerateRequest({required this.round});

  Map<String, dynamic> toJson() => {"round": round};
}
