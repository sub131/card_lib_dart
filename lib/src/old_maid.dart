import 'dart:math';

import '../common_decks.dart';
import '../pile_and_deck.dart';
import 'common_rules.dart';
import 'multiplayer.dart';

/// Standard Old Maid: 51 cards (queen of clubs removed), rank pairs discarded,
/// and each player draws blindly from the next clockwise nonempty hand.
/// The last player holding the unmatched queen loses. Server-side use only.
class OldMaidGame {
  final TurnOrder _turns;
  final Map<String, CardPile> _hands;
  final CardPile _discard;
  final Random _random;

  OldMaidGame._(this._turns, this._hands, this._discard, this._random);

  factory OldMaidGame(Iterable<String> players, {Random? random}) {
    final turns = TurnOrder(players);
    if (turns.players.length > 10) {
      throw ArgumentError('Old Maid supports two to ten players');
    }
    final rng = random ?? Random.secure();
    final deck = DefaultCardDeck();
    deck.removeFirstMatchingCard(
      suit: DefaultCardDeck.clubs,
      rankName: 'queen',
    );
    deck.shuffle(rng);
    final hands = {
      for (final player in turns.players) player: CardPile(player),
    };
    final discard = CardPile('discard');
    deck.dealCards(hands.values.toList(), (51 / hands.length).ceil());
    for (final hand in hands.values) {
      MatchingCards.discardPairs(hand, discard);
    }
    final firstActive = hands.entries.firstWhere((e) => e.value.length > 0).key;
    return OldMaidGame._(
      TurnOrder(turns.players, startingPlayer: firstActive),
      hands,
      discard,
      rng,
    );
  }

  Set<String> get _active => {
    for (final entry in _hands.entries)
      if (entry.value.length > 0) entry.key,
  };
  int get revision => _turns.revision;
  bool get isFinished => _active.length == 1;
  String? get loser => isFinished ? _active.single : null;
  String? get currentPlayer => isFinished ? null : _turns.currentPlayer;
  int get discardedCardCount => _discard.length;

  String? get drawFromPlayer {
    if (isFinished) return null;
    final players = _turns.players;
    var index = players.indexOf(_turns.currentPlayer);
    do {
      index = (index + 1) % players.length;
    } while (_hands[players[index]]!.length == 0);
    return players[index];
  }

  /// Index zero is the top of the opponent's hidden hand. The hand is shuffled
  /// after each draw so exposed card positions cannot be tracked across turns.
  void draw({
    required String playerId,
    required int expectedRevision,
    required int cardIndex,
  }) {
    if (isFinished) throw StateError('Game has finished');
    _turns.requireTurn(playerId, expectedRevision);
    final source = _hands[drawFromPlayer]!;
    if (cardIndex < 0 || cardIndex >= source.length) {
      throw RangeError.index(cardIndex, source.cards);
    }
    final hand = _hands[playerId]!;
    source.moveCardToPile(hand, cardIndex);
    MatchingCards.discardPairs(hand, _discard);
    source.shuffle(_random);
    hand.shuffle(_random);
    _turns.advance(activePlayers: _active);
  }

  /// Detached JSON-compatible view. Only the viewer's own hand is disclosed.
  Map<String, Object?> viewFor(String? viewer) {
    if (viewer != null && !_hands.containsKey(viewer)) {
      throw ArgumentError('Unknown viewer');
    }
    return {
      'game': 'oldMaid',
      'revision': revision,
      'players': _turns.players,
      'currentPlayer': currentPlayer,
      'drawFromPlayer': drawFromPlayer,
      'isFinished': isFinished,
      'loser': loser,
      'discardedCardCount': discardedCardCount,
      'hands': {
        for (final entry in _hands.entries)
          entry.key: [
            for (final card in entry.value.cards)
              if (entry.key == viewer)
                card.toJson()
              else
                <String, Object?>{'hidden': true},
          ],
      },
    };
  }
}
