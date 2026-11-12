// MIT License
// Copyright (c) 2025 by sub131

import 'dart:math';

import 'package:card_lib_dart/named.dart';

/// Suit class, contains information about the suit and card names in it, including:
/// - Suit.suitNames: Names of all created suits
/// - Suit.suitName(int) & Suit.suitNumber(String): lookup functions between suit name to suitNumber
/// - numOfCards: highest rank (e.g. returns 13 for standard 52 card deck suit)
/// - rankNames: Names of all ranks in this suit
/// - rankName(int) & rankNumber(String): lookup functions between card rank and card Name
/// Use Suit.resetSuits() to clear all static suit information
class Suit extends Named {
  static final List<String> _suitNames = [];
  static final Map<String, int> _suitNamesToSuitNum = {};
  static get numOfSuits {
    return _suitNames.length;
  }

  static List<String> get suitNames {
    return List<String>.unmodifiable(_suitNames);
  }

  static String? suitName(int suitNum) {
    return suitNum < 1 ? null : _suitNames.elementAtOrNull(suitNum - 1);
  }

  static int? suitNumber(String suitName) {
    return _suitNamesToSuitNum.containsKey(suitName)
        ? _suitNamesToSuitNum[suitName]
        : null;
  }

  static resetSuits() {
    _suitNames.clear();
    _suitNamesToSuitNum.clear();
  }

  final Map<String, int> _rankNamesToRank = {};
  final List<String> _rankNames = [];
  List<String> get rankNames {
    return List<String>.unmodifiable(_rankNames);
  }

  int get numOfRanks {
    return rankNames.length;
  }

  String? rankName(int rank) {
    return rank < 1 ? null : _rankNames.elementAtOrNull(rank - 1);
  }

  int? rankNumber(String rankName) {
    return _rankNamesToRank.containsKey(rankName)
        ? _rankNamesToRank[rankName]
        : null;
  }

  int _incrementCards(String name) {
    if (!_rankNamesToRank.containsKey(name)) {
      _rankNames.add(name);
      _rankNamesToRank[name] = numOfRanks;
    }
    return _rankNamesToRank[name] ?? numOfRanks;
  }

  final int suitNum;
  Suit(super.name) : suitNum = suitNames.length + 1 {
    if (suitNames.contains(name)) {
      throw ArgumentError("Duplicate Suits not allowed");
    }
    _suitNames.add(name);
    _suitNamesToSuitNum[name] = numOfSuits;
  }
}

enum CardVisibility {
  hidden,

  ///< hidden from all
  visible,

  ///< visible to all
  pileVisible,

  ///< visible only to the pile/player
  special1,

  ///< special visibility rules apply
  special2,

  ///< special visibility rules apply
  special3,

  ///< special visibility rules apply
  special4,

  ///< special visibility rules apply
  special5,

  ///< special visibility rules apply
}

class Card extends Named {
  static final Random _random = Random.secure();

  /// Opaque identity for one physical card; retained when the card moves.
  final String id = List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  /// Creates an independent physical card, including an independent metadata map.
  Card copy() => Card(suit, rankName, name)
    ..visibility = visibility
    ..metaData.addAll(metaData);

  /// Full server-side representation. Use filtered table views for clients.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'suit': suit.name,
    'rank': rank,
    'rankName': rankName,
    'visibility': visibility.name,
    'metaData': Map<String, String>.of(metaData),
  };

  final Suit suit;
  final int rank;
  final String rankName;
  CardVisibility visibility = CardVisibility.hidden;
  Card(this.suit, this.rankName, super.name)
    : rank = suit._incrementCards(rankName);
  Card.standard52(this.suit, this.rankName)
    : rank = suit._incrementCards(rankName),
      super("$rankName of ${suit.name}");

  @override
  String toString() {
    return '{suit: $suit, rank: $rank, name: "$name"}';
  }
}
