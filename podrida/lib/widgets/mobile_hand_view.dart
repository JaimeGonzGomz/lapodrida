import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/rules.dart';
import 'draggable_widget.dart';

class MobileHandView extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isExpanded;
  final ValueChanged<bool> onToggleExpand;
  final GameState gameState;
  final Function(PlayingCard) onCardPlayed;

  const MobileHandView({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.gameState,
    required this.onCardPlayed,
  });

  @override
  State<MobileHandView> createState() => _MobileHandViewState();
}

class _MobileHandViewState extends State<MobileHandView> {
  int? selectedIndex;
  bool isDropTargetActive = false;

  bool isCardPlayable(PlayingCard card) {
    return GameRules.canPlayCard(
        card, widget.gameState.currentTrick.leadCard, widget.player.hand);
  }

  bool get isPlayerTurn {
    // Check if it's this player's turn by comparing with currentPlayerIndex
    int playerIndex =
        widget.gameState.players.indexWhere((p) => p.id == widget.player.id);
    return playerIndex == widget.gameState.currentPlayerIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * (widget.isExpanded ? 0.12 : 0.08);
    final cardHeight = cardWidth * 1.4;
    final totalCardsWidth =
        widget.player.hand.length * cardWidth * 0.4 + cardWidth * 0.6;
    final handContainerHeight =
        widget.isExpanded ? screenHeight * 0.35 : screenHeight * 0.15;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          // Drop Target Area
          if (widget.isExpanded &&
              isPlayerTurn) // Only show drop target on player's turn
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: handContainerHeight + 20,
              child: DragTarget<PlayingCard>(
                onWillAccept: (card) {
                  setState(() => isDropTargetActive = true);
                  return card != null && isCardPlayable(card);
                },
                onAccept: (card) {
                  setState(() => isDropTargetActive = false);
                  widget.onCardPlayed(card);
                },
                onLeave: (_) => setState(() => isDropTargetActive = false),
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDropTargetActive
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: isDropTargetActive
                          ? Colors.green.withAlpha(40)
                          : Colors.transparent,
                    ),
                    child: isDropTargetActive
                        ? const Center(
                            child: Text(
                              'Release to Play',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),

          // Turn Indicator (when it's not player's turn)
          if (!isPlayerTurn && widget.isExpanded)
            Positioned(
              top: screenHeight * 0.3,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Player ${widget.gameState.currentPlayerIndex + 1}\'s Turn',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Hand Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height:
                widget.isExpanded ? screenHeight * 0.35 : screenHeight * 0.15,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 10,
                  child: SizedBox(
                    width: totalCardsWidth,
                    height: handContainerHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children:
                          List.generate(widget.player.hand.length, (index) {
                        final card = widget.player.hand[index];
                        final isPlayable = isCardPlayable(card);

                        return Positioned(
                          left: index * cardWidth * 0.4,
                          bottom: 0,
                          width: cardWidth,
                          height: cardHeight,
                          child: DraggableCardWidget(
                            card: card..faceUp = widget.isCurrentPlayer,
                            width: cardWidth,
                            height: cardHeight,
                            isPlayable: isPlayable,
                            isCurrentTurn: isPlayerTurn, // Pass turn status
                            onCardPlayed: widget.onCardPlayed,
                            onDoubleTap: isPlayable && isPlayerTurn
                                ? () => widget.onCardPlayed(card)
                                : null,
                            onTap: isPlayable && isPlayerTurn
                                ? () {
                                    setState(() {
                                      selectedIndex =
                                          selectedIndex == index ? null : index;
                                    });
                                  }
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
