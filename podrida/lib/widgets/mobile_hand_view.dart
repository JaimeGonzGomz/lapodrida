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
    Key? key,
    required this.player,
    required this.isCurrentPlayer,
    required this.isExpanded,
    required this.onToggleExpand,
  }) : super(key: key);

  @override
  _MobileHandViewState createState() => _MobileHandViewState();
}

class _MobileHandViewState extends State<MobileHandView> {
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate card dimensions based on view mode
    final cardWidth = screenWidth * (widget.isExpanded ? 0.12 : 0.08);
    final cardHeight = cardWidth * 1.4;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalCardsWidth =
              widget.player.hand.length * cardWidth * 0.4 + cardWidth * 0.6;
          final containerWidth = widget.isExpanded
              ? totalCardsWidth + cardWidth * 0.4 // Add padding when expanded
              : screenWidth; // Full width when collapsed

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: containerWidth,
            height:
                widget.isExpanded ? screenHeight * 0.45 : screenHeight * 0.15,
            decoration: widget.isExpanded
                ? BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Column(
              children: [
                // Player name only shown when expanded
                if (widget.isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: Text(
                      widget.player.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isExpanded ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Cards container
                Expanded(
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(
                        widget.player.hand.length,
                        (index) => Positioned(
                          left: index * cardWidth * 0.4 + 24,
                          top: 0,
                          bottom: 24,
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => hoveredIndex = index),
                            onExit: (_) => setState(() => hoveredIndex = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.identity()
                                ..scale(
                                    hoveredIndex == index && widget.isExpanded
                                        ? 1.3
                                        : 1.0)
                                ..translate(
                                  0.0,
                                  hoveredIndex == index && widget.isExpanded
                                      ? -20.0
                                      : 0.0,
                                ),
                              child: GestureDetector(
                                onTapDown: (_) => setState(() =>
                                    widget.player.hand[index].faceUp = true),
                                onTapUp: (_) => setState(() => widget
                                    .player
                                    .hand[index]
                                    .faceUp = widget.isCurrentPlayer),
                                onTapCancel: () => setState(() => widget
                                    .player
                                    .hand[index]
                                    .faceUp = widget.isCurrentPlayer),
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
