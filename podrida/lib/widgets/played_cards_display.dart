import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/game_state.dart';
import 'animated_card_widget.dart';

class PlayedCardsDisplay extends StatefulWidget {
  final GameState gameState;

  const PlayedCardsDisplay({
    super.key,
    required this.gameState,
  });

  @override
  State<PlayedCardsDisplay> createState() => _PlayedCardsDisplayState();
}

class _PlayedCardsDisplayState extends State<PlayedCardsDisplay> {
  List<PlayingCard> animatedCards = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Current Trick',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            width: 250,
            child: Stack(
              children: [
                ...widget.gameState.currentTrick.cards.map((card) {
                  final index =
                      widget.gameState.currentTrick.cards.indexOf(card);
                  final player = widget.gameState.currentTrick.players[index];
                  final playerIndex = widget.gameState.players.indexOf(player);

                  // Calculate start position based on player position
                  final startPosition = _getPlayerCardPosition(playerIndex);
                  final endPosition = Offset(50.0 * index + 10, 0);

                  if (!animatedCards.contains(card)) {
                    animatedCards.add(card);
                    return AnimatedPlayedCard(
                      key: ObjectKey(card),
                      card: card,
                      startPosition: startPosition,
                      endPosition: endPosition,
                      onAnimationComplete: () {},
                    );
                  }

                  return Positioned(
                    left: endPosition.dx,
                    top: endPosition.dy,
                    child: CardWidget(
                      card: card..faceUp = true,
                      width: 50,
                      height: 70,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Offset _getPlayerCardPosition(int playerIndex) {
    switch (playerIndex) {
      case 0: // Bottom player
        return const Offset(125, 200);
      case 1: // Left player
        return const Offset(-50, 100);
      case 2: // Top player
        return const Offset(125, -100);
      case 3: // Right player
        return const Offset(300, 100);
      default:
        return const Offset(0, 0);
    }
  }
}
