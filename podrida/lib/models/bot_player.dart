import 'dart:math';
import 'card.dart';
import 'player.dart';
import 'rules.dart';

class BotPlayer {
  static final Random _random = Random();

  /// Plays a random valid card from the bot's hand following the game rules
  static PlayingCard playCard(Player botPlayer, PlayingCard? leadCard) {
    // Get list of legal plays based on game rules
    List<PlayingCard> playableCards =
        GameRules.getPlayableCards(botPlayer.hand, leadCard);

    if (playableCards.isEmpty) {
      throw StateError('No playable cards available for bot ${botPlayer.name}');
    }

    // Select random card from legal plays
    int randomIndex = _random.nextInt(playableCards.length);
    return playableCards[randomIndex];
  }

  /// Test function to verify bot follows suit rule
  static bool verifyBotFollowsSuit(Player botPlayer, PlayingCard leadCard) {
    PlayingCard playedCard = playCard(botPlayer, leadCard);

    // If bot has cards of lead suit, verify played card matches suit
    bool hasSuit = botPlayer.hand.any((card) => card.suit == leadCard.suit);
    if (hasSuit) {
      return playedCard.suit == leadCard.suit;
    }

    return true; // Bot can play any suit if they don't have lead suit
  }

  /// Debug function to print bot's decision making
  static void debugBotPlay(Player botPlayer, PlayingCard? leadCard) {
    print('\nBot ${botPlayer.name} turn:');
    print('Lead card: ${leadCard?.suit.toString().split('.').last ?? 'None'}');
    print(
        'Bot hand: ${botPlayer.hand.map((c) => '${c.rank.toString().split('.').last} of ${c.suit.toString().split('.').last}').join(', ')}');

    PlayingCard played = playCard(botPlayer, leadCard);
    print(
        'Bot played: ${played.rank.toString().split('.').last} of ${played.suit.toString().split('.').last}');
  }
}
