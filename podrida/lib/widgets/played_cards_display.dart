import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class PlayedCardsDisplay extends StatelessWidget {
  final GameState gameState;

  const PlayedCardsDisplay({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...gameState.currentTrick.cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CardWidget(
                    card: card..faceUp = true,
                    width: 50,
                    height: 70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
