import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/card.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'widgets/animated_card_widget.dart';

class GameDemoScreen extends StatefulWidget {
  @override
  _GameDemoScreenState createState() => _GameDemoScreenState();
}

class _GameDemoScreenState extends State<GameDemoScreen> {
  late GameState gameState;
  int? hoveredPlayerIndex;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    setupGame();
  }

  void setupGame() {
    gameState.startNewGame([
      Player(id: '1', name: 'Player 1'),
      Player(id: '2', name: 'Player 2'),
      Player(id: '3', name: 'Player 3'),
      Player(id: '4', name: 'Player 4'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Trump Card',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(height: 8),
                                    CardWidget(
                                      card: gameState.trumpCard!..faceUp = true,
                                      width: 50,
                                      height: 70,
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
          padding: EdgeInsets.symmetric(horizontal: 4),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Player 3 (Top)
        Positioned(
          top: 20,
          left: screenWidth * 0.3,
          right: screenWidth * 0.3,
          child: _buildPlayerHand(2, Alignment.topCenter),
        ),
        // Player 2 (Left)
        Positioned(
          left: 20,
          top: screenHeight * 0.2,
          child: Column(
            children: [
              RotatedBox(
                quarterTurns:
                    3, // Changed rotation to make cards stack vertically
                child: Text(
                  gameState.players[1].name,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height:
                    screenHeight * 0.4, // Constrain height for vertical cards
                child: Column(
                  children: gameState.players[1].hand.map((card) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: AnimatedCardWidget(
                        card: card,
                        width: 70,
                        height: 100,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Player 4 (Right)
        Positioned(
          right: 20,
          top: screenHeight * 0.2,
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Text(
                  gameState.players[3].name,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: screenHeight * 0.4,
                child: Column(
                  children: gameState.players[3].hand.map((card) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: AnimatedCardWidget(
                        card: card,
                        width: 70,
                        height: 100,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Player 1 (Bottom)
        Positioned(
          bottom: 20,
          left: screenWidth * 0.3,
          right: screenWidth * 0.3,
          child: _buildPlayerHand(0, Alignment.bottomCenter,
              isCurrentPlayer: true),
        ),
      ],
    );
  }

  Widget _buildPlayerHand(int playerIndex, Alignment alignment,
      {bool isCurrentPlayer = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gameState.players[playerIndex].name,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameState.players[playerIndex].hand.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
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
      padding: EdgeInsets.all(16),
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => gameState.startNewRound()),
            child: Text('Deal New Round'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}
