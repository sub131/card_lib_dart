// MIT License
// Copyright (c) 2025 by sub131
import 'package:card_lib_dart/card_and_suit.dart';
import 'package:card_lib_dart/pile_and_deck.dart';

/// Abstract class in case we want to add anything to common decks, like reset, etc.
abstract class CommonDefaultDecks extends Deck {
  CommonDefaultDecks(super.name, super.deckInfo, {super.addSuitToName = true});
}

/// Standard 52 card deck, no jokers
class DefaultCardDeck extends CommonDefaultDecks {
  static Suit hearts = Suit("hearts");
  static Suit clubs = Suit("clubs");
  static Suit spades = Suit("spades");
  static Suit diamonds = Suit("diamonds");
  static List<String> cardNames = [
    "ace",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "jack",
    "queen",
    "king",
  ];
  static Map<Suit, List<String>> _populateInfo({int copies = 1}) {
    if (copies < 1) {
      throw ArgumentError.value(copies, 'copies', 'Must be positive');
    }
    Map<Suit, List<String>> deckInfo = {};
    deckInfo[hearts] = [for (var i = 0; i < copies; i++) ...cardNames];
    deckInfo[clubs] = [for (var i = 0; i < copies; i++) ...cardNames];
    deckInfo[spades] = [for (var i = 0; i < copies; i++) ...cardNames];
    deckInfo[diamonds] = [for (var i = 0; i < copies; i++) ...cardNames];
    return deckInfo;
  }

  static int compareCards(Card left, Card right, {bool aceHigh = true}) {
    int leftRank = (aceHigh && left.rank == 1) ? 14 : left.rank;
    int rightRank = (aceHigh && right.rank == 1) ? 14 : right.rank;
    return leftRank.compareTo(rightRank);
  }

  /// Creates a standard deck
  DefaultCardDeck() : super('Standard52', _populateInfo());

  /// Creates a standard deck
  DefaultCardDeck.createFromInfo(super.name, super.info);

  /// Creates a standard multi-deck deck
  DefaultCardDeck.createMultipleDecks(int totalNumOfDecks)
    : super(
        'Standard52 x $totalNumOfDecks',
        _populateInfo(copies: totalNumOfDecks),
      );
}

/// Exctends the standard 52 card deck with 2 jokers (red and black)
class DefaultCardDeckWithJokers extends DefaultCardDeck {
  static Suit jokers = Suit("jokers");
  static List<String> jokerNames = ["red joker", "black joker"];
  static Map<Suit, List<String>> _populateInfo({int copies = 1}) {
    Map<Suit, List<String>> deckInfo = DefaultCardDeck._populateInfo(
      copies: copies,
    );
    deckInfo[jokers] = [for (var i = 0; i < copies; i++) ...jokerNames];
    return deckInfo;
  }

  static int compareCards(Card left, Card right, {bool aceHigh = true}) {
    int leftRank = (aceHigh && left.rank == 1) ? 14 : left.rank;
    int rightRank = (aceHigh && right.rank == 1) ? 14 : right.rank;
    if (left.suit == jokers) {
      leftRank = 15;
    }
    if (right.suit == jokers) {
      rightRank = 15;
    }
    return leftRank.compareTo(rightRank);
  }

  DefaultCardDeckWithJokers()
    : super.createFromInfo('Standard52wJkrs', _populateInfo());

  /// Creates a standard multi-deck deck
  DefaultCardDeckWithJokers.createMultipleDecks(int totalNumOfDecks)
    : super.createFromInfo(
        'Standard52wJkrs x $totalNumOfDecks',
        _populateInfo(copies: totalNumOfDecks),
      );
}

/// Creates a clue-style who-done-it deck with default cards to test non-standard decks
class MysteryDeck extends CommonDefaultDecks {
  static Suit who = Suit("who");
  static Suit what = Suit("what");
  static Suit where = Suit("where");
  static List<String> people = [
    "Colonel Canary",
    "Mrs. Snow",
    "Mrs. Penguin",
    "Mr. Leaf",
    "Professor Pepper",
    "Miss Red",
  ];
  static List<String> weapons = [
    "broomstick",
    "noose",
    "copper pipe",
    "hammer",
    "gun",
    "knife",
  ];
  static List<String> locations = [
    "Dancefloor",
    "Game Room",
    "Greenhouse",
    "Dining Room",
    "Hallway",
    "Kitchen",
    "Sitting Room",
    "Living Room",
    "Office",
  ];
  static Map<Suit, List<String>> _populateInfo() {
    Map<Suit, List<String>> deckInfo = {};
    deckInfo[who] = people;
    deckInfo[what] = weapons;
    deckInfo[where] = locations;
    return deckInfo;
  }

  MysteryDeck() : super('MysteryDeck', _populateInfo(), addSuitToName: false);
}
