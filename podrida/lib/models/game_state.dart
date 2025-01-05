import 'dart:math';
import 'card.dart';
import 'player.dart';
import 'trick_history.dart';
import 'rules.dart';

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

  TrickHistory trickHistory = TrickHistory();

  void _resolveTrick() {
    if (currentTrick.cards.length == players.length) {
      // Determine winning card
      int winningCardIndex = GameRules.determineWinningCardIndex(
          currentTrick.cards, trumpCard, currentTrick.leadCard!);

      // Get winning player
      Player winner = currentTrick.players[winningCardIndex];

      // Create trick plays list
      List<TrickPlay> plays = List.generate(currentTrick.cards.length,
          (i) => TrickPlay(currentTrick.players[i], currentTrick.cards[i]));

      // Add to history
      trickHistory.addCompletedTrick(plays, winner, trumpCard);

      // Set next player to the winner
      currentPlayerIndex = players.indexOf(winner);

      // Clear current trick
      currentTrick.clear();
    }
  }

// Update playCard method to ensure lead card is tracked
  bool playCard(Player player, PlayingCard card) {
    if (players[currentPlayerIndex].id != player.id) {
      return false;
    }
    if (!player.hand.remove(card)) {
      return false;
    }

    currentTrick.addCard(card, player);

    // Only change current player if trick isn't complete
    if (currentTrick.cards.length < players.length) {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } else {
      _resolveTrick(); // This will set the next player to the winner
    }

    return true;
  }
}
