import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Suit { hearts, diamonds, clubs, spades }

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king
}

class PlayingCard {
  final Suit suit;
  final Rank rank;
  bool faceUp;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.faceUp = false,
  });
}

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final double width;
  final double height;

  const CardWidget({
    Key? key,
    required this.card,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: SvgPicture.asset(
        _getCardAssetPath(),
        fit: BoxFit.contain,
      ),
    );
  }

  String _getCardAssetPath() {
    if (!card.faceUp) {
      return 'assets/cards/blue.svg';
    }

    final suitName = card.suit.toString().split('.').last;
    final rankName = _getRankString();
    return 'assets/cards/$suitName/${suitName}_$rankName.svg';
  }

  String _getRankString() {
    switch (card.rank) {
      case Rank.ace:
        return 'ace';
      case Rank.jack:
        return 'jack';
      case Rank.queen:
        return 'queen';
      case Rank.king:
        return 'king';
      default:
        return (card.rank.index + 1).toString();
    }
  }
}
