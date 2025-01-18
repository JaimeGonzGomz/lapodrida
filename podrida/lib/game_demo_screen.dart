import 'package:flutter/material.dart';
import 'dart:math';
import 'models/card.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'widgets/mobile_hand_view.dart';
import 'widgets/player_info_card.dart';
import 'widgets/played_cards_display.dart';
import 'models/bot_player.dart';
import 'widgets/betting_phase.dart';
import 'widgets/trick_history_display.dart';
import 'dart:async';
import 'models/rules.dart';

class GameDemoScreen extends StatefulWidget {
  const GameDemoScreen({super.key});

  @override
  State<GameDemoScreen> createState() => GameDemoScreenState();
}

class GameDemoScreenState extends State<GameDemoScreen> {
  // Initialize gameState and isHandExpanded as class fields
  GameState gameState = GameState();
  bool isHandExpanded = true;

  void setupGame() {
    setState(() {
      gameState.startNewGame([
        Player(id: '1', name: 'Player Name'),
        Player(id: '2', name: 'Player 2'),
        Player(id: '3', name: 'Player 3'),
        Player(id: '4', name: 'Player 4'),
      ]);
    });
  }

  void _triggerBotPlay() {
    // Don't trigger if it's the human player's turn
    if (gameState.currentPlayerIndex == 0) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        try {
          final currentBot = gameState.players[gameState.currentPlayerIndex];
          PlayingCard selectedCard =
              BotPlayer.playCard(currentBot, gameState.currentTrick.leadCard);

          // For debugging - print bot's decision making
          BotPlayer.debugBotPlay(currentBot, gameState.currentTrick.leadCard);

          if (gameState.playCard(currentBot, selectedCard)) {
            // Recursively trigger next bot's play
            _triggerBotPlay();
          }
        } catch (e) {
          print('Error during bot play: $e');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              if (gameState.trumpCard != null)
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 32.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(77),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Trump Card',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 8),
                                              CardWidget(
                                                card: gameState.trumpCard!
                                                  ..faceUp = true,
                                                width: 70,
                                                height: 98,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      if (gameState
                                          .currentTrick.cards.isNotEmpty)
                                        PlayedCardsDisplay(
                                            gameState: gameState),
                                    ],
                                  ),
                                ),
                              Positioned.fill(
                                child: _buildPlayerPositions(),
                              ),
                              if (!gameState.isBettingPhase)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: _buildTimerDisplay(),
                                ),
                            ],
                          ),
                        ),
                        _buildControlBar(),
                      ],
                    ),
                  ),
                ],
              ),
              if (gameState.isBettingPhase)
                Center(
                  child: BettingPhase(
                    gameState: gameState,
                    onBetPlaced: _handleBetPlaced,
                    remainingTime: _remainingTime,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerBotBet() {
    if (!gameState.isBettingPhase) return;
    if (gameState.currentBettingPlayerIndex == 0)
      return; // Skip if human player

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final currentBot =
            gameState.players[gameState.currentBettingPlayerIndex];

        // Simple bot betting strategy
        int remainingTricks = gameState.totalCardsInHand;
        int totalBets = gameState.players
            .where((p) => p.currentBet >= 0)
            .fold(0, (sum, p) => sum + p.currentBet);

        bool isLastBetter =
            gameState.currentBettingPlayerIndex == gameState.players.length - 1;
        int botBet;

        if (isLastBetter) {
          // Make sure total doesn't equal remaining tricks
          do {
            botBet = Random().nextInt(gameState.cardsPerPlayer + 1);
          } while (totalBets + botBet == remainingTricks);
        } else {
          botBet = Random().nextInt(gameState.cardsPerPlayer + 1);
        }

        if (gameState.placeBet(currentBot, botBet)) {
          _triggerBotBet(); // Continue with next bot
        }
      });
    });
  }

  static const int betTimeLimit = 30; // seconds
  static const int playTimeLimit = 20; // seconds

  Timer? _actionTimer;
  int _remainingTime = 0;

  @override
  void dispose() {
    _actionTimer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds, VoidCallback onTimeout) {
    _actionTimer?.cancel();
    setState(() => _remainingTime = seconds);

    _actionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          onTimeout();
        }
      });
    });
  }

  void _handleBetTimeout() {
    // Make random valid bet if timer expires
    if (gameState.isBettingPhase) {
      final currentPlayer =
          gameState.players[gameState.currentBettingPlayerIndex];
      if (currentPlayer.id == '1') {
        // Human player
        int randomBet = Random().nextInt(gameState.cardsPerPlayer + 1);
        _handleBetPlaced(randomBet);
      }
    }
  }

  void _handlePlayTimeout() {
    // Play random valid card if timer expires
    if (!gameState.isBettingPhase && gameState.currentPlayerIndex == 0) {
      final player = gameState.players[0];
      final validCards = GameRules.getPlayableCards(
          player.hand, gameState.currentTrick.leadCard);
      if (validCards.isNotEmpty) {
        final randomCard = validCards[Random().nextInt(validCards.length)];
        _handleCardPlayed(randomCard);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setupGame();
    _startTimer(betTimeLimit, _handleBetTimeout);

    // Add callback for trick resolution
    gameState.onTrickResolved = () {
      // Wait 1 second before resolving the trick
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          gameState.finishTrickResolution();
        });
      });
    };
  }

  void _handleBetPlaced(int bet) {
    setState(() {
      Player currentPlayer =
          gameState.players[gameState.currentBettingPlayerIndex];
      if (gameState.placeBet(currentPlayer, bet)) {
        // If it's a bot's turn to bet, simulate their bet
        _triggerBotBet();
      }
    });
  }

  void _handleCardPlayed(PlayingCard card) {
    setState(() {
      if (gameState.playCard(gameState.players[0], card)) {
        _startTimer(playTimeLimit, _handlePlayTimeout);
        _triggerBotPlay();
      }
    });
  }

  Widget _buildTimerDisplay() {
    if (_remainingTime <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _remainingTime <= 5 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$_remainingTime seconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlayerPositions() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Top player
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: PlayerInfoCard(
              player: gameState.players[2],
              score: 750,
              cards: gameState.players[2].hand,
            ),
          ),
        ),

        // Left player
        Positioned(
          left: 10,
          top: screenHeight * 0.3,
          child: PlayerInfoCard(
            player: gameState.players[1],
            score: 500,
            cards: gameState.players[1].hand,
            isVertical: true,
          ),
        ),

        // Right player
        Positioned(
          right: 10,
          top: screenHeight * 0.3,
          child: PlayerInfoCard(
            player: gameState.players[3],
            score: 250,
            cards: gameState.players[3].hand,
            isVertical: true,
          ),
        ),

        // Current player's info (left side)
        Positioned(
          left: 10,
          bottom: screenHeight * 0.15,
          child: PlayerInfoCard(
            player: gameState.players[0],
            score: 1000,
            cards: gameState.players[0].hand,
            isCurrentPlayer: true,
          ),
        ),

        // Current player's hand (center bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: MobileHandView(
              player: gameState.players[0],
              isCurrentPlayer: true,
              isExpanded: isHandExpanded,
              onToggleExpand: (bool expanded) =>
                  setState(() => isHandExpanded = expanded),
              gameState: gameState,
              onCardPlayed: _handleCardPlayed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      gameState.setCardsPerPlayer(gameState.cardsPerPlayer - 1);
                    });
                  },
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${gameState.cardsPerPlayer} cards',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: TrickHistoryDisplay(
                          history: gameState.trickHistory,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, color: Colors.white70),
                  label: const Text(
                    'Show History',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      gameState.setCardsPerPlayer(gameState.cardsPerPlayer + 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => setState(() => gameState.startNewRound()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: const Text('Deal New Round'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () => setState(() => isHandExpanded = !isHandExpanded),
              icon: Icon(
                isHandExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.white70,
              ),
              label: Text(
                isHandExpanded ? 'Show Current Round' : 'Show Hand',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
