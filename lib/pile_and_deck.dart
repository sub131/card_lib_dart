import 'card_and_suit.dart';
/// A Calculator.
class Game {
  /// TBD
}


class CardPile {
  final List<Card> _cards = [];
  get length { return _cards.length;}
  get cards { return List<Card>.unmodifiable(_cards);}
  shuffle () {_cards.shuffle();}
  var isTopVisible = false;

  Card? removeTopCard() {
    if (length > 0) {
      return _cards.removeLast();
    } else {
      return null;
    }
  }
  Card? removeCard(int index) {
    if (index < length && index >= 0) {
      return _cards.removeAt(index);
    } else {
      return null;
    }
  }
  Card? whatIsTopCard() {
    if (length > 0) {
      return _cards.last;
    } else {
      return null;
    }
  }
  Card? whatIsCard(int index) {
    if (index < length && index >= 0) {
      return _cards[index];
    } else {
      return null;
    }
  }
  /// Removes the first card to match all of the supplied parameters (suit, name or rank).
  /// If no parameters are supplied, nothing will be found. Usually only name or rank will be necessary
  /// as they are usually related. Examples: 
  /// - removeFirstMatchingCard(suit: DefaultCardDeck.hearts) => returns the first heart
  /// - removeFirstMatchingCard(suit: DefaultCardDeck.hearts, name: "ace") => returns the ace of hearts
  /// - removeFirstMatchingCard(rank: 1) => returns the first ace of any suit
  /// - removeFirstMatchingCard(rank: 1, name: "two") => returns null (asking for a "two" that's rank 1)
  Card? removeFirstMatchingCard({Suit? suit, String? name, int? rank}) {
    if (suit==null && name==null && rank==null) {
      return null;
    }
    for (Card card in cards) {
      if ((suit == null || card.suit == suit) && 
          (name == null || card.name == name) &&
          (rank == null || card.rank == rank)) {
        _cards.remove(card);
        return card;
      }
    }
    return null;
  }
  /// Returns whether at least one card matches all of the supplied parameters (suit, name or rank).
  /// If no parameters are supplied, nothing will be found. Usually only name or rank will be necessary
  /// as they are usually related. Examples: 
  /// - isCardPresent(suit: DefaultCardDeck.hearts) => returns true if pile contains a heart
  /// - isCardPresent(suit: DefaultCardDeck.hearts, name: "ace") => returns true if the ace of hearts if found
  /// - isCardPresent(rank: 1) => returns true if pile contains an ace of any suit
  /// - isCardPresent(rank: 1, name: "two") => returns false (asking for a "two" that's rank 1)
  bool isCardPresent({Suit? suit, String? name, int? rank}) {
    if (suit==null && name==null && rank==null) {
      return false;
    }
    for (Card card in cards) {
      if ((suit == null || card.suit == suit) && 
          (name == null || card.name == name) &&
          (rank == null || card.rank == rank)) {
        return true;
      }
    }
    return false;
  }
  /// Moves the first card to match all of the supplied parameters (suit, name or rank). Returns true
  /// if a move was made.
  /// If no parameters are supplied, nothing will be found. Usually only name or rank will be necessary
  /// as they are usually related. Examples: 
  /// - moveFirstMatchingCardToPile(other, suit: DefaultCardDeck.hearts) => moves the first heart
  /// - moveFirstMatchingCardToPile(other, suit: DefaultCardDeck.hearts, name: "ace") => moves the ace of hearts
  /// - moveFirstMatchingCardToPile(other, rank: 1) => moves the first ace of any suit
  /// - moveFirstMatchingCardToPile(other, rank: 1, name: "two") => returns false (asking for a "two" that's rank 1)
  bool moveFirstMatchingCardToPile(CardPile pile, {Suit? suit, String? name, int? rank}) {
    Card? card = removeFirstMatchingCard(suit: suit, name: name, rank: rank);
    if (card==null) {
      return false;
    } else {
      pile.addCard(card);
      return true;
    }
  }
  addCard(Card card) {
    _cards.add(card);
  }
  bool moveTopCardToPile(CardPile other) {
    Card? card = removeTopCard();
    if (card != null) {
      other.addCard(card);
      return true;
    } else {
      return false;
    }
  }
}

class Deck extends CardPile {
  static const String undefinedName = "UNDEFINED";
  final List<Card> _addedCards = [];
  final Map<Suit, Map<int, Card>> _addedCardsBySuiteRank = {};
  List<Card> get addedCards {return List<Card>.unmodifiable(_addedCards);}
  var allowDuplicates = false;
  
  /// Adds each list of rank names to the suit and to the deck.
  /// @param rankNamesPerSuit a mapping of suits to list of rank names in that suit
  /// @param allowDuplicates set to true to allow multiple identical cards to be added to the deck (default false)
  /// @param addSuitToName set to true to use the same name for the card as for the rankName (default true)
  ///   (e.g. '$rankName' vs '$rankName of ${suit.name}') 
  Deck(Map<Suit,List<String>> rankNamesPerSuit, {this.allowDuplicates=false, bool addSuitToName=true}) {
    for (var suit in rankNamesPerSuit.keys) {
      for (var name in (rankNamesPerSuit[suit]??[])) {
        addSuitToName ? 
          addNewCard(suit, name) :
          addNewCard(suit, name, cardName: name);
      }
    }
  }
  Deck.emptyDeck(this.allowDuplicates);

  /// Adds a new card to the deck. If duplicates are allowed,
  /// then adding duplicate names creates two such
  addNewCard(Suit suit, String rankName, {String? cardName}) {
    if (rankName.toUpperCase() == undefinedName.toUpperCase()) {
      throw ArgumentError("Name can't be undefinedName");
    }

    if (allowDuplicates || suit.rankNumber(rankName)==null) {
      //If not already added, add it.
      Card newCard;
      bool isStandard52 = cardName==null;
      if (isStandard52) {
        newCard = Card.standard52(suit, rankName);
      } else {
        newCard = Card(suit, rankName, cardName);
      }
      addCard(newCard);
      _addedCards.add(newCard);
      if (!_addedCardsBySuiteRank.containsKey(suit)) {
        _addedCardsBySuiteRank[suit] = {};
      }
      _addedCardsBySuiteRank[suit]?[newCard.rank] = newCard;
    }
  }
  String rankName(Suit suit, int rank) {
    return suit.rankName(rank) ?? undefinedName;
  }
  String cardName(Suit suit, int rank) {
    return _addedCardsBySuiteRank[suit]?[rank]?.name ?? undefinedName;
  }
  Deck.createDefaultClue();

  @override
  String toString() {
    return cards.toString();
  }

}
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