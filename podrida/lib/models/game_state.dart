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
} // In game_state.dart

// In game_state.dart
typedef DelayedCallback = void Function();

class GameState {
  List<Player> players = [];
  PlayingCard? trumpCard;
  List<PlayingCard> deck = [];
  int cardsPerPlayer = 6;
  int totalCardsInHand = 0;
  bool isBettingPhase = false;
  int currentBettingPlayerIndex = 0;
  Trick currentTrick = Trick();
  int currentPlayerIndex = 0;
  TrickHistory trickHistory = TrickHistory();

  // Add callback for delayed resolution

  void _resolveTrick() {
    if (currentTrick.cards.length == players.length) {
      // Determine winning card
      int winningCardIndex = GameRules.determineWinningCardIndex(
          currentTrick.cards, trumpCard, currentTrick.leadCard!);
      Player winner = currentTrick.players[winningCardIndex];

      // Notify UI to start delay
      if (onTrickResolved != null) {
        onTrickResolved!();
      }
    }
  }

  DelayedCallback? onTrickResolved;
  void finishTrickResolution() {
    if (currentTrick.cards.length == players.length) {
      int winningCardIndex = GameRules.determineWinningCardIndex(
          currentTrick.cards, trumpCard, currentTrick.leadCard!);

      Player winner = currentTrick.players[winningCardIndex];
      winner.tricksWon++;

      // Add to history
      List<TrickPlay> plays = List.generate(currentTrick.cards.length,
          (i) => TrickPlay(currentTrick.players[i], currentTrick.cards[i]));
      trickHistory.addCompletedTrick(plays, winner, trumpCard);

      // Clear current trick BEFORE setting next player
      currentTrick.clear();

      // Set next player to winner
      currentPlayerIndex = players.indexOf(winner);

      // Calculate scores if round is over
      if (players.every((p) => p.hand.isEmpty)) {
        _calculateRoundScores();
      }
    }
  }

  void startNewGame(List<Player> gamePlayers) {
    players = gamePlayers;
    _initializeDeck();
    startNewRound();
  }

  void startNewRound() {
    for (var player in players) {
      player.resetRoundStats();
      player.hand.clear();
    }
    currentTrick.clear();
    currentPlayerIndex = 0;
    totalCardsInHand = cardsPerPlayer;
    isBettingPhase = true;
    currentBettingPlayerIndex = 0;

    _initializeDeck();
    _shuffleDeck();

    // Deal cards
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

  bool placeBet(Player player, int bet) {
    if (!isBettingPhase || players[currentBettingPlayerIndex].id != player.id) {
      return false;
    }

    // Calculate sum of existing bets
    int totalBets = players
        .where((p) => p.currentBet >= 0)
        .fold(0, (sum, p) => sum + p.currentBet);

    // Check if this is the last player betting
    bool isLastBetter = currentBettingPlayerIndex == players.length - 1;

    // For last player, total bets + their bet can't equal total cards
    if (isLastBetter && (totalBets + bet == totalCardsInHand)) {
      return false;
    }

    player.currentBet = bet;
    currentBettingPlayerIndex++;

    // If all players have bet, start the playing phase
    if (currentBettingPlayerIndex >= players.length) {
      isBettingPhase = false;
      currentPlayerIndex = 0;
    }

    return true;
  }

  bool playCard(Player player, PlayingCard card) {
    if (isBettingPhase) {
      return false;
    }
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
      _resolveTrick(); // This will trigger the delay through onTrickResolved
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

  void _calculateRoundScores() {
    print("GameState._calculateRoundScores called");
    for (var player in players) {
      player.score += player.tricksWon;
      if (player.tricksWon == player.currentBet) {
        player.score += 10;
      }
    }

    // Use the existing onTrickResolved callback
    if (onTrickResolved != null) {
      onTrickResolved!();
    }
  }
}
// In game_state.dart
