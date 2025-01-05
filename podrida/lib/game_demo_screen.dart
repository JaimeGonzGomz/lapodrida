import 'package:flutter/material.dart';
import 'package:podrida/models/rules.dart';
import 'models/card.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'widgets/animated_card_widget.dart';
import 'widgets/mobile_hand_view.dart';
import 'widgets/player_info_card.dart';
import 'widgets/played_cards_display.dart';

class GameDemoScreen extends StatefulWidget {
  const GameDemoScreen({super.key});

  @override
  _GameDemoScreenState createState() => _GameDemoScreenState();
}

class _GameDemoScreenState extends State<GameDemoScreen> {
  late GameState gameState;
  bool isHandExpanded = true;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    setupGame();
  }

  void setupGame() {
    gameState.startNewGame([
      Player(id: '1', name: 'Player Name'),
      Player(id: '2', name: 'Player 2'),
      Player(id: '3', name: 'Player 3'),
      Player(id: '4', name: 'Player 4'),
    ]);
  }

  void _handleCardPlayed(PlayingCard card) {
    setState(() {
      if (gameState.playCard(gameState.players[0], card)) {
        if (gameState.currentPlayerIndex == 3) {
          _playAutomaticCard();
        }
      }
    });
  }

  void _playAutomaticCard() {
    final player4 = gameState.players[3];
    final playableCards = GameRules.getPlayableCards(
        player4.hand, gameState.currentTrick.leadCard);

    if (playableCards.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          gameState.playCard(player4, playableCards.first);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (gameState.trumpCard != null)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Trump Card',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          const SizedBox(height: 8),
                                          CardWidget(
                                            card: gameState.trumpCard!
                                              ..faceUp = true,
                                            width: 50,
                                            height: 70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  // Add played cards display
                                  if (gameState.currentTrick.cards.isNotEmpty)
                                    PlayedCardsDisplay(gameState: gameState),
                                ],
                              ),
                            ),
                          Positioned.fill(
                            child: _buildPlayerPositions(),
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
        ),
      ),
    );
  }

  Widget _buildCards(Player player, bool isCurrentPlayer) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: player.hand.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedCardWidget(
            // Use AnimatedCardWidget instead of CardWidget
            card: player.hand[index]..faceUp = isCurrentPlayer,
            width: 70, // Made cards a bit bigger
            height: 100,
          ),
        );
      },
    );
  }

  Widget _buildPlayerPositions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isHandExpanded = this.isHandExpanded;

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

  Widget _buildPlayerHand(int playerIndex, Alignment alignment,
      {bool isCurrentPlayer = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gameState.players[playerIndex].name,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameState.players[playerIndex].hand.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedCardWidget(
                    card: gameState.players[playerIndex].hand[index]
                      ..faceUp = isCurrentPlayer,
                    width: 70,
                    height: 100,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card count controls
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
              IconButton(
                icon:
                    const Icon(Icons.add_circle_outline, color: Colors.white70),
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
    );
  }
}
