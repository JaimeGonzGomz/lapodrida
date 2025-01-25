import 'package:flutter/material.dart';
import '../../../models/game_state.dart';
import '../../../widgets/trick_history_display.dart';

class GameControlBar extends StatelessWidget {
  final GameState gameState;
  final bool isHandExpanded;
  final ValueChanged<bool> onToggleExpand;
  final VoidCallback onNewRound;
  final VoidCallback onShowBettingSummary;

  const GameControlBar({
    super.key,
    required this.gameState,
    required this.isHandExpanded,
    required this.onToggleExpand,
    required this.onNewRound,
    required this.onShowBettingSummary,
  });

  @override
  Widget build(BuildContext context) {
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
                    gameState.setCardsPerPlayer(gameState.cardsPerPlayer - 1);
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
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white70),
                  onPressed: () {
                    gameState.setCardsPerPlayer(gameState.cardsPerPlayer + 1);
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),
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
              label: const Text('Show History',
                  style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.stars, color: Colors.white70),
              label: Text(
                'Score: ${gameState.players[0].score} | Tricks: ${gameState.players[0].tricksWon}/${gameState.players[0].currentBet}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: onShowBettingSummary,
              icon: const Icon(Icons.analytics, color: Colors.white70),
              label: const Text('Betting Summary',
                  style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onNewRound,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              child: const Text('Deal New Round'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () => onToggleExpand(!isHandExpanded),
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
