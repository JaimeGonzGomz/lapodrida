import 'card.dart';

class Player {
  final String id;
  final String name;
  List<PlayingCard> hand;
  int score; // Add this field

  Player({
    required this.id,
    required this.name,
    List<PlayingCard>? hand,
    this.score = 0, // Initialize score to 0
  }) : hand = hand ?? [];
}
