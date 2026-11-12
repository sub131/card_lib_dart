import '../card_and_suit.dart';
import '../pile_and_deck.dart';

const _ranks = [
  'ace',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'jack',
  'queen',
  'king',
];
const _suits = ['hearts', 'clubs', 'spades', 'diamonds'];

/// Canonical standard-card rank, independent of the global Suit registry or
/// the order in which a custom deck registered rank names. Jokers are rejected.
int standardRank(Card card, {bool aceHigh = false}) {
  final rank = _ranks.indexOf(card.rankName) + 1;
  if (rank == 0 || !_suits.contains(card.suit.name)) {
    throw ArgumentError('Expected a standard playing card: ${card.name}');
  }
  return aceHigh && rank == 1 ? 14 : rank;
}

class BlackjackValue {
  final int total;
  final bool isSoft;
  final bool isBlackjack;
  bool get isBust => total > 21;
  const BlackjackValue._(this.total, this.isSoft, this.isBlackjack);
}

abstract final class Blackjack {
  /// Aces count as eleven only when doing so avoids busting.
  static BlackjackValue evaluate(Iterable<Card> cards) {
    var total = 0;
    var aces = 0;
    var count = 0;
    for (final card in cards) {
      final rank = standardRank(card);
      total += rank > 10 ? 10 : rank;
      if (rank == 1) aces++;
      count++;
    }
    final soft = aces > 0 && total + 10 <= 21;
    if (soft) total += 10;
    return BlackjackValue._(total, soft, count == 2 && total == 21);
  }
}

/// Rank matching helpers also work with custom decks (matching rank names).
abstract final class MatchingCards {
  /// Moves pairs into discard and returns the number of pairs removed.
  static int discardPairs(CardPile hand, CardPile discard) =>
      discardBooks(hand, discard, bookSize: 2);

  /// Go Fish uses four-card books; other matching games can choose a size.
  static int discardBooks(CardPile hand, CardPile discard, {int bookSize = 4}) {
    if (identical(hand, discard) || bookSize < 2) {
      throw ArgumentError('Use distinct piles and a book size of at least two');
    }
    final groups = <String, List<Card>>{};
    for (final card in hand.cards) {
      groups.putIfAbsent(card.rankName, () => []).add(card);
    }
    var removed = 0;
    for (final group in groups.values) {
      final count = group.length ~/ bookSize * bookSize;
      for (final card in group.take(count)) {
        hand.moveCardToPile(discard, hand.cards.indexOf(card));
      }
      removed += count ~/ bookSize;
    }
    return removed;
  }
}

/// Building blocks for Whist, Hearts, and Spades. Scoring, bidding and special
/// opening restrictions remain the responsibility of the specific game.
abstract final class TrickTaking {
  static List<Card> legalPlays(Iterable<Card> hand, {Suit? leadSuit}) {
    final cards = hand.toList();
    final following = cards
        .where((c) => c.suit.name == leadSuit?.name)
        .toList();
    return List.unmodifiable(following.isEmpty ? cards : following);
  }

  /// Cards are in play order. Highest trump wins, otherwise highest lead suit.
  static int winnerIndex(Iterable<Card> trick, {Suit? trump}) {
    final cards = trick.toList();
    if (cards.isEmpty) throw ArgumentError('A trick cannot be empty');
    for (final card in cards) {
      standardRank(card);
    }
    var best = 0;
    int strength(Card c) =>
        (c.suit.name == trump?.name
            ? 100
            : c.suit.name == cards.first.suit.name
            ? 50
            : 0) +
        standardRank(c, aceHigh: true);
    for (var i = 1; i < cards.length; i++) {
      if (strength(cards[i]) > strength(cards[best])) best = i;
    }
    return best;
  }
}
