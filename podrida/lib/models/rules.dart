import 'card.dart';

class GameRules {
  static bool canPlayCard(
      PlayingCard card, PlayingCard? leadCard, List<PlayingCard> playerHand) {
    if (leadCard == null) {
      return true;
    }
    bool hasSameSuit = playerHand.any((c) => c.suit == leadCard.suit);
    if (hasSameSuit) {
      return card.suit == leadCard.suit;
    }
    return true;
  }

  static List<PlayingCard> getPlayableCards(
      List<PlayingCard> hand, PlayingCard? leadCard) {
    if (leadCard == null) {
      return hand;
    }
    bool hasSameSuit = hand.any((card) => card.suit == leadCard.suit);
    if (hasSameSuit) {
      return hand.where((card) => card.suit == leadCard.suit).toList();
    }
    return hand;
  }
}
