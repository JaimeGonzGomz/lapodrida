import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/card.dart';

class AnimatedCardWidget extends StatefulWidget {
  final PlayingCard card;
  final double width;
  final double height;

  const AnimatedCardWidget({
    super.key,
    required this.card,
    required this.width,
    required this.height,
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isHovered ? 1.2 : 1.0)
          ..translate(0.0, isHovered ? -10.0 : 0.0),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: SvgPicture.asset(
            _getCardAssetPath(),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  String _getCardAssetPath() {
    if (!widget.card.faceUp) {
      return 'assets/cards/blue.svg';
    }

    final suitName = widget.card.suit.toString().split('.').last;
    final rankName = _getRankString();
    return 'assets/cards/$suitName/${suitName}_$rankName.svg';
  }

  String _getRankString() {
    switch (widget.card.rank) {
      case Rank.ace:
        return 'ace';
      case Rank.jack:
        return 'jack';
      case Rank.queen:
        return 'queen';
      case Rank.king:
        return 'king';
      default:
        return (widget.card.rank.index + 1).toString();
    }
  }
}
