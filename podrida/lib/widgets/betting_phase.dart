import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/card.dart';

class BettingPhase extends StatefulWidget {
  final GameState gameState;
  final Function(int) onBetPlaced;
  final int remainingTime;
  final VoidCallback? onHide;

  const BettingPhase({
    super.key,
    required this.gameState,
    required this.onBetPlaced,
    required this.remainingTime,
    this.onHide,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white10),
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Timer only (removed Trump)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.remainingTime <= 5 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.remainingTime}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Center - Betting controls
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentPlayer.name}\'s Bet',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle,
                        color: Colors.white, size: 20),
                    onPressed: selectedBet > 0
                        ? () => setState(() => selectedBet--)
                        : null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selectedBet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.white, size: 20),
                    onPressed: selectedBet < widget.gameState.cardsPerPlayer
                        ? () => setState(() => selectedBet++)
                        : null,
                  ),
                ],
              ),
            ],
          ),

          // Right side - Place bet button and total
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onBetPlaced(selectedBet);
                  setState(() => selectedBet = 0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Place Bet'),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${_calculateTotalBets()}/${widget.gameState.totalCardsInHand}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
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
