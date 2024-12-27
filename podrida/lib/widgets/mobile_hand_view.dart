import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card.dart';
import '../models/player.dart';

class MobileHandView extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isExpanded;
  final ValueChanged<bool> onToggleExpand;

  const MobileHandView({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  _MobileHandViewState createState() => _MobileHandViewState();
}

// In mobile_hand_view.dart

// In mobile_hand_view.dart

class _MobileHandViewState extends State<MobileHandView> {
  int? selectedIndex;
  bool isHolding = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * (widget.isExpanded ? 0.12 : 0.08);
    final cardHeight = cardWidth * 1.4;
    final totalCardsWidth =
        widget.player.hand.length * cardWidth * 0.4 + cardWidth * 0.6;

    final cardIndices = List.generate(widget.player.hand.length, (i) => i);
    if (selectedIndex != null) {
      cardIndices.remove(selectedIndex);
      cardIndices.add(selectedIndex!);
    }

    return Center(
      child: Container(
        height: widget.isExpanded ? screenHeight * 0.45 : screenHeight * 0.15,
        width: screenWidth,
        child: Center(
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
              if (widget.isExpanded)
                Positioned(
                  top: 8,
                  child: Text(
                    widget.player.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Center(
                child: SizedBox(
                  width: totalCardsWidth,
                  height: widget.isExpanded
                      ? screenHeight * 0.35
                      : screenHeight * 0.15,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: cardIndices.map((index) {
                      final isSelected = selectedIndex == index && isHolding;

                      return Positioned(
                        left: index * cardWidth * 0.4,
                        child: Listener(
                          onPointerDown: (event) {
                            setState(() {
                              selectedIndex = index;
                              isHolding = true;
                              widget.player.hand[index].faceUp = true;
                            });
                          },
                          onPointerUp: (event) {
                            setState(() {
                              widget.player.hand[index].faceUp =
                                  widget.isCurrentPlayer;
                              isHolding = false;
                              selectedIndex = null;
                            });
                          },
                          onPointerCancel: (event) {
                            setState(() {
                              widget.player.hand[index].faceUp =
                                  widget.isCurrentPlayer;
                              isHolding = false;
                              selectedIndex = null;
                            });
                          },
                          child: MouseRegion(
                            onEnter: (_) {
                              if (!isHolding) {
                                setState(() => selectedIndex = index);
                              }
                            },
                            onExit: (_) {
                              if (!isHolding && selectedIndex == index) {
                                setState(() => selectedIndex = null);
                              }
                            },
                            child: Transform.scale(
                              scale:
                                  isSelected && widget.isExpanded ? 1.1 : 1.0,
                              child: Transform.translate(
                                offset: Offset(
                                    0,
                                    isSelected && widget.isExpanded
                                        ? -20.0
                                        : 0.0),
                                child: Container(
                                  decoration: isSelected && widget.isExpanded
                                      ? BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.yellow
                                                  .withOpacity(0.5),
                                              blurRadius: 15,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: SizedBox(
                                    width: cardWidth,
                                    height: cardHeight,
                                    child: CardWidget(
                                      card: widget.player.hand[index]
                                        ..faceUp = widget.isCurrentPlayer,
                                      width: cardWidth,
                                      height: cardHeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
