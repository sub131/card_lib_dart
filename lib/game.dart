import 'card.dart';
/// A Calculator.
class Game {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
  Suit? type;
}

class CardPile {
  final List<Card> _cards = [];
  get length { return cards.length;}
  get cards { return _cards;}
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
