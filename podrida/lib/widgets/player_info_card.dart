import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/card.dart';

class PlayerInfoCard extends StatelessWidget {
  final Player player;
  final int score;
  final List<PlayingCard> cards;
  final bool isVertical;
  final bool isCurrentPlayer;

  const PlayerInfoCard({
    super.key,
    required this.player,
    this.score = 0,
    required this.cards,
    this.isVertical = false,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade800.withAlpha(123),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: ${player.score}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
                // Make tricks won info more prominent
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: player.tricksWon == player.currentBet
                            ? Colors.green.withAlpha(100)
                            : Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Tricks: ${player.tricksWon}/${player.currentBet}',
                        style: TextStyle(
                          color: player.tricksWon == player.currentBet
                              ? Colors.green.shade300
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
