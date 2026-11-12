# card_lib_dart

A pure Dart library for customizable cards and decks, reusable card-game rules,
and server-authoritative multiplayer state. Works in Dart servers and Flutter
applications without a Flutter SDK dependency. Requires Dart 3.8.1 or newer.

## Game support

| Game | Included support |
| --- | --- |
| Five-card draw / stud | Best five-card high-poker hand from five to seven cards |
| Texas Hold'em | Two hole cards, three to five community cards, board-only hands and ties |
| Four-card Omaha | Exactly two of four hole cards and exactly three board cards |
| Old Maid | Complete two-to-ten-player game: setup, pairing, blind draws, eliminated seats, loser |
| Blackjack | Hard/soft totals, multiple aces, naturals and busts |
| Go Fish / matching games | Rank pairs and configurable complete-book removal |
| Whist / Hearts / Spades | Follow-suit legal plays and lead/trump trick winner |

Poker support is **showdown evaluation**: betting, blinds, side pots, lowball,
Hi/Lo and wild-card rules are not included. Jokers and duplicate faces are rejected
by the poker evaluator. A royal flush is an ace-high `straightFlush`.
Blackjack, matching and trick-taking support consists of composable rules, rather
than complete games. Bidding, scoring, opening restrictions and game-specific
phases belong in your game's rules layer.

## Decks and generic cards

```dart
import 'package:card_lib_dart/card_lib_dart.dart';

final deck = DefaultCardDeck();
final alice = CardPile('alice');
final bob = CardPile('bob');
deck.shuffle(); // secure randomness by default
deck.dealCards([alice, bob], 5); // round-robin, ten cards total

final custom = Deck('animals', {
  Suit('forest'): ['fox', 'owl', 'deer'],
  Suit('sea'): ['whale', 'seal', 'shark'],
});
```

Piles expose top-first, unmodifiable lists: index zero is the top. Empty draws
return `null`; dealing stops when the source is empty. Transfers to the same pile
and duplicate destinations in round-robin deals throw before moving any cards.
Each physical card has an opaque `id` that survives movement. `duplicate()`
creates independent cards with fresh IDs and independent metadata. Multi-deck
shoes retain all their cards when duplicated.

Existing direct imports (`card_and_suit.dart`, `pile_and_deck.dart`,
`common_decks.dart`) still work. The new umbrella import is `card_lib_dart.dart`.
The legacy `Suit` registry is process-wide. Do not reset it while decks are in
use, or create a separate suit with an already registered name; share suit
definitions across games. New standard-game helpers resolve rank names rather
than relying on registry-assigned numbers.

## Poker and other rules

```dart
final deck = DefaultCardDeck();
final hand = [
  for (final rank in ['ace', 'king', 'queen', 'jack', 'ten'])
    deck.cardByRankName(DefaultCardDeck.hearts, rank)!,
];
final value = Poker.evaluate(hand); // straightFlush, kickers [14]
final blackjack = Blackjack.evaluate(hand.take(2)); // total 21, natural

// Poker.texasHoldem(holeCards, boardCards)
// Poker.omaha(fourHoleCards, boardCards)
// value.compareTo(otherValue): positive wins, zero ties, negative loses.
// MatchingCards.discardPairs(handPile, discardPile)
// MatchingCards.discardBooks(handPile, booksPile) // Go Fish: four of a rank
// TrickTaking.legalPlays(handCards, leadSuit: leadSuit)
// TrickTaking.winnerIndex(playedCards, trump: trumpSuit)
```

## Multiplayer integration

`OldMaidGame` supplies a complete rules engine with revision checks and filtered
JSON-compatible views:

```dart
final game = OldMaidGame(['alice', 'bob', 'carol']);

// On the server, derive playerId from the authenticated connection. Client
// submits expectedRevision and a blind cardIndex into drawFromPlayer's hand.
if (!game.isFinished) {
  game.draw(
    playerId: game.currentPlayer!, // demo only; use authenticated ID in production
    expectedRevision: game.revision,
    cardIndex: 0,
  );
}
final aliceView = game.viewFor('alice');
final spectatorView = game.viewFor(null);
```

