// MIT License
// Copyright (c) 2025 by sub131
import 'package:playing_cards/card_and_suit.dart';
import 'package:playing_cards/pile_and_deck.dart';

/// Abstract class in case we want to add anything to common decks, like reset, etc.
abstract class CommonDefaultDecks extends Deck {
  CommonDefaultDecks(super.deckInfo, {super.addSuitToName=true});
}

/// Standard 52 card deck, no jokers
class DefaultCardDeck extends CommonDefaultDecks {
  static Suit hearts = Suit("hearts");
  static Suit clubs = Suit("clubs");
  static Suit spades = Suit("spades");
  static Suit diamonds = Suit("diamonds");
  static List<String> cardNames = ["ace", "two", "three","four","five","six","seven","eight","nine","ten","jack","queen","king"];
  static Map<Suit,List<String>> _populateInfo() {
    Map<Suit,List<String>> deckInfo = {};
    deckInfo[hearts] = cardNames;
    deckInfo[clubs] = cardNames;
    deckInfo[spades] = cardNames;
    deckInfo[diamonds] = cardNames;
    return deckInfo;
  }

  /// Creates a standard deck
  DefaultCardDeck() :super(_populateInfo());

  /// Creates a standard deck
  DefaultCardDeck.createFromInfo(super.info);

  /// Creates a standard multi-deck deck
  DefaultCardDeck.createMultipleDecks(int totalNumOfDecks) :super(_populateInfo()) {
    // Start at 1 since we already have this deck finished
    for (int i=1; i<totalNumOfDecks; i++) {
      CardPile otherPile = duplicate();
      otherPile.moveCardsToPile(this);
    }
  }
}

/// Exctends the standard 52 card deck with 2 jokers (red and black)
class DefaultCardDeckWithJokers extends DefaultCardDeck {
  static Suit jokers = Suit("jokers");
  static List<String> jokerNames = ["red joker","black joker"];
  static Map<Suit,List<String>> _populateInfo() {
    Map<Suit,List<String>> deckInfo = DefaultCardDeck._populateInfo();
    deckInfo[jokers] = jokerNames;
    return deckInfo;
  }
  DefaultCardDeckWithJokers() :super.createFromInfo(_populateInfo());

  /// Creates a standard multi-deck deck
  DefaultCardDeckWithJokers.createMultipleDecks(int totalNumOfDecks) :super.createFromInfo(_populateInfo()) {
    // Start at 1 since we already have this deck finished
    for (int i=1; i<totalNumOfDecks; i++) {
      CardPile otherPile = duplicate();
      otherPile.moveCardsToPile(this);
    }
  }
}

/// Creates a clue-style deck with default cards
class ClueDeck extends CommonDefaultDecks {
  static Suit who = Suit("who");
  static Suit what = Suit("what");
  static Suit where = Suit("where");
  static List<String> people = ["Colonel Mustard","Mrs. White","Mrs. Peacock","Mr. Green","Professor Plum","Miss Scarlet"];
  static List<String> weapons = ["candlestick","rope","lead pipe","wrench","revolver","dagger"];
  static List<String> locations = ["Ballroom","Billiard Room","Conservatory","Dining Room","Hall","Kitchen","Lounge","Library","Study"];
  static Map<Suit,List<String>> _populateInfo() {
    Map<Suit,List<String>> deckInfo = {};
    deckInfo[who] = people;
    deckInfo[what] = weapons;
    deckInfo[where] = locations;
    return deckInfo;
  }

  ClueDeck() :super(_populateInfo(), addSuitToName: false);
}