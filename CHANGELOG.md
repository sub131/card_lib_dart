## 0.1.0

* Remove the Flutter SDK requirement; support pure Dart servers and Flutter apps.
* Add umbrella import, independent physical card IDs, and JSON card output.
* Evaluate standard five-to-seven-card poker, Texas Hold'em, and four-card Omaha.
* Add a complete Old Maid rules engine with private player/spectator views.
* Add Blackjack evaluation, matching pairs/Go Fish books, and trick-taking helpers.
* Add transport-independent tables with turn, ownership, revision and legality checks.
* Fix ace/joker comparison, suit lookup, shared duplicate cards, multi-deck inventory,
  self-transfers, empty deal targets, and visibility after shuffle/reverse.
* Add seeded end-to-end games, regression tests, an executable example and Dart CI.

### Compatibility

* Duplicated decks now contain independent card instances and metadata.
* Existing individual library imports remain available.
* Special visibility modes are hidden in network views until explicitly revealed.

## 0.0.1

* Initial release, customizable cards, piles, and decks, with names and metadata
