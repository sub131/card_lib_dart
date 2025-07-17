import 'package:subsoft.cards/card_and_suit.dart';
import 'package:subsoft.cards/pile_and_deck.dart';

abstract class CommonDefaultDecks {
  final Map<Suit,List<String>> deckInfo = {};
  CommonDefaultDecks();
  Deck _createDeck({allowDuplicates=false, bool addSuitToName=true}) {
    return Deck(deckInfo, allowDuplicates: allowDuplicates, addSuitToName: addSuitToName);
  }
  Deck create();
}

class DefaultCardDeck extends CommonDefaultDecks {
  Suit hearts = Suit("hearts");
  Suit clubs = Suit("clubs");
  Suit spades = Suit("spades");
  Suit diamonds = Suit("diamonds");
  var cards = ["ace", "two", "three","four","five","six","seven","eight","nine","ten","jack","queen","king"];

  DefaultCardDeck() {
    deckInfo[hearts] = cards;
    deckInfo[clubs] = cards;
    deckInfo[spades] = cards;
    deckInfo[diamonds] = cards;
  }

  @override 
  Deck create() {return _createDeck();}
  Deck createMultipleDecks(int totalNumOfDecks) {
    Deck deck = create();
    for (int i=0; i < totalNumOfDecks; i++) {
      deck.duplicate().moveCardsToPile(deck);
    }
    return deck;
  }
}

class DefaultCardDeckWithJokers extends DefaultCardDeck {
  Suit jokers = Suit("jokers");
  var jokerNames = ["red joker","black joker"];

  DefaultCardDeckWithJokers() {
    deckInfo[jokers] = jokerNames;
  }
  
  @override 
  Deck create() {return _createDeck();}
}

class ClueDeck extends CommonDefaultDecks {
  Suit who = Suit("who");
  Suit what = Suit("what");
  Suit where = Suit("where");
  var people = ["Colonel Mustard","Mrs. White","Mrs. Peacock","Mr. Green","Professor Plum","Miss Scarlet"];
  var weapons = ["candlestick","rope","lead pipe","wrench","revolver","dagger"];
  var locations = ["Ballroom","Billiard Room","Conservatory","Dining Room","Hall","Kitchen","Lounge","Library","Study"];


  ClueDeck() {
    deckInfo[who] = people;
    deckInfo[what] = weapons;
    deckInfo[where] = locations;
  }
  
  @override 
  Deck create() {return _createDeck(addSuitToName: false);}
}