import 'package:flutter/material.dart';
import '../models/card.dart';

class DraggableCardWidget extends StatefulWidget {
  final PlayingCard card;
  final double width;
  final double height;
  final bool isPlayable;
  final bool isCurrentTurn; // New parameter
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Function(PlayingCard)? onCardPlayed;

  const DraggableCardWidget({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    required this.isPlayable,
    required this.isCurrentTurn, // Add this
    this.onTap,
    this.onDoubleTap,
    this.onCardPlayed,
  });

  @override
  State<DraggableCardWidget> createState() => _DraggableCardWidgetState();
}

class _DraggableCardWidgetState extends State<DraggableCardWidget> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    Widget child = Stack(
      children: [
        CardWidget(
          card: widget.card,
          width: widget.width,
          height: widget.height,
        ),
        // Show "Wait" overlay when it's not player's turn
        if (!widget.isCurrentTurn)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
            ),
          ),
        // Add this new block for unplayable cards
        if (!widget.isPlayable && widget.isCurrentTurn)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
            ),
          ),
      ],
    );

    child = GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: child,
    );

    if (!widget.isPlayable) {
      return child;
    }

    return Draggable<PlayingCard>(
      data: widget.card,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withAlpha(123),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CardWidget(
              card: widget.card,
              width: widget.width,
              height: widget.height,
            ),
          ),
        ),
      ),
      onDragStarted: () {
        setState(() {
          isDragging = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          isDragging = false;
        });
      },
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.yellow.withAlpha(123),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
