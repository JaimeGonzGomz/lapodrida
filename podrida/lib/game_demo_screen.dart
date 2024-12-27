import 'package:flutter/material.dart';
import 'models/card.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'widgets/animated_card_widget.dart';
import 'package:flutter/services.dart';
import 'widgets/compact_card_display.dart';
import 'widgets/mobile_hand_view.dart';

class GameDemoScreen extends StatefulWidget {
  const GameDemoScreen({super.key});

  @override
  _GameDemoScreenState createState() => _GameDemoScreenState();
}

class _GameDemoScreenState extends State<GameDemoScreen> {
  late GameState gameState;
  int? hoveredPlayerIndex;
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
                              child: Container(
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    CardWidget(
                                      card: gameState.trumpCard!..faceUp = true,
                                      width: 50,
                                      height: 100,
                                    ),
                                  ],
                                ),
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
    final bool isHandExpanded = this.isHandExpanded; // Store state
    return Stack(
      children: [
        // Top player
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  gameState.players[2].name,
                  style: const TextStyle(color: Colors.white),
                ),
                CompactCardDisplay(cards: gameState.players[2].hand),
              ],
            ),
          ),
        ),

        // Left player
        Positioned(
          left: 10,
          top: screenHeight * 0.3,
          child: Column(
            children: [
              Text(
                gameState.players[1].name,
                style: const TextStyle(color: Colors.white),
              ),
              CompactCardDisplay(cards: gameState.players[1].hand),
            ],
          ),
        ),

        // Right player
        Positioned(
          right: 10,
          top: screenHeight * 0.3,
          child: Column(
            children: [
              Text(
                gameState.players[3].name,
                style: const TextStyle(color: Colors.white),
              ),
              CompactCardDisplay(cards: gameState.players[3].hand),
            ],
          ),
        ),

        // Bottom player (current)
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: MobileHandView(
              player: gameState.players[0],
              isCurrentPlayer: true,
              isExpanded: isHandExpanded,
              onToggleExpand: (bool expanded) =>
                  setState(() => this.isHandExpanded = expanded),
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
