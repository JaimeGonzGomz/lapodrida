import 'dart:math';
import 'card.dart';
import 'player.dart';

class Trick {
  List<PlayingCard> cards = [];
  List<Player> players = [];
  PlayingCard? leadCard;

  void addCard(PlayingCard card, Player player) {
    cards.add(card);
    players.add(player);
    leadCard ??= card;
  }

  void clear() {
    cards.clear();
    players.clear();
    leadCard = null;
  }
}

class GameState {
  List<Player> players = [];
  PlayingCard? trumpCard;
  List<PlayingCard> deck = [];
  int cardsPerPlayer = 6;
  Trick currentTrick = Trick();
  int currentPlayerIndex = 0;

  void startNewGame(List<Player> gamePlayers) {
    players = gamePlayers;
    _initializeDeck();
    startNewRound();
  }

  void startNewRound() {
    for (var player in players) {
      player.hand.clear();
    }
    currentTrick.clear();
    currentPlayerIndex = 0;
    _initializeDeck();
    _shuffleDeck();

    for (var i = 0; i < cardsPerPlayer; i++) {
      for (var player in players) {
        if (deck.isNotEmpty) {
          player.hand.add(deck.removeLast());
        }
      }
    }

    if (deck.isNotEmpty) {
      trumpCard = deck.removeLast();
    }
  }

  bool playCard(Player player, PlayingCard card) {
    if (players[currentPlayerIndex].id != player.id) {
      return false;
    }
    if (!player.hand.remove(card)) {
      return false;
    }
    currentTrick.addCard(card, player);
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    if (currentTrick.cards.length == players.length) {
      currentTrick.clear();
    }
    return true;
  }

  void _initializeDeck() {
    deck.clear();
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void setCardsPerPlayer(int count) {
    cardsPerPlayer = count.clamp(1, 13);
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
