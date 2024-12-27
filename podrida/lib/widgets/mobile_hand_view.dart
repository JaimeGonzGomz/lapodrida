import 'package:flutter/material.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/rules.dart';

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
  bool isDragging = false;
  double dragOffset = 0.0;

  bool isCardPlayable(PlayingCard card) {
    return GameRules.canPlayCard(
        card, widget.gameState.currentTrick.leadCard, widget.player.hand);
  }

  void resetCardState() {
    setState(() {
      isDragging = false;
      dragOffset = 0.0;
    });
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
    final dropZoneHeight = handContainerHeight / 2;
    final bottomPadding = 10.0;

    return SizedBox(
      height: widget.isExpanded ? screenHeight * 0.45 : screenHeight * 0.15,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (widget.isExpanded)
            Container(
              width: totalCardsWidth + cardWidth * 0.4,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          if (isDragging && widget.isExpanded && selectedIndex != null)
            Positioned(
              bottom: dropZoneHeight + bottomPadding,
              child: Container(
                width: totalCardsWidth + cardWidth * 0.4,
                height: cardHeight * 1.2,
                decoration: BoxDecoration(
                  color: (dragOffset > dropZoneHeight * 0.8)
                      ? Colors.green.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: (dragOffset > dropZoneHeight * 0.8)
                        ? Colors.green
                        : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: (dragOffset > dropZoneHeight * 0.8)
                            ? Colors.green
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (dragOffset > dropZoneHeight * 0.8)
                            ? 'Release to Play Card'
                            : 'Drag Card Here',
                        style: TextStyle(
                          color: (dragOffset > dropZoneHeight * 0.8)
                              ? Colors.green
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Cards
          Positioned(
            bottom: bottomPadding,
            child: SizedBox(
              width: totalCardsWidth,
              height: handContainerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: List.generate(widget.player.hand.length, (index) {
                  final isSelected = selectedIndex == index;
                  final card = widget.player.hand[index];
                  final isPlayable = isCardPlayable(card);

                  return Positioned(
                    left: index * cardWidth * 0.4,
                    bottom: 0,
                    width: cardWidth,
                    height: cardHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onDoubleTap: widget.isExpanded
                          ? () {
                              if (isPlayable) {
                                widget.onCardPlayed(card);
                                setState(() {
                                  selectedIndex = null;
                                  isDragging = false;
                                  dragOffset = 0.0;
                                });
                              }
                            }
                          : null,
                      onTapDown: widget.isExpanded
                          ? (details) {
                              if (isPlayable && !isSelected) {
                                setState(() {
                                  selectedIndex = index;
                                  isDragging = false;
                                  dragOffset = 0.0;
                                });
                              }
                            }
                          : null,
                      onTap: widget.isExpanded
                          ? () {
                              if (isPlayable && isSelected && !isDragging) {
                                setState(() {
                                  selectedIndex = null;
                                  dragOffset = 0.0;
                                });
                              }
                            }
                          : null,
                      onVerticalDragStart: widget.isExpanded
                          ? (details) {
                              if (isPlayable && isSelected) {
                                setState(() {
                                  isDragging = true;
                                  dragOffset = 0.0;
                                });
                              }
                            }
                          : null,
                      onVerticalDragUpdate: widget.isExpanded
                          ? (details) {
                              if (isPlayable && isDragging && isSelected) {
                                setState(() {
                                  dragOffset -= details.delta.dy;
                                  dragOffset =
                                      dragOffset.clamp(0.0, dropZoneHeight);
                                });
                              }
                            }
                          : null,
                      onVerticalDragEnd: widget.isExpanded
                          ? (details) {
                              if (isPlayable &&
                                  isDragging &&
                                  isSelected &&
                                  dragOffset > dropZoneHeight * 0.8) {
                                widget.onCardPlayed(card);
                                setState(() {
                                  selectedIndex = null;
                                });
                              }
                              resetCardState();
                            }
                          : null,
                      onVerticalDragCancel: resetCardState,
                      child: AnimatedContainer(
                        duration: isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.identity()
                          ..translate(
                              0.0,
                              isSelected
                                  ? (isDragging ? -dragOffset : -20.0)
                                  : 0.0),
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                )
                              : null,
                          child: CardWidget(
                            card: card..faceUp = widget.isCurrentPlayer,
                            width: cardWidth,
                            height: cardHeight,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
