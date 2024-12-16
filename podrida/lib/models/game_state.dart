import 'dart:math';
import 'card.dart';
import 'player.dart';

class GameState {
  List<Player> players = [];
  PlayingCard? trumpCard;
  List<PlayingCard> deck = [];

  void startNewGame(List<Player> gamePlayers) {
    players = gamePlayers;
    _initializeDeck();
    startNewRound();
  }

  void startNewRound() {
    // Clear all hands
    for (var player in players) {
      player.hand.clear();
    }

    // Reset and shuffle deck
    _initializeDeck();
    _shuffleDeck();

    // Deal cards (6 cards per player)
    for (var i = 0; i < 6; i++) {
      for (var player in players) {
        if (deck.isNotEmpty) {
          player.hand.add(deck.removeLast());
        }
      }
    }

    // Set trump card
    if (deck.isNotEmpty) {
      trumpCard = deck.removeLast();
    }
  }

  void _initializeDeck() {
    deck.clear();
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void _shuffleDeck() {
    final random = Random();
    for (var i = deck.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = deck[i];
      deck[i] = deck[j];
      deck[j] = temp;
    }
  }
}
