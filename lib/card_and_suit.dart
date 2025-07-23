// MIT License
// Copyright (c) 2025 by sub131

//@TODO: Add suit and card compare, ace high, jokers higher?

import 'package:playing_cards/named.dart';

/// Suit class, contains information about the suit and card names in it, including:
/// - Suit.suitNames: Names of all created suits
/// - Suit.suitName(int) & Suit.suitNumber(String): lookup functions between suit name to suitNumber
/// - numOfCards: highest rank (e.g. returns 13 for standard 52 card deck suit)
/// - rankNames: Names of all ranks in this suit
/// - rankName(int) & rankNumber(String): lookup functions between card rank and card Name
/// Use Suit.resetSuits() to clear all static suit information 
class Suit extends Named {
  static final List<String> _suitNames=[];
  static final Map<String, int> _suitNamesToSuitNum={};
  static get numOfSuits {return _suitNames.length;}
  static List<String> get suitNames {return List<String>.unmodifiable(_suitNames);}
  static String? suitName(int suitNum) {return _suitNames.elementAtOrNull(suitNum);}
  static int? suitNumber(String suitName) {return _suitNamesToSuitNum.containsKey(suitName) ? _suitNamesToSuitNum[suitName]: null;}
  
  final Map<String, int> _rankNamesToRank={};
  final List<String> _rankNames=[];
  List<String> get rankNames {return List<String>.unmodifiable(_rankNames);}
  int get numOfRanks { return rankNames.length;}
  String? rankName(int rank) {return _rankNames.elementAtOrNull(rank-1);}
  int? rankNumber(String rankName) {return _rankNamesToRank.containsKey(rankName) ? _rankNamesToRank[rankName]: null;}
  
  int _incrementCards(String name) {
    if (!_rankNamesToRank.containsKey(name)) {
      _rankNames.add(name);
      _rankNamesToRank[name] = numOfRanks;
    }
    return numOfRanks;
  }
  final int suitNum;
  Suit(super.name) : suitNum = suitNames.length+1
  {
    if (suitNames.contains(name)) {
      throw ArgumentError("Duplicate Suits not allowed");
    }
    _suitNames.add(name);
    _suitNamesToSuitNum[name] = numOfSuits;    
  }
}

class Card extends Named {
  final Suit suit;
  final int rank;
  final String rankName;
  Card(this.suit, this.rankName, super.name) : rank = suit._incrementCards(rankName);
  Card.standard52(this.suit, this.rankName) : rank = suit._incrementCards(rankName), super("$rankName of ${suit.name}");
  
  @override
  String toString() {
    return '{suit: $suit, rank: $rank, name: "$name"}';
  }
}