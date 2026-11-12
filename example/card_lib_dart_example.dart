import 'dart:convert';
import 'dart:math';
import 'package:card_lib_dart/card_lib_dart.dart';

void main() {
  final deck = DefaultCardDeck();
  Card card(Suit suit, String rank) => deck.cardByRankName(suit, rank)!;
  final showdown = Poker.texasHoldem(
    [card(DefaultCardDeck.hearts, 'ace'), card(DefaultCardDeck.hearts, 'king')],
    [
      card(DefaultCardDeck.hearts, 'queen'),
      card(DefaultCardDeck.hearts, 'jack'),
      card(DefaultCardDeck.hearts, 'ten'),
      card(DefaultCardDeck.clubs, 'two'),
      card(DefaultCardDeck.spades, 'three'),
    ],
  );
  print(jsonEncode(showdown.toJson()));

  // A real server uses the secure default RNG. Seeded RNG is for reproducible
  // demos/tests; it should not be used for competitive online games.
  final game = OldMaidGame(['alice', 'bob', 'carol'], random: Random(42));
  while (!game.isFinished) {
    game.draw(
      playerId: game.currentPlayer!,
      expectedRevision: game.revision,
      cardIndex: 0,
    );
  }
  print('Old Maid loser: ${game.loser} after ${game.revision} turns');
  print(jsonEncode(game.viewFor(null)));
}
