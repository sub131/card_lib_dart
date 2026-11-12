import 'dart:convert';
import 'package:card_lib_dart/card_lib_dart.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  test('turn order validates participants and skips eliminated players', () {
    for (final players in [
      <String>[],
      ['a'],
      ['a', 'a'],
      ['a', ' '],
    ]) {
      expect(() => TurnOrder(players), throwsArgumentError);
    }
    expect(
      () => TurnOrder(['a', 'b'], startingPlayer: 'c'),
      throwsArgumentError,
    );
    final turns = TurnOrder(['a', 'b', 'c']);
    turns.requireTurn('a', 0);
    expect(() => turns.requireTurn('b', 0), throwsStateError);
    expect(() => turns.requireTurn('a', 1), throwsStateError);
    turns.advance(activePlayers: {'a', 'c'});
    expect(turns.currentPlayer, 'c');
    expect(turns.revision, 1);
    turns.advance(endTurn: false);
    expect(turns.currentPlayer, 'c');
    expect(turns.revision, 2);
    turns.advance(activePlayers: {'a'});
    expect(turns.currentPlayer, 'a');
    expect(() => turns.advance(activePlayers: {}), throwsArgumentError);
    expect(
      () => turns.advance(activePlayers: {'unknown'}),
      throwsArgumentError,
    );
    expect(turns.revision, 3);
    expect(() => turns.players.clear(), throwsUnsupportedError);
  });

  late CardPile a;
  late CardPile b;
  late CardPile stock;
  late CardPile discard;
  late CardTable table;
  setUp(() {
    a = pile('a', 'Ah Kh')
      ..deckVisiblity = CardVisibility.pileVisible
      ..topCardVisiblity = CardVisibility.pileVisible;
    b = pile('b', 'Ac Kc')
      ..deckVisiblity = CardVisibility.pileVisible
      ..topCardVisiblity = CardVisibility.pileVisible;
    stock = pile('stock', '2h 3h');
    discard = CardPile('discard')
      ..deckVisiblity = CardVisibility.visible
      ..topCardVisiblity = CardVisibility.visible;
    table = CardTable(
      players: ['a', 'b'],
      piles: {'a': a, 'b': b, 'stock': stock, 'discard': discard},
      owners: {'a': 'a', 'b': 'b'},
    );
  });
  void move(
    String actor,
    int rev,
    String from,
    String to,
    String id, {
    bool legal = true,
    bool endTurn = true,
  }) {
    table.move(
      playerId: actor,
      expectedRevision: rev,
      from: from,
      to: to,
      cardId: id,
      isLegal: (_) => legal,
      endTurn: endTurn,
    );
  }

  test(
    'views hide faces, metadata and identities from opponents and spectators',
    () {
      a.whatIsTopCard()!.metaData['private'] = 'secret';
      final own = table.viewFor('a');
      final other = table.viewFor('b');
      final spectator = table.viewFor(null);
      final ownPiles = own['piles'] as Map;
      expect((ownPiles['a'] as List).first['rankName'], 'ace');
      expect((ownPiles['a'] as List).first['id'], a.whatIsTopCard()!.id);
      expect((ownPiles['b'] as List).first, {'hidden': true});
      expect((ownPiles['stock'] as List).first, {'hidden': true});
      for (final view in [other, spectator]) {
        final hidden = (view['piles'] as Map)['a'] as List;
        expect(hidden, [
          {'hidden': true},
          {'hidden': true},
        ]);
        expect(jsonEncode(view), isNot(contains('secret')));
        expect(jsonEncode(view), isNot(contains(a.whatIsTopCard()!.id)));
      }
      expect(() => table.viewFor('stranger'), throwsArgumentError);
      // Detached result cannot mutate cards or metadata on the server.
      (ownPiles['a'] as List).first['metaData']['private'] = 'changed';
      expect(a.whatIsTopCard()!.metaData['private'], 'secret');
    },
  );
  test('special visibility modes fail closed, including for owners', () {
    a.whatIsTopCard()!.visibility = CardVisibility.special1;
    expect(((table.viewFor('a')['piles'] as Map)['a'] as List).first, {
      'hidden': true,
    });
  });
  test(
    'accepted move preserves card ID, reveals discard and advances revision',
    () {
      final card = a.whatIsTopCard()!;
      move('a', 0, 'a', 'discard', card.id);
      expect(a.length, 1);
      expect(discard.whatIsTopCard(), same(card));
      expect(table.revision, 1);
      expect(table.currentPlayer, 'b');
      expect(
        ((table.viewFor(null)['piles'] as Map)['discard'] as List).first['id'],
        card.id,
      );
      expect(
        () => move('a', 0, 'a', 'discard', a.whatIsTopCard()!.id),
        throwsStateError,
      );
      expect(table.revision, 1);
    },
  );
  test('invalid actions leave complete state and revision unchanged', () {
    final before = jsonEncode(table.viewFor('a'));
    final id = a.whatIsTopCard()!.id;
    expect(() => move('b', 0, 'a', 'discard', id), throwsStateError);
    expect(() => move('a', 1, 'a', 'discard', id), throwsStateError);
    expect(
      () => move('a', 0, 'b', 'discard', b.whatIsTopCard()!.id),
      throwsStateError,
    );
    expect(() => move('a', 0, 'a', 'discard', 'unknown'), throwsStateError);
    expect(() => move('a', 0, 'a', 'missing', id), throwsArgumentError);
    expect(() => move('a', 0, 'a', 'a', id), throwsArgumentError);
    expect(
      () => move('a', 0, 'a', 'discard', id, legal: false),
      throwsStateError,
    );
    expect(
      () => table.move(
        playerId: 'a',
        expectedRevision: 0,
        from: 'a',
        to: 'discard',
        cardId: id,
        isLegal: (_) => throw StateError('rule failure'),
      ),
      throwsStateError,
    );
    expect(jsonEncode(table.viewFor('a')), before);
    expect(discard.length, 0);
  });
  test(
    'shared piles require rules and support multiple actions in one turn',
    () {
      final id = stock.whatIsTopCard()!.id;
      move('a', 0, 'stock', 'a', id, endTurn: false);
      expect(table.currentPlayer, 'a');
      expect(table.revision, 1);
      expect(a.whatIsTopCard()!.visibility, CardVisibility.pileVisible);
      move('a', 1, 'a', 'discard', id);
      expect(table.currentPlayer, 'b');
      expect(table.revision, 2);
    },
  );
  test('table rejects aliased piles/cards and invalid ownership', () {
    expect(
      () => CardTable(players: ['a', 'b'], piles: {}),
      throwsArgumentError,
    );
    expect(
      () => CardTable(players: ['a', 'b'], piles: {'x': a, 'y': a}),
      throwsArgumentError,
    );
    b.addCard(a.whatIsTopCard()!);
    expect(
      () => CardTable(players: ['a', 'b'], piles: {'a': a, 'b': b}),
      throwsArgumentError,
    );
    expect(
      () => CardTable(
        players: ['a', 'b'],
        piles: {'a': a},
        owners: {'a': 'stranger'},
      ),
      throwsArgumentError,
    );
    expect(
      () => CardTable(
        players: ['a', 'b'],
        piles: {'a': a},
        owners: {'missing': 'a'},
      ),
      throwsArgumentError,
    );
  });
}
