import '../card_and_suit.dart';
import '../pile_and_deck.dart';

/// Server-side turn and optimistic concurrency guard. Authenticate a connection
/// before using its player ID; never trust a player ID supplied by a client.
class TurnOrder {
  final List<String> players;
  int _index = 0;
  int _revision = 0;
  int get revision => _revision;
  String get currentPlayer => players[_index];

  TurnOrder(Iterable<String> players, {String? startingPlayer})
    : players = List.unmodifiable(players) {
    if (this.players.length < 2 ||
        this.players.any((p) => p.trim().isEmpty) ||
        this.players.toSet().length != this.players.length) {
      throw ArgumentError('Provide at least two distinct, nonempty player IDs');
    }
    if (startingPlayer != null) {
      _index = this.players.indexOf(startingPlayer);
      if (_index < 0) {
        throw ArgumentError('Starting player must be a participant');
      }
    }
  }

  void requireTurn(String playerId, int expectedRevision) {
    if (expectedRevision != revision) throw StateError('Stale game revision');
    if (playerId != currentPlayer) throw StateError('Not this player\'s turn');
  }

  /// Advances clockwise, skipping inactive players. One accepted action raises
  /// revision exactly once. Validation errors leave state unchanged.
  void advance({Set<String>? activePlayers, bool endTurn = true}) {
    final active = activePlayers ?? players.toSet();
    if (active.isEmpty || !active.every(players.contains)) {
      throw ArgumentError(
        'Active players must be a nonempty subset of players',
      );
    }
    if (endTurn || !active.contains(currentPlayer)) {
      do {
        _index = (_index + 1) % players.length;
      } while (!active.contains(currentPlayer));
    }
    _revision++;
  }
}

/// A trusted server's rule validator receives the proposed move before mutation.
class CardMove {
  final String playerId;
  final String from;
  final String to;
  final Card card;
  const CardMove(this.playerId, this.from, this.to, this.card);
}

/// Transport-independent authoritative table. Piles and rule callbacks belong
/// exclusively to the trusted server. Serialize [viewFor] to clients, never the
/// underlying piles. Apply actions serially within one game instance.
class CardTable {
  final TurnOrder _turns;
  final Map<String, CardPile> _piles;
  final Map<String, String> _owners;
  int get revision => _turns.revision;
  String get currentPlayer => _turns.currentPlayer;

  CardTable({
    required Iterable<String> players,
    required Map<String, CardPile> piles,
    Map<String, String> owners = const {},
  }) : _turns = TurnOrder(players),
       _piles = Map.unmodifiable(piles),
       _owners = Map.unmodifiable(owners) {
    if (_piles.isEmpty ||
        _piles.keys.any((k) => k.trim().isEmpty) ||
        _piles.values.toSet().length != _piles.length ||
        _owners.entries.any(
          (e) =>
              !_piles.containsKey(e.key) || !_turns.players.contains(e.value),
        )) {
      throw ArgumentError('Invalid piles or ownership');
    }
    final ids = <String>{};
    for (final pile in _piles.values) {
      for (final card in pile.cards) {
        if (!ids.add(card.id)) {
          throw ArgumentError('A card occupies multiple slots');
        }
      }
    }
  }

  /// Requires a game-specific legality check, even for unowned draw/discard
  /// piles. Moving another player's private cards is always forbidden here.
  void move({
    required String playerId,
    required int expectedRevision,
    required String from,
    required String to,
    required String cardId,
    required bool Function(CardMove move) isLegal,
    bool endTurn = true,
  }) {
    _turns.requireTurn(playerId, expectedRevision);
    final source = _piles[from];
    final target = _piles[to];
    if (source == null || target == null || from == to) {
      throw ArgumentError('Use different, known piles');
    }
    if (_owners[from] != null && _owners[from] != playerId) {
      throw StateError('Cannot move another player\'s cards');
    }
    final index = source.cards.indexWhere((c) => c.id == cardId);
    if (index < 0) throw StateError('Card is not in the source pile');
    final card = source.whatIsCard(index)!;
    if (!isLegal(CardMove(playerId, from, to, card))) {
      throw StateError('Illegal game move');
    }
    source.moveCardToPile(target, index);
    _turns.advance(endTurn: endTurn);
  }

  /// Null viewer means spectator. Hidden cards contain no face, ID, or metadata.
  /// Special visibility modes are hidden until the game explicitly reveals them.
  Map<String, Object?> viewFor(String? viewer) {
    if (viewer != null && !_turns.players.contains(viewer)) {
      throw ArgumentError('Unknown viewer');
    }
    return {
      'revision': revision,
      'currentPlayer': currentPlayer,
      'players': _turns.players,
      'piles': {
        for (final entry in _piles.entries)
          entry.key: [
            for (final card in entry.value.cards)
              if (card.visibility == CardVisibility.visible ||
                  (card.visibility == CardVisibility.pileVisible &&
                      viewer != null &&
                      _owners[entry.key] == viewer))
                card.toJson()
              else
                <String, Object?>{'hidden': true},
          ],
      },
    };
  }
}
