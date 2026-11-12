import 'package:card_lib_dart/card_lib_dart.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  test('Blackjack scores multiple aces, soft/hard totals and naturals', () {
    expect(Blackjack.evaluate([]).total, 0);
    final soft = Blackjack.evaluate(cards('Ah Ac 9d'));
    expect(soft.total, 21);
    expect(soft.isSoft, isTrue);
    expect(soft.isBlackjack, isFalse);
    final hard = Blackjack.evaluate(cards('Ah Ac Ad 9d'));
    expect(hard.total, 12);
    expect(hard.isSoft, isFalse);
    expect(Blackjack.evaluate(cards('Ah Kh')).isBlackjack, isTrue);
    expect(Blackjack.evaluate(cards('Kh Qd 2s')).isBust, isTrue);
    expect(Blackjack.evaluate(cards('Kh Qd')).total, 20);
    expect(
      () => Blackjack.evaluate(DefaultCardDeckWithJokers().cards),
      throwsArgumentError,
    );
  });
  test('rank pairs remove two out of three and all four out of four', () {
    final hand = pile('hand', 'Ah Ac Ad Kh Kc Kd Ks 2h');
    final discard = CardPile('discard');
    expect(MatchingCards.discardPairs(hand, discard), 3);
    expect(hand.length, 2);
    expect(hand.cards.map((c) => c.rankName), containsAll(['ace', 'two']));
    expect(discard.length, 6);
    expect(MatchingCards.discardPairs(hand, discard), 0);
    expect(() => MatchingCards.discardPairs(hand, hand), throwsArgumentError);
  });
  test('Go Fish books remove only complete four-card ranks', () {
    final hand = pile('hand', 'Ah Ac Ad As Kh Kc Kd');
    final discard = CardPile('books');
    expect(MatchingCards.discardBooks(hand, discard), 1);
    expect(hand.length, 3);
    expect(discard.length, 4);
    expect(
      () => MatchingCards.discardBooks(hand, discard, bookSize: 1),
      throwsArgumentError,
    );
  });
  test('matching supports custom deck names, not accidental numeric ranks', () {
    final deck = Deck('custom', {
      Suit('red-matches'): ['cat', 'dog'],
      Suit('blue-matches'): ['dog', 'cat'],
    });
    expect(MatchingCards.discardPairs(deck, CardPile('discard')), 2);
    expect(deck.length, 0);
  });
  test('trick play must follow suit when possible', () {
    final hand = cards('Ah Kc 2h');
    expect(TrickTaking.legalPlays(hand, leadSuit: DefaultCardDeck.hearts), [
      hand[0],
      hand[2],
    ]);
    expect(
      TrickTaking.legalPlays(hand, leadSuit: DefaultCardDeck.spades),
      hand,
    );
    expect(TrickTaking.legalPlays(hand), hand);
    expect(
      TrickTaking.legalPlays([], leadSuit: DefaultCardDeck.hearts),
      isEmpty,
    );
  });
  test('lead suit and trump determine a trick winner with ace high', () {
    final trick = cards('Kh Ac 2s Ah');
    expect(TrickTaking.winnerIndex(trick), 3);
    expect(TrickTaking.winnerIndex(trick, trump: DefaultCardDeck.spades), 2);
    expect(
      TrickTaking.winnerIndex(cards('2s As Ks'), trump: DefaultCardDeck.spades),
      1,
    );
    expect(() => TrickTaking.winnerIndex([]), throwsArgumentError);
  });
}
