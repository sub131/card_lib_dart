import 'dart:math';
import 'package:card_lib_dart/card_lib_dart.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  test('ace high/low and jokers compare correctly', () {
    final hand = cards('Ah Kh 2c');
    expect(DefaultCardDeck.compareCards(hand[0], hand[1]), greaterThan(0));
    expect(
      DefaultCardDeck.compareCards(hand[0], hand[2], aceHigh: false),
      lessThan(0),
    );
    final joker = DefaultCardDeckWithJokers().whatIsTopCard()!;
    expect(
      DefaultCardDeckWithJokers.compareCards(joker, hand[0]),
      greaterThan(0),
    );
    expect(DefaultCardDeckWithJokers.compareCards(hand[1], joker), lessThan(0));
    expect(
      DefaultCardDeckWithJokers.compareCards(joker, hand[1], aceHigh: false),
      greaterThan(0),
    );
  });
  test('multi-decks contain distinct objects and IDs, and duplicate fully', () {
    for (final deck in [
      DefaultCardDeck.createMultipleDecks(3),
      DefaultCardDeckWithJokers.createMultipleDecks(3),
    ]) {
      final size = deck is DefaultCardDeckWithJokers ? 162 : 156;
      expect(deck.length, size);
      expect(deck.addedCards.length, size);
      expect(deck.cards.toSet().length, size);
      expect(deck.cards.map((c) => c.id).toSet().length, size);
      final duplicate = deck.duplicate();
      expect(duplicate.length, size);
      expect(
        duplicate.cards
            .map((c) => c.id)
            .toSet()
            .intersection(deck.cards.map((c) => c.id).toSet()),
        isEmpty,
      );
      expect(deck.cards.where((c) => c.rankName == 'ace').length, 12);
    }
    expect(() => DefaultCardDeck.createMultipleDecks(0), throwsArgumentError);
    expect(
      () => DefaultCardDeckWithJokers.createMultipleDecks(-1),
      throwsArgumentError,
    );
  });
  test('duplicate metadata and visibility are independent', () {
    final deck = DefaultCardDeck();
    deck.whatIsTopCard()!.metaData['texture'] = 'king.png';
    final copy = deck.duplicate();
    copy.whatIsTopCard()!.metaData['texture'] = 'other.png';
    copy.topCardVisiblity = CardVisibility.visible;
    expect(deck.whatIsTopCard()!.metaData['texture'], 'king.png');
    expect(deck.whatIsTopCard()!.visibility, CardVisibility.hidden);
    expect(copy.whatIsTopCard()!.visibility, CardVisibility.visible);
  });
  test('rejects every self-transfer without changing cards', () {
    final source = pile('source', 'Ah Kc');
    final before = source.cards;
    for (final action in <void Function()>[
      () => source.moveTopCardToPile(source),
      () => source.moveCardToPile(source, 0),
      () => source.moveCardsToPile(source),
      () => source.moveFirstMatchingCardToPile(source, rank: 1),
      () => source.moveAllMatchingCardsToPile(source, rank: 1),
      () => source.dealCardsToPile(source, 10),
      () => source.dealCards([CardPile('other'), source], 1),
    ]) {
      expect(action, throwsArgumentError);
      expect(source.cards, before);
    }
  });
  test('empty deal targets terminate and duplicates fail before moving', () {
    final source = pile('source', 'Ah Kc 2s');
    final target = CardPile('target');
    expect(source.dealCards([], 2), 0);
    expect(() => source.dealCards([target, target], 1), throwsArgumentError);
    expect(source.length, 3);
    expect(target.length, 0);
    expect(source.dealCards([target], 0), 0);
    expect(source.dealCards([target], -1), 0);
    expect(source.dealCards([target], 100), 3);
  });
  test(
    'reorder updates top-only visibility and seeded shuffle is reproducible',
    () {
      final source = pile('source', 'Ah Kc 2s')
        ..topCardVisiblity = CardVisibility.visible;
      void check() {
        expect(source.cards.first.visibility, CardVisibility.visible);
        expect(
          source.cards
              .skip(1)
              .every((c) => c.visibility == CardVisibility.hidden),
          isTrue,
        );
      }

      check();
      source.reverse();
      check();
      source.shuffle(Random(44));
      check();
      final a = DefaultCardDeck()..shuffle(Random(77));
      final b = DefaultCardDeck()..shuffle(Random(77));
      expect(a.cards.map((c) => c.name), b.cards.map((c) => c.name));
    },
  );
  test('suit number lookup is one-based like suitNum and suitNumber', () {
    // A unique suit avoids changing the legacy global registry in other tests.
    final suit = Suit('lookup-regression');
    expect(Suit.suitName(suit.suitNum), suit.name);
    expect(Suit.suitNumber(suit.name), suit.suitNum);
    expect(Suit.suitName(0), isNull);
  });
}
