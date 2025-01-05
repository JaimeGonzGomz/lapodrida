import 'card.dart';
import 'player.dart';

class TrickPlay {
  final Player player;
  final PlayingCard card;

  TrickPlay(this.player, this.card);
}

class CompletedTrick {
  final List<TrickPlay> plays;
  final Player winner;
  final PlayingCard? trumpCard;
  final PlayingCard leadCard;

  CompletedTrick(this.plays, this.winner, this.trumpCard)
      : leadCard = plays.first.card;
}

class TrickHistory {
  final List<CompletedTrick> completedTricks = [];

  void addCompletedTrick(
      List<TrickPlay> plays, Player winner, PlayingCard? trumpCard) {
    completedTricks.add(CompletedTrick(plays, winner, trumpCard));
  }

  void clearHistory() {
    completedTricks.clear();
  }
}
