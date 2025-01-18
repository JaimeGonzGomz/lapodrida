import 'card.dart';

class Player {
  final String id;
  final String name;
  List<PlayingCard> hand;
  int score;
  int currentBet = 0; // How many tricks they bet to win
  int tricksWon = 0; // How many tricks they've won this round

  Player({
    required this.id,
    required this.name,
    List<PlayingCard>? hand,
    this.score = 0,
  }) : hand = hand ?? [];

  void resetRoundStats() {
    currentBet = 0;
    tricksWon = 0;
  }
}
