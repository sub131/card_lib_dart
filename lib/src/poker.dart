import '../card_and_suit.dart';
import 'common_rules.dart';

enum PokerCategory {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
}

/// A larger value wins; suits never break a tie. A royal flush is an ace-high
/// straight flush. Kickers are ordered from most to least significant.
class PokerHand implements Comparable<PokerHand> {
  final PokerCategory category;
  final List<int> kickers;
  PokerHand._(this.category, Iterable<int> kickers)
    : kickers = List.unmodifiable(kickers);

  @override
  int compareTo(PokerHand other) {
    final categoryOrder = category.index.compareTo(other.category.index);
    if (categoryOrder != 0) return categoryOrder;
    for (var i = 0; i < kickers.length; i++) {
      final order = kickers[i].compareTo(other.kickers[i]);
      if (order != 0) return order;
    }
    return 0;
  }

  Map<String, Object> toJson() => {
    'category': category.name,
    'kickers': kickers,
  };
}

/// Standard high poker, with no wild cards or duplicate faces.
abstract final class Poker {
  /// Best five-card hand from five to seven cards (draw or stud showdown).
  static PokerHand evaluate(Iterable<Card> cards) {
    final hand = cards.toList();
    if (hand.length < 5 || hand.length > 7) {
      throw ArgumentError('Poker requires five to seven cards');
    }
    _validate(hand);
    return _best(_choose(hand, 5));
  }

  /// Exactly two hole cards, with three to five shared community cards.
  static PokerHand texasHoldem(Iterable<Card> hole, Iterable<Card> board) {
    final privateCards = hole.toList();
    final shared = board.toList();
    if (privateCards.length != 2 || shared.length < 3 || shared.length > 5) {
      throw ArgumentError(
        'Holdem requires two hole and three to five board cards',
      );
    }
    return evaluate([...privateCards, ...shared]);
  }

  /// Four-card Omaha: must use exactly two hole and three community cards.
  static PokerHand omaha(Iterable<Card> hole, Iterable<Card> board) {
    final privateCards = hole.toList();
    final shared = board.toList();
    if (privateCards.length != 4 || shared.length < 3 || shared.length > 5) {
      throw ArgumentError(
        'Omaha requires four hole and three to five board cards',
      );
    }
    _validate([...privateCards, ...shared]);
    return _best([
      for (final h in _choose(privateCards, 2))
        for (final b in _choose(shared, 3)) [...h, ...b],
    ]);
  }

  static void _validate(List<Card> cards) {
    final faces = <String>{};
    for (final card in cards) {
      standardRank(card);
      if (!faces.add('${card.suit.name}/${card.rankName}')) {
        throw ArgumentError('Duplicate card face in poker hand');
      }
    }
  }

  static Iterable<List<Card>> _choose(
    List<Card> cards,
    int count, [
    int start = 0,
    List<Card> prefix = const [],
  ]) sync* {
    if (count == 0) {
      yield prefix;
      return;
    }
    for (var i = start; i <= cards.length - count; i++) {
      yield* _choose(cards, count - 1, i + 1, [...prefix, cards[i]]);
    }
  }

  static PokerHand _best(Iterable<List<Card>> candidates) {
    PokerHand? best;
    for (final cards in candidates) {
      final value = _five(cards);
      if (best == null || value.compareTo(best) > 0) best = value;
    }
    return best!;
  }

  static PokerHand _five(List<Card> cards) {
    final ranks = cards.map((c) => standardRank(c, aceHigh: true)).toList()
      ..sort((a, b) => b.compareTo(a));
    final counts = <int, int>{};
    for (final rank in ranks) {
      counts[rank] = (counts[rank] ?? 0) + 1;
    }
    final groups = counts.keys.toList()
      ..sort((a, b) {
        final sizeOrder = counts[b]!.compareTo(counts[a]!);
        return sizeOrder != 0 ? sizeOrder : b.compareTo(a);
      });
    final flush = cards.every((c) => c.suit.name == cards.first.suit.name);
    var straightHigh = 0;
    if (counts.length == 5) {
      if (ranks.first - ranks.last == 4) straightHigh = ranks.first;
      if (ranks.join(',') == '14,5,4,3,2') straightHigh = 5;
    }
    if (flush && straightHigh > 0) {
      return PokerHand._(PokerCategory.straightFlush, [straightHigh]);
    }
    if (counts[groups[0]] == 4) {
      return PokerHand._(PokerCategory.fourOfAKind, groups);
    }
    if (counts[groups[0]] == 3 && counts[groups[1]] == 2) {
      return PokerHand._(PokerCategory.fullHouse, groups);
    }
    if (flush) return PokerHand._(PokerCategory.flush, ranks);
    if (straightHigh > 0) {
      return PokerHand._(PokerCategory.straight, [straightHigh]);
    }
    if (counts[groups[0]] == 3) {
      return PokerHand._(PokerCategory.threeOfAKind, groups);
    }
    if (counts[groups[0]] == 2 && counts[groups[1]] == 2) {
      return PokerHand._(PokerCategory.twoPair, groups);
    }
    if (counts[groups[0]] == 2) {
      return PokerHand._(PokerCategory.onePair, groups);
    }
    return PokerHand._(PokerCategory.highCard, ranks);
  }
}