Old Maid removes the queen of clubs from a standard deck. Players discard any
rank pairs and draw from the next clockwise nonempty hand. Empty seats are
skipped. One unmatched queen remains with the loser. Hands are shuffled after
each draw. Setup has revision zero; each accepted draw increments it once.

For custom games, `CardTable` adds ownership, revisions, rule-checked moves and
visibility filtering. Keep piles and rule validators exclusively on the server:

```dart
final hand = CardPile('alice')
  ..deckVisiblity = CardVisibility.pileVisible
  ..topCardVisiblity = CardVisibility.pileVisible;
final discard = CardPile('discard')
  ..deckVisiblity = CardVisibility.visible
  ..topCardVisiblity = CardVisibility.visible;
final deck = DefaultCardDeck();
deck.dealCardsToPile(hand, 5);
final table = CardTable(
  players: ['alice', 'bob'],
  piles: {'alice': hand, 'discard': discard, 'stock': deck},
  owners: {'alice': 'alice'},
);
table.move(
  playerId: 'alice', // authenticated connection ID
  expectedRevision: 0,
  from: 'alice',
  to: 'discard',
  cardId: hand.whatIsTopCard()!.id,
  isLegal: (move) => move.from == 'alice' && move.to == 'discard',
);
final view = table.viewFor('bob');
```

- `hidden` cards are hidden from everyone; `pileVisible` cards are disclosed only
  to the pile's configured owner; `visible` cards are public. Special visibility
  modes remain hidden until your rules explicitly reveal them.
- Hidden cards serialize only as `{"hidden": true}`. Their IDs, faces and metadata
  are omitted. Viewer results are detached from mutable server card data.
- `isLegal` is a required **trusted, synchronous, side-effect-free** rule check.
  It must validate the specific game's moves, including moves out of unowned
  stock/discard piles. Another player's owned source pile is always forbidden.
- For a blind stock draw, clients request a draw action; the server chooses the
  top card's ID. Never send stock IDs or a raw full-card snapshot to clients.
- Stale revisions, out-of-turn actions, missing cards, ownership violations and
  rule rejections leave state unchanged. Successful moves end the turn by
  default; trusted rules may use `endTurn: false` for multi-action turns.
- Authenticate users before choosing the viewer/player ID. An ID argument is not
  authentication. Apply actions serially per game on one authoritative instance;
  distributed servers must provide their own lock or transaction mechanism.
- The package does not open sockets or provide matchmaking, authentication,
  persistence or reconnection storage. Use your own HTTP/WebSocket adapter and
  broadcast only each recipient's `viewFor` result. These are client views, not
  restorable server checkpoints. `Card.toJson()` includes full card information
  and must not be used to transmit hidden cards.

Use secure default randomness for real games. Pass `Random(seed)` to
`CardPile.shuffle` or `OldMaidGame` only for deterministic tests or demos. IDs are
always generated independently using secure randomness.

## Development

```sh
dart pub get
dart analyze --fatal-infos
dart test
dart run example/card_lib_dart_example.dart
```

Tests cover poker categories and tie breakers, Hold'em/Omaha selection rules,
Old Maid end-to-end simulations at five player counts, hidden-information
filtering, stale/invalid move atomicity, Blackjack, matching, tricks, and legacy
deck behavior. CI runs checks against Dart 3.8.1 and the stable SDK.

## Migration from 0.0.1

Use `package:test/test.dart` for library tests rather than `flutter_test`. Flutter
apps can continue consuming the library. Code that relied on `duplicate()`
sharing mutable card instances must now retain original references explicitly.
Ace-high comparison now ranks aces above kings; joker comparison ranks jokers
above standard cards. Suit number lookup now matches the one-based `suitNum`.
Reordering a pile reapplies its configured visibility policy.

## License

MIT. Copyright (C) 2025 by sub131.
