import 'card.dart';

class GameRules {
  /// Returns the index of the winning card based on trick rules
  static int determineWinningCardIndex(
      List<PlayingCard> cards, PlayingCard? trumpCard, PlayingCard leadCard) {
    if (cards.isEmpty) return -1;

    // First, check if any trump cards were played
    List<PlayingCard> trumpCards = cards
        .where((card) => trumpCard != null && card.suit == trumpCard.suit)
        .toList();

    // If trump cards were played, highest trump wins
    if (trumpCards.isNotEmpty) {
      return cards.indexOf(trumpCards.reduce((highest, card) =>
          _compareCardRanks(highest, card) > 0 ? highest : card));
    }

    // If no trumps, highest card of lead suit wins
    List<PlayingCard> leadSuitCards =
        cards.where((card) => card.suit == leadCard.suit).toList();

    return cards.indexOf(leadSuitCards.reduce((highest, card) =>
        _compareCardRanks(highest, card) > 0 ? highest : card));
  }

  /// Compare card ranks, Ace high (returns positive if card1 higher, negative if card2 higher)
  static int _compareCardRanks(PlayingCard card1, PlayingCard card2) {
    // Convert rank to numeric value (Ace high)
    int getValue(Rank rank) {
      switch (rank) {
        case Rank.ace:
          return 14;
        case Rank.king:
          return 13;
        case Rank.queen:
          return 12;
        case Rank.jack:
          return 11;
        default:
          return rank.index + 2; // 2-10 are index + 2
      }
    }

    return getValue(card1.rank) - getValue(card2.rank);
  }

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
