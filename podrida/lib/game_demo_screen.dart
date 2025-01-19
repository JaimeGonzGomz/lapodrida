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
    print(
        "Triggering bot play, current player: ${gameState.currentPlayerIndex}");

    // Don't trigger if it's the human player's turn
    if (gameState.currentPlayerIndex == 0) {
      return;
    }

    // Don't trigger if trick is complete
    if (gameState.currentTrick.cards.length >= gameState.players.length) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        try {
          final currentBot = gameState.players[gameState.currentPlayerIndex];
          if (currentBot.hand.isEmpty) {
            print("Bot ${currentBot.name} has no cards left");
            return;
          }

          PlayingCard selectedCard =
              BotPlayer.playCard(currentBot, gameState.currentTrick.leadCard);

          print("Bot ${currentBot.name} playing card");
          if (gameState.playCard(currentBot, selectedCard)) {
            // Only trigger next bot if trick isn't complete
            if (gameState.currentTrick.cards.length <
                gameState.players.length) {
              _triggerBotPlay();
            }
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
              // Main game layout
              Column(
                children: [
                  // Game area takes most space
                  Expanded(
                    child: Stack(
                      children: [
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
                  // Control/admin bar first
                  _buildControlBar(),
                  // Then betting phase if active
                  if (gameState.isBettingPhase)
                    BettingPhase(
                      gameState: gameState,
                      onBetPlaced: _handleBetPlaced,
                      remainingTime: _remainingTime,
                    ),
                ],
              ),

              // Trump card and betting summary overlays remain in the stack
              if (gameState.trumpCard != null)
                Positioned(
                  left: 20,
                  bottom: kBottomNavigationBarHeight + 80,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(77),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Trump',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        CardWidget(
                          card: gameState.trumpCard!..faceUp = true,
                          width: 62.5,
                          height: 87.5,
                        ),
                      ],
                    ),
                  ),
                ),

              // Betting Summary overlay
              if (showBettingSummary)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: Center(child: _buildBettingSummary()),
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
    if (gameState.currentBettingPlayerIndex == 0) {
      return; // Skip if human player
    }

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
      if (gameState.isBettingPhase &&
              gameState.currentBettingPlayerIndex != 0 ||
          !gameState.isBettingPhase && gameState.currentPlayerIndex != 0) {
        timer.cancel();
        return;
      }

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

  bool isBettingVisible = true;

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

    gameState.onTrickResolved = () {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        setState(() {
          gameState.finishTrickResolution();
          print(
              "Trick finished, next player index: ${gameState.currentPlayerIndex}");

          // Check if round is over
          if (gameState.players.every((p) => p.hand.isEmpty)) {
            print("Round is over, starting new round...");
            for (var player in gameState.players) {
              player.score += player.tricksWon;
              if (player.tricksWon == player.currentBet) {
                player.score += 10;
              }
            }

            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                gameState.startNewRound();
                _startTimer(betTimeLimit, _handleBetTimeout);
              });
            });
          } else {
            // Trigger bot play if it's their turn
            print("Round continues, checking if bot should play...");
            if (gameState.currentPlayerIndex != 0) {
              _triggerBotPlay();
            } else {
              // Start timer for human player
              _startTimer(playTimeLimit, _handlePlayTimeout);
            }
          }
        });
      });
    };
  }

  void _handleBetPlaced(int bet) {
    setState(() {
      Player currentPlayer =
          gameState.players[gameState.currentBettingPlayerIndex];
      if (gameState.placeBet(currentPlayer, bet)) {
        if (!gameState.isBettingPhase) {
          // Only show summary when all bets are placed
          isBettingVisible = false;
          showBettingSummary = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() => showBettingSummary = false);
            }
          });
        }
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
    if (_remainingTime <= 0 ||
        (gameState.isBettingPhase &&
            gameState.currentBettingPlayerIndex != 0) ||
        (!gameState.isBettingPhase && gameState.currentPlayerIndex != 0)) {
      return const SizedBox.shrink();
    }

    final progress = _remainingTime /
        (gameState.isBettingPhase ? betTimeLimit : playTimeLimit);

    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(50, 50),
            painter: TimerProgressPainter(progress),
          ),
          Text(
            '$_remainingTime',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

        // Center area for played cards
        if (gameState.currentTrick.cards.isNotEmpty)
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: PlayedCardsDisplay(gameState: gameState),
            ),
          ),

        // Trump card (at bottom left)

        // Trump card (moved under Player 2)

        // Current player's hand
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

  bool showBettingSummary = false;

  Widget _buildBettingSummary() {
    return AnimatedOpacity(
      opacity: showBettingSummary ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Betting Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...gameState.players.map((player) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${player.currentBet} tricks',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
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
            TextButton.icon(
              onPressed: () {
                setState(() => showBettingSummary = true);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() => showBettingSummary = false);
                  }
                });
              },
              icon: const Icon(Icons.analytics, color: Colors.white70),
              label: const Text(
                'Betting Summary',
                style: TextStyle(color: Colors.white70),
              ),
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

class TimerProgressPainter extends CustomPainter {
  final double progress;

  TimerProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = progress <= 0.3 ? Colors.red : Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -90 * (3.14159 / 180); // Start from top
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(TimerProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
