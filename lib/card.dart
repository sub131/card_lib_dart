class Named {
  final String name;
  const Named(this.name);
  @override
  String toString() {
    return name;
  }
}

class Suit extends Named {
  static Set<String> suitNames={};
  static get numOfSuits {return suitNames.length;}
  static resetSuits() {
    suitNames.clear();
  }

  get numOfCards { return _numOfCards;}
  int _numOfCards=0;

  int incrementCards() {
    return ++_numOfCards;
  }
  final int suitNum;
  Suit(super.name) : suitNum = suitNames.length+1
  {
    if (suitNames.contains(name)) {
      throw ArgumentError("Duplicate Suits not allowed");
    }
    suitNames.add(name);
  }
}

class Card extends Named {
  final Suit suit;
  final int rank;
  Card(this.suit, super.name) : rank = suit.incrementCards();
  
  @override
  String toString() {
    return '{suit: $suit, rank: $rank, name: "$name"}';
  }
}

class Deck {
  var allowDuplicates = false;
  var cards = [];
  Map<Suit, Map<int, String>> customizableNamesByIndex = {};
  Map<Suit, Map<String, int>> customizableIndexByNames = {};

  String? getNameByCardNum(Suit suit, int cardNum) {
    return customizableNamesByIndex[suit]?[cardNum];
  }
  int? getCardNumByName(Suit suit, String name) {
    return customizableIndexByNames[suit]?[name];
  }

  Card? get removeTopCard {
    if (cards.isEmpty) return null;
    return cards.removeLast();
  }
  Card? removeFirst(Suit suit) {
    Card? card = cards.firstWhere((element) => element.suit==suit, orElse: () => null);
    cards.remove(card);
    return card;
  }

  Deck(Map<Suit,List<String>> numPerSuit, {this.allowDuplicates=false}) {
    for (var suit in numPerSuit.keys) {
      customizableNamesByIndex[suit] = {};
      customizableIndexByNames[suit] = {};
      for (var name in (numPerSuit[suit]??[])) {
        addNewCard(suit, name);
      }
    }
  }
  Deck.emptyDeck(this.allowDuplicates);
  addNewCard(Suit suit, String name) {
    if (!customizableIndexByNames.containsKey(suit)){
      customizableIndexByNames[suit] = {};
      customizableNamesByIndex[suit] = {};
    }
    if (allowDuplicates || !customizableIndexByNames[suit]!.containsKey(name)) {
      //If not already added, add it.
      Card newCard = Card(suit, name);
      customizableNamesByIndex[suit]![newCard.rank] = name;
      customizableIndexByNames[suit]![name] = newCard.rank;
      cards.add(newCard);
    }
  }
  shuffle() {
    cards.shuffle();
  }
  String name(Suit suit, int index) {
    return customizableNamesByIndex[suit]![index] ?? "UNDEFINED";
  }
  String cardName(Card card) {
    return name(card.suit, card.rank);
  }
  Deck.createDefaultClue();

  @override
  String toString() {
    return cards.toString();
  }

}
class CommonDefaultDecks {
  final Map<Suit,List<String>> deckInfo = {};
  CommonDefaultDecks();
  Deck createDeck() {
    return Deck(deckInfo);
  }
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
}