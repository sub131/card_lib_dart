import 'package:card_lib_dart/card_lib_dart.dart';

List<Card> cards(String notation) {
  final deck = DefaultCardDeck();
  const ranks = {
    'A': 'ace',
    '2': 'two',
    '3': 'three',
    '4': 'four',
    '5': 'five',
    '6': 'six',
    '7': 'seven',
    '8': 'eight',
    '9': 'nine',
    'T': 'ten',
    'J': 'jack',
    'Q': 'queen',
    'K': 'king',
  };
  final suits = {
    'h': DefaultCardDeck.hearts,
    'c': DefaultCardDeck.clubs,
    's': DefaultCardDeck.spades,
    'd': DefaultCardDeck.diamonds,
  };
  return [
    for (final code in notation.split(' '))
      deck.cardByRankName(suits[code[1]]!, ranks[code[0]]!)!,
  ];
}

CardPile pile(String name, String notation) {
  final result = CardPile(name);
  for (final card in cards(notation).reversed) {
    result.addCard(card);
  }
  return result;
}
