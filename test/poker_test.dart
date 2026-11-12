import 'package:card_lib_dart/card_lib_dart.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  final examples = {
    PokerCategory.highCard: 'Ah Kc 9d 6s 3h',
    PokerCategory.onePair: 'Ah Ac 9d 6s 3h',
    PokerCategory.twoPair: 'Ah Ac 9d 9s 3h',
    PokerCategory.threeOfAKind: 'Ah Ac Ad 6s 3h',
    PokerCategory.straight: '9h 8c 7d 6s 5h',
    PokerCategory.flush: 'Ah Jh 9h 6h 3h',
    PokerCategory.fullHouse: 'Ah Ac Ad 6s 6h',
    PokerCategory.fourOfAKind: 'Ah Ac Ad As 3h',
    PokerCategory.straightFlush: 'Ah Kh Qh Jh Th',
  };
  for (final entry in examples.entries) {
    test('recognizes ${entry.key.name}', () {
      expect(Poker.evaluate(cards(entry.value)).category, entry.key);
    });
  }
  test('all categories rank in standard order', () {
    final hands = examples.values.map((s) => Poker.evaluate(cards(s))).toList();
    for (var i = 1; i < hands.length; i++) {
      expect(hands[i].compareTo(hands[i - 1]), greaterThan(0));
      expect(hands[i - 1].compareTo(hands[i]), lessThan(0));
    }
  });
  final tiebreaks = [
    ['Ah Kc 9d 6s 4h', 'Ah Kc 9d 6s 3h'], // fifth high-card kicker
    ['Ah Ac Kd 9s 5h', 'Ah Ac Kd 9s 4h'], // pair kicker
    ['Ah Ac Kd Ks 3h', 'Ah Ac Qd Qs Kh'], // second pair
    ['Ah Ac Kd Ks 4h', 'Ah Ac Kd Ks 3h'], // two-pair kicker
    ['Ah Ac Ad Ks 4h', 'Ah Ac Ad Ks 3h'], // trip kicker
    ['6h 5c 4d 3s 2h', 'Ah 2c 3d 4s 5h'], // wheel low
    ['Ah Jh 9h 6h 4h', 'Ah Jh 9h 6h 3h'], // fifth flush kicker
    ['Ah Ac Ad Ks Kh', 'Ah Ac Ad Qs Qh'], // full-house pair
    ['Kh Kc Kd Qs Qh', 'Qh Qc Qd As Ah'], // full-house trips
    ['Ah Ac Ad As Kh', 'Ah Ac Ad As Qh'], // quads kicker
    ['Kh Qh Jh Th 9h', 'Qh Jh Th 9h 8h'], // straight flush high
  ];
  for (var i = 0; i < tiebreaks.length; i++) {
    test('tie breaker $i', () {
      final pair = tiebreaks[i];
      expect(
        Poker.evaluate(
          cards(pair[0]),
        ).compareTo(Poker.evaluate(cards(pair[1]))),
        greaterThan(0),
      );
    });
  }
  test('suits do not break ties and kickers cannot be mutated', () {
    final a = Poker.evaluate(cards('Ah Kc 9d 6s 3h'));
    final b = Poker.evaluate(cards('As Kd 9h 6c 3s'));
    expect(a.compareTo(b), 0);
    expect(() => a.kickers.clear(), throwsUnsupportedError);
    expect(a.toJson()['category'], 'highCard');
  });
  test('six/seven cards choose best five, including two triples', () {
    expect(Poker.evaluate(cards('Ah Ac Ad Kh Kc Kd 2s')).kickers, [14, 13]);
    expect(Poker.evaluate(cards('Ah Ac Ad Kh Kc Kd')).kickers, [14, 13]);
    expect(Poker.evaluate(cards('Ah 2c 3d 4s 5h 6d 9s')).kickers, [6]);
    expect(
      Poker.evaluate(cards('Ah Kh Qh Jh Th 2c 3d')).category,
      PokerCategory.straightFlush,
    );
  });
  test('Holdem may play only the board and tie with another player', () {
    final board = cards('Ah Kh Qh Jh Th');
    final a = Poker.texasHoldem(cards('2c 3d'), board);
    final b = Poker.texasHoldem(cards('4s 5d'), board);
    expect(a.category, PokerCategory.straightFlush);
    expect(a.compareTo(b), 0);
    expect(
      Poker.texasHoldem(cards('Ac Ad'), cards('Ah Kd Qs')).category,
      PokerCategory.threeOfAKind,
    );
  });
  test('Omaha must use exactly two hole and three board cards', () {
    final hole = cards('Ah 2c 3d 4s');
    final board = cards('Kh Qh Jh Th 9h');
    expect(Poker.omaha(hole, board).category, PokerCategory.highCard);
    expect(
      Poker.omaha(cards('8h 7h 2d 3s'), board).category,
      PokerCategory.straightFlush,
    );
    expect(
      Poker.omaha(cards('Ac Ad As 2d'), cards('Ah Kh Kd')).category,
      PokerCategory.fullHouse,
    ); // cannot use three pocket aces
  });
  test(
    'rejects unsupported counts, duplicate faces, custom cards and jokers',
    () {
      expect(() => Poker.evaluate(cards('Ah Kc 9d 6s')), throwsArgumentError);
      expect(
        () => Poker.evaluate(cards('Ah Kc 9d 6s 3h 2c 4d 5s')),
        throwsArgumentError,
      );
      expect(
        () => Poker.evaluate(cards('Ah Ah 9d 6s 3h')),
        throwsArgumentError,
      );
      final hand = cards('Ah Kc 9d 6s 3h');
      hand[0] = DefaultCardDeckWithJokers().whatIsTopCard()!;
      expect(() => Poker.evaluate(hand), throwsArgumentError);
      hand[0] = Card(Suit('poker-custom'), 'wizard', 'wizard');
      expect(() => Poker.evaluate(hand), throwsArgumentError);
      expect(
        () => Poker.texasHoldem(cards('Ah'), cards('Kh Qh Jh')),
        throwsArgumentError,
      );
      expect(
        () => Poker.texasHoldem(cards('Ah Kh'), cards('Qh Jh')),
        throwsArgumentError,
      );
      expect(
        () => Poker.omaha(cards('Ah Kh'), cards('Qh Jh Th')),
        throwsArgumentError,
      );
      expect(
        () => Poker.omaha(cards('Ah Kh 2s 3s'), cards('Ah Jh Th')),
        throwsArgumentError,
      );
    },
  );
}
