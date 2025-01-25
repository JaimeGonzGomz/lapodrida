import 'card.dart';

class Player {
  final String id;
  final String name;
  List<PlayingCard> hand;
  int score;
  int currentBet = 0;
  int tricksWon = 0;
  String? email; // Added for Supabase user info

  Player({
    required this.id,
    required this.name,
    this.email,
    List<PlayingCard>? hand,
    this.score = 0,
  }) : hand = hand ?? [];

  void resetRoundStats() {
    currentBet = 0;
    tricksWon = 0;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'score': score,
    };
  }
}
