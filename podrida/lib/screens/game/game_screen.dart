import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../models/card.dart';
import '../../../models/player.dart';
import '../../../models/game_state.dart';
import '../../../models/bot_player.dart';
import '../../../models/rules.dart';
import 'components/game_control_bar.dart';
import 'components/betting_summary.dart';
import 'components/betting_phase.dart';
import 'components/game_board.dart';
import 'components/timer_display.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  GameState gameState = GameState();
  bool isHandExpanded = true;
  bool showBettingSummary = false;
  Timer? _actionTimer;
  int _remainingTime = 0;
  bool isBettingVisible = true;

  static const int betTimeLimit = 30;
  static const int playTimeLimit = 20;

  @override
  void initState() {
    super.initState();
    setupGame();
    _startTimer(betTimeLimit, _handleBetTimeout);
    _setupTrickResolution();
  }

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

  void _setupTrickResolution() {
    gameState.onTrickResolved = () {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          gameState.finishTrickResolution();
          if (gameState.players.every((p) => p.hand.isEmpty)) {
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                gameState.startNewRound();
                _startTimer(betTimeLimit, _handleBetTimeout);
              });
            });
          } else {
            if (gameState.currentPlayerIndex != 0) {
              _triggerBotPlay();
            } else {
              _startTimer(playTimeLimit, _handlePlayTimeout);
            }
          }
        });
      });
    };
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

  void _handleBetTimeout() {
    if (gameState.isBettingPhase) {
      final currentPlayer =
          gameState.players[gameState.currentBettingPlayerIndex];
      if (currentPlayer.id == '1') {
        int randomBet = Random().nextInt(gameState.cardsPerPlayer + 1);
        _handleBetPlaced(randomBet);
      }
    }
  }

  void _handlePlayTimeout() {
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

  void _triggerBotPlay() {
    if (gameState.currentPlayerIndex == 0) return;
    if (gameState.currentTrick.cards.length >= gameState.players.length) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        try {
          final currentBot = gameState.players[gameState.currentPlayerIndex];
          if (currentBot.hand.isEmpty) return;

          PlayingCard selectedCard =
              BotPlayer.playCard(currentBot, gameState.currentTrick.leadCard);

          if (gameState.playCard(currentBot, selectedCard)) {
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

  void _handleBetPlaced(int bet) {
    setState(() {
      Player currentPlayer =
          gameState.players[gameState.currentBettingPlayerIndex];
      if (gameState.placeBet(currentPlayer, bet)) {
        if (!gameState.isBettingPhase) {
          isBettingVisible = false;
          showBettingSummary = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => showBettingSummary = false);
          });
        }
        _triggerBotBet();
      }
    });
  }

  void _triggerBotBet() {
    if (!gameState.isBettingPhase) return;
    if (gameState.currentBettingPlayerIndex == 0) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final currentBot =
            gameState.players[gameState.currentBettingPlayerIndex];
        bool isLastBetter =
            gameState.currentBettingPlayerIndex == gameState.players.length - 1;
        int totalBets = gameState.players
            .where((p) => p.currentBet >= 0)
            .fold(0, (sum, p) => sum + p.currentBet);

        int botBet;
        if (isLastBetter) {
          do {
            botBet = Random().nextInt(gameState.cardsPerPlayer + 1);
          } while (totalBets + botBet == gameState.totalCardsInHand);
        } else {
          botBet = Random().nextInt(gameState.cardsPerPlayer + 1);
        }

        if (gameState.placeBet(currentBot, botBet)) {
          _triggerBotBet();
        }
      });
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

  @override
  void dispose() {
    _actionTimer?.cancel();
    super.dispose();
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
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        GameBoard(
                          gameState: gameState,
                          isHandExpanded: isHandExpanded,
                          onToggleExpand: (expanded) =>
                              setState(() => isHandExpanded = expanded),
                          onCardPlayed: _handleCardPlayed,
                        ),
                        if (!gameState.isBettingPhase)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: TimerDisplay(
                              remainingTime: _remainingTime,
                              isBettingPhase: gameState.isBettingPhase,
                              currentPlayerIndex: gameState.currentPlayerIndex,
                              currentBettingPlayerIndex:
                                  gameState.currentBettingPlayerIndex,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GameControlBar(
                    gameState: gameState,
                    isHandExpanded: isHandExpanded,
                    onToggleExpand: (expanded) =>
                        setState(() => isHandExpanded = expanded),
                    onNewRound: () => setState(() => gameState.startNewRound()),
                    onShowBettingSummary: () {
                      setState(() => showBettingSummary = true);
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) setState(() => showBettingSummary = false);
                      });
                    },
                  ),
                  if (gameState.isBettingPhase)
                    BettingPhase(
                      gameState: gameState,
                      onBetPlaced: _handleBetPlaced,
                      remainingTime: _remainingTime,
                    ),
                ],
              ),
              if (showBettingSummary)
                BettingSummary(
                  gameState: gameState,
                  showBettingSummary: showBettingSummary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
