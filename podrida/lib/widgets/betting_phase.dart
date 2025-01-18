import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';

class BettingPhase extends StatefulWidget {
  final GameState gameState;
  final Function(int) onBetPlaced;
  final int remainingTime;

  const BettingPhase({
    super.key,
    required this.gameState,
    required this.onBetPlaced,
    required this.remainingTime,
  });

  @override
  State<BettingPhase> createState() => _BettingPhaseState();
}

class _BettingPhaseState extends State<BettingPhase> {
  int selectedBet = 0;

  @override
  Widget build(BuildContext context) {
    Player currentPlayer =
        widget.gameState.players[widget.gameState.currentBettingPlayerIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer display
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.remainingTime <= 5 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.remainingTime} seconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.gameState.trumpCard != null)
            Column(
              children: [
                const Text(
                  'Trump Card',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                CardWidget(
                  card: widget.gameState.trumpCard!..faceUp = true,
                  width: 70,
                  height: 98,
                ),
                const SizedBox(height: 16),
              ],
            ),
          Text(
            '${currentPlayer.name}\'s Bet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.white),
                onPressed: selectedBet > 0
                    ? () => setState(() => selectedBet--)
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$selectedBet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.white),
                onPressed: selectedBet < widget.gameState.cardsPerPlayer
                    ? () => setState(() => selectedBet++)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onBetPlaced(selectedBet);
              setState(() => selectedBet = 0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Place Bet'),
          ),
          const SizedBox(height: 8),
          Text(
            'Total bets: ${_calculateTotalBets()}/${widget.gameState.totalCardsInHand}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  int _calculateTotalBets() {
    return widget.gameState.players
        .where((p) => p.currentBet >= 0)
        .fold(0, (sum, p) => sum + p.currentBet);
  }
}
