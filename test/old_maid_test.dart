import 'dart:convert';
import 'dart:math';
import 'package:card_lib_dart/card_lib_dart.dart';
import 'package:test/test.dart';

void main() {
  test('validates player count and viewer', () {
    expect(() => OldMaidGame(['a']), throwsArgumentError);
    expect(() => OldMaidGame(['a', 'a']), throwsArgumentError);
    expect(
      () => OldMaidGame(List.generate(11, (i) => '$i')),
      throwsArgumentError,
    );
    final game = OldMaidGame(['a', 'b'], random: Random(10));
    expect(() => game.viewFor('unknown'), throwsArgumentError);
  });
  test('wrong turn, stale actions and invalid card index are atomic', () {
    final game = OldMaidGame(['a', 'b', 'c'], random: Random(11));
    final before = jsonEncode(game.viewFor(game.currentPlayer));
    expect(
      () => game.draw(
        playerId: game.drawFromPlayer!,
        expectedRevision: 0,
        cardIndex: 0,
      ),
      throwsStateError,
    );
    expect(
      () => game.draw(
        playerId: game.currentPlayer!,
        expectedRevision: 1,
        cardIndex: 0,
      ),
      throwsStateError,
    );
    for (final index in [-1, 1000]) {
      expect(
        () => game.draw(
          playerId: game.currentPlayer!,
          expectedRevision: 0,
          cardIndex: index,
        ),
        throwsRangeError,
      );
    }
    expect(jsonEncode(game.viewFor(game.currentPlayer)), before);
    game.draw(playerId: game.currentPlayer!, expectedRevision: 0, cardIndex: 0);
    expect(game.revision, 1);
    expect(
      () => game.draw(
        playerId: game.currentPlayer!,
        expectedRevision: 0,
        cardIndex: 0,
      ),
      throwsStateError,
    );
  });
  test(
    'same shuffle seed gives same starting faces independently of card IDs',
    () {
      final a = OldMaidGame(['a', 'b', 'c'], random: Random(22));
      final b = OldMaidGame(['a', 'b', 'c'], random: Random(22));
      for (final player in ['a', 'b', 'c']) {
        List<String> faces(OldMaidGame game) =>
            (((game.viewFor(player)['hands'] as Map)[player]) as List)
                .map((c) => c['name'] as String)
                .toList();
        expect(faces(a), faces(b));
      }
    },
  );
  for (final playerCount in [2, 3, 4, 6, 10]) {
    test(
      'completes 20 seeded $playerCount-player games with conserved cards',
      () {
        for (var seed = 0; seed < 20; seed++) {
          final players = List.generate(playerCount, (i) => 'player$i');
          final game = OldMaidGame(players, random: Random(seed));
          var actions = 0;
          expect(game.revision, 0);
          while (true) {
            final spectatorHands = game.viewFor(null)['hands'] as Map;
            var count = game.discardedCardCount;
            final ids = <String>{};
            for (final player in players) {
              final hidden = spectatorHands[player] as List;
              final own =
                  (game.viewFor(player)['hands'] as Map)[player] as List;
              expect(hidden.length, own.length);
              expect(
                hidden.every((c) => jsonEncode(c) == '{"hidden":true}'),
                isTrue,
              );
              count += own.length;
              // No pair remains after setup or a draw, and no physical card is
              // duplicated across hands. The removed queen never enters play.
              final ranks = <String>{};
              for (final card in own) {
                expect(ranks.add(card['rankName'] as String), isTrue);
                expect(ids.add(card['id'] as String), isTrue);
                expect(card['name'], isNot('queen of clubs'));
              }
            }
            expect(count, 51);
            expect(game.revision, actions);
            if (game.isFinished) break;
            final sourceCount =
                (spectatorHands[game.drawFromPlayer] as List).length;
            expect(sourceCount, greaterThan(0));
            expect((spectatorHands[game.currentPlayer] as List), isNotEmpty);
            expect(game.currentPlayer, isNot(game.drawFromPlayer));
            final actor = game.currentPlayer!;
            final rev = game.revision;
            game.draw(
              playerId: actor,
              expectedRevision: rev,
              cardIndex: actions % sourceCount,
            );
            actions++;
            expect(actions, lessThan(10000), reason: 'seed=$seed');
          }
          expect(game.currentPlayer, isNull);
          expect(game.drawFromPlayer, isNull);
          expect(game.discardedCardCount, 50);
          final last =
              (game.viewFor(game.loser)['hands'] as Map)[game.loser] as List;
          expect(last.length, 1);
          expect(last.single['rankName'], 'queen');
          expect(
            () => game.draw(
              playerId: game.loser!,
              expectedRevision: game.revision,
              cardIndex: 0,
            ),
            throwsStateError,
          );
        }
      },
    );
  }
}
