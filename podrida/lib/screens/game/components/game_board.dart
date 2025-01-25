import 'package:flutter/material.dart';
import '../../../models/game_state.dart';
import '../../../models/card.dart';
import '../../../widgets/mobile_hand_view.dart';
import '../../../widgets/player_info_card.dart';
import '../../../widgets/played_cards_display.dart';

class GameBoard extends StatelessWidget {
  final GameState gameState;
  final bool isHandExpanded;
  final ValueChanged<bool> onToggleExpand;
  final Function(PlayingCard) onCardPlayed;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.isHandExpanded,
    required this.onToggleExpand,
    required this.onCardPlayed,
  });

  @override
  Widget build(BuildContext context) {
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

        // Trump card display
        if (gameState.trumpCard != null)
          Positioned(
            left: 15 * MediaQuery.of(context).size.height / 100,
            bottom: kBottomNavigationBarHeight - 30,
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
                    width: MediaQuery.of(context).size.height / 7,
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ],
              ),
            ),
          ),

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
              onToggleExpand: onToggleExpand,
              gameState: gameState,
              onCardPlayed: onCardPlayed,
            ),
          ),
        ),
      ],
    );
  }
}
