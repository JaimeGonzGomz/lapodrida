import 'package:flutter/material.dart';
import '../models/card.dart';

class CompactCardDisplay extends StatefulWidget {
  final List<PlayingCard> cards;
  final bool showAll;
  final bool isCurrentPlayer;

  const CompactCardDisplay({
    super.key,
    required this.cards,
    this.showAll = false,
    this.isCurrentPlayer = false,
  });

  @override
  State<CompactCardDisplay> createState() => _CompactCardDisplayState();
}

class _CompactCardDisplayState extends State<CompactCardDisplay> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (!widget.showAll) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardWidget(
            card: widget.cards.first..faceUp = false,
            width: 40,
            height: 56,
          ),
          Text(
            ' x${widget.cards.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cards.length,
        itemBuilder: (context, index) {
          return MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = index),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: GestureDetector(
              onTapDown: (_) =>
                  setState(() => widget.cards[index].faceUp = true),
              onTapUp: (_) => setState(
                  () => widget.cards[index].faceUp = widget.isCurrentPlayer),
              onTapCancel: () => setState(
                  () => widget.cards[index].faceUp = widget.isCurrentPlayer),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()
                  ..scale(hoveredIndex == index ? 1.5 : 1.0)
                  ..translate(
                    0.0,
                    hoveredIndex == index ? -20.0 : 0.0,
                  ),
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : -25.0,
                  ),
                  child: CardWidget(
                    card: widget.cards[index]..faceUp = widget.isCurrentPlayer,
                    width: 60,
                    height: 84,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
