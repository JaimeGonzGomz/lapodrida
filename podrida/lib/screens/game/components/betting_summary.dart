import 'package:flutter/material.dart';
import '../../../models/game_state.dart';
import '../../../models/player.dart';

class BettingSummary extends StatelessWidget {
  final GameState gameState;
  final bool showBettingSummary;

  const BettingSummary({
    super.key,
    required this.gameState,
    required this.showBettingSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: AnimatedOpacity(
            opacity: showBettingSummary ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Betting Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRoundTable('Current Round', gameState.players),
                    if (gameState.roundHistory.isNotEmpty) ...[
                      const Divider(color: Colors.white24, height: 32),
                      const Text(
                        'Previous Rounds',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ...gameState.roundHistory.reversed
                          .map((round) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Round ${gameState.roundHistory.length - gameState.roundHistory.indexOf(round)}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildHistoryTable(round),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundTable(String title, List<Player> players) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          children: [
            Text('Player',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
            Text('Bet/Won',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
            Text('Score',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
          ],
        ),
        ...players.map((player) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(player.name,
                      style: const TextStyle(color: Colors.white)),
                ),
                Text(
                  '${player.tricksWon}/${player.currentBet}',
                  style: TextStyle(
                    color: player.tricksWon == player.currentBet
                        ? Colors.green
                        : Colors.white,
                  ),
                ),
                Text(
                  '${player.score}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildHistoryTable(RoundSummary round) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        ...round.playerInfo.map((info) => TableRow(
              children: [
                Text(info.name, style: const TextStyle(color: Colors.white70)),
                Text(
                  '${info.won}/${info.bet}',
                  style: TextStyle(
                    color: info.won == info.bet ? Colors.green : Colors.white70,
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
