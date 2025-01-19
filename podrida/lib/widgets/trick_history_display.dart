import 'package:flutter/material.dart';
import '../models/trick_history.dart';
import '../models/card.dart';

class TrickHistoryDisplay extends StatelessWidget {
  final TrickHistory history;
  final VoidCallback onClose;

  const TrickHistoryDisplay({
    super.key,
    required this.history,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var trick in history.completedTricks.reversed)
                    _buildTrickCard(trick),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Round History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTrickCard(CompletedTrick trick) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with winner and trump card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Winner: ${trick.winner.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trick.trumpCard != null)
                Row(
                  children: [
                    const Text(
                      'Trump: ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    CardWidget(
                      card: trick.trumpCard!..faceUp = true,
                      width: 20,
                      height: 28,
                    ),
                  ],
                ),
            ],
          ),

          const Divider(color: Colors.white24),

          // Cards played in the trick
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var play in trick.plays)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Player name
                    Text(
                      play.player.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    // Points (using player's score)
                    Text(
                      '${play.player == trick.winner ? "+1" : "+0"}',
                      style: TextStyle(
                        color: play.player == trick.winner
                            ? Colors.green
                            : Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Card played
                    CardWidget(
                      card: play.card..faceUp = true,
                      width: 40,
                      height: 56,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
