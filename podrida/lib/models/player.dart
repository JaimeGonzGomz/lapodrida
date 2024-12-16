import 'card.dart';

class Player {
  final String id;
  final String name;
  List<PlayingCard> hand;

  Player({
    required this.id,
    required this.name,
    List<PlayingCard>? hand,
  }) : hand = hand ?? [];
}
