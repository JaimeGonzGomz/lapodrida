import 'package:flutter/material.dart';
import '../utils/timer_progress_painter.dart';

class TimerDisplay extends StatelessWidget {
  final int remainingTime;
  final bool isBettingPhase;
  final int currentPlayerIndex;
  final int currentBettingPlayerIndex;
  static const int betTimeLimit = 30;
  static const int playTimeLimit = 20;

  const TimerDisplay({
    super.key,
    required this.remainingTime,
    required this.isBettingPhase,
    required this.currentPlayerIndex,
    required this.currentBettingPlayerIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (remainingTime <= 0 ||
        (isBettingPhase && currentBettingPlayerIndex != 0) ||
        (!isBettingPhase && currentPlayerIndex != 0)) {
      return const SizedBox.shrink();
    }

    final progress =
        remainingTime / (isBettingPhase ? betTimeLimit : playTimeLimit);

    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(50, 50),
            painter: TimerProgressPainter(progress),
          ),
          Text(
            '$remainingTime',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
