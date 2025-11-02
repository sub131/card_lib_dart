// MIT License
// Copyright (c) 2025 by sub131

import 'package:card_lib_dart/named.dart';

import 'card_and_suit.dart';

/// For efficiency, cardPiles are implemented as a reversed list since most common actions are
/// to add or remove from the top (end of list). All lists returned will be unmodifyable 
/// reversed lists (0 being top). 
/// That has the consequence that some operations seem backwards. Adding a card adds it to the
/// top (index 0), removing it removes it from the top (index 0). Adding 1, 2, then 3 will 
/// leave the pile at 3, 2, 1 with 3 on the top.
class CardPile extends Named {
  final List<Card> _cards = [];
  CardVisibility _topCardVisiblity = CardVisibility.hidden;
  CardVisibility _deckVisiblity = CardVisibility.hidden;

  CardVisibility get deckVisiblity => _deckVisiblity;
  set deckVisiblity(CardVisibility visibility) {
    _deckVisiblity = visibility;
    updateVisibility(allCards:true);
  }
  CardVisibility get topCardVisiblity => _topCardVisiblity;
  set topCardVisiblity(CardVisibility visibility) {
    _topCardVisiblity = visibility;
    updateVisibility();
  }

  CardPile(super.name);

  get length { return _cards.length;}
  List<Card> get cards { return List<Card>.unmodifiable(_cards.reversed);}

  /// Shuffles the deck
  shuffle () {_cards.shuffle();}

  /// Reverses the deck
  reverse() {
    List<Card> reversedList = List<Card>.from(cards);
    _cards.clear();
    _cards.addAll(reversedList);
  }

  updateVisibility({bool allCards=false, Card? card}) {
    if (_cards.isNotEmpty) {
      if (allCards) {
        for (int i=0; i < _cards.length-1; i++) {
          _cards[i].visibility = deckVisiblity;
        }
      }
      if (card != null) {
        card.visibility = deckVisiblity;
      }
      _cards.last.visibility = topCardVisiblity;
    }
  }

  /// Removes the top card and returns it to be put elsewhere
  Card? removeTopCard() {
    if (length > 0) {
      Card? removed = _cards.removeLast();
      updateVisibility(); //Ensure top card visibility is updated
      return removed;
    } else {
      return null;
    }
  }

  /// Internal helper function to reverse the index
  int _reverseIndex(int index) {
    // reversed index (0 = last, length-1 = first)
      return length-1-index;
  }
  /// Internal helper function to check for a valid index
  bool _validIndex(int index) {
    return (index < length && index >= 0);
  }

  /// Removes the card at the specified index
  Card? removeCard(int index) {
    if (_validIndex(index)) {
      // Remove reversed index (0 = last, length-1 = first)
      Card? removedCard = _cards.removeAt(_reverseIndex(index));
      updateVisibility(); //Ensure top card visibility is updated
      return removedCard;
    } else {
      return null;
    }
  }

  /// Peaks at the top card without removing it
  Card? whatIsTopCard() {
    if (length > 0) {
      return _cards.last;
    } else {
      return null;
    }
  }

  /// Peaks at the specified card without removing it
  Card? whatIsCard(int index) {
    if (_validIndex(index)) {
      return _cards[_reverseIndex(index)];
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
  Card? removeFirstMatchingCard({Suit? suit, String? rankName, int? rank}) {
    if (suit==null && rankName==null && rank==null) {
      return null;
    }
    for (int index=0; index < length; index++) {
      Card? card = whatIsCard(index);
      if (card != null &&
          (suit == null || card.suit == suit) && 
          (rankName == null || card.rankName == rankName) &&
          (rank == null || card.rank == rank)) {
        Card? removedCard = removeCard(index);
        updateVisibility(); //Ensure top card visibility is updated
        return removedCard;
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

  /// Moves the first card to match all of the supplied parameters (suit, rankName or rank). Returns true
  /// if a move was made.
  /// If no parameters are supplied, nothing will be found. Usually only rankName or rank will be necessary
  /// as they are usually related. Examples: 
  /// - moveFirstMatchingCardToPile(other, suit: DefaultCardDeck.hearts) => moves the first heart
  /// - moveFirstMatchingCardToPile(other, suit: DefaultCardDeck.hearts, rankName: "ace") => moves the ace of hearts
  /// - moveFirstMatchingCardToPile(other, rank: 1) => moves the first ace of any suit
  /// - moveFirstMatchingCardToPile(other, rank: 1, rankName: "two") => returns false (asking for a "two" that's rank 1)
  bool moveFirstMatchingCardToPile(CardPile pile, {Suit? suit, String? rankName, int? rank}) {
    Card? card = removeFirstMatchingCard(suit: suit, rankName: rankName, rank: rank);
    if (card==null) {
      return false;
    } else {
      updateVisibility(); //Ensure top card visibility is updated
      pile.addCard(card);
      return true;
    }
  }

  /// Moves all cards that match all of the supplied parameters (suit, rankName or rank). Returns true
  /// if a move was made.
  /// If no parameters are supplied, nothing will be found. Usually only rankName or rank will be necessary
  /// as they are usually related. Examples: 
  /// - moveAllMatchingCardsToPile(other, suit: DefaultCardDeck.hearts) => moves the hearts
  /// - moveAllMatchingCardsToPile(other, suit: DefaultCardDeck.hearts, rankName: "ace") => moves the ace of hearts
  /// - moveAllMatchingCardsToPile(other, rank: 1) => moves the aces of every suit
  /// - moveAllMatchingCardsToPile(other, rank: 1, rankName: "two") => returns false (asking for a "two" that's rank 1)
  bool moveAllMatchingCardsToPile(CardPile pile, {Suit? suit, String? rankName, int? rank}) {
    Card? card = removeFirstMatchingCard(suit: suit, rankName: rankName, rank: rank);
    bool removed = false;
    while (card != null) {
      pile.addCard(card);
      removed = true;
      card = removeFirstMatchingCard(suit: suit, rankName: rankName, rank: rank);
    }
    updateVisibility(); //Ensure top card visibility is updated
    return removed;
  }

  /// Puts the card on the top of this pile
  addCard(Card card) {
    Card? oldLast = _cards.isNotEmpty ? _cards.last : null;
    _cards.add(card);
    updateVisibility(card:oldLast); //Ensure top card visibility is updated
  }

  /// Moves the top card to the specified pile, returning true if there was a card
  bool moveTopCardToPile(CardPile other) {
    Card? card = removeTopCard();
    if (card != null) {
      updateVisibility(); //Ensure top card visibility is updated
      other.addCard(card);
      return true;
    } else {
      return false;
    }
  }

    /// Moves the top card to the specified pile, returning true if there was a card
  bool moveCardToPile(CardPile other, int index) {
    Card? card = removeCard(index);
    if (card != null) {
      updateVisibility(); //Ensure top card visibility is updated
      other.addCard(card);
      return true;
    } else {
      return false;
    }
  }
  
  /// Deals the specified number of cards from the top of this pile to the top of the other.
  /// Returns the number of cards dealt.
  int dealCardsToPile(CardPile other, int maxCards) {
    int cardsDealt = 0;
    bool done = maxCards <= 0;

    while (!done) {
      if (moveTopCardToPile(other)) {
        cardsDealt++;
        done = cardsDealt >= maxCards;
      } else {
        done = true;
      }
    }
    updateVisibility(); //Ensure top card visibility is updated
    return cardsDealt;
  }

  /// Deals the number of cards to each pile in order, returning the number of cards dealt.
  /// Dealing 5 cards to 3 hands will deal up to 15 cards if available.
  int dealCards(List<CardPile> others, int maxCardsPerHand) {
    int cardsDealt = 0;
    int handsDealt = 0;
    bool done = maxCardsPerHand <= 0;

    while (!done) {
      for (CardPile other in others) {
        if (moveTopCardToPile(other)) {
          cardsDealt++;
        } else {
          done = true;
        }
      }
      if (!done) {
        handsDealt++;
        done = handsDealt >= maxCardsPerHand;
      }
    }
    updateVisibility(); //Ensure top card visibility is updated
    return cardsDealt;
  }

  /// Move all cards to the pile, from the top of this pile to the top of the other, 
  /// which will also reverse the cards.
  bool moveCardsToPile(CardPile other) {
    Card? card = removeTopCard();
    bool removed = false;
    while (card != null) {
      other.addCard(card);
      removed = true;
      card = removeTopCard();
    }
    return removed;
  }

  @override
  String toString() {
    List<String> names = [];
    for (Card c in cards) {
      names.add(c.name);
    }
    return '$name: $names';
  }
  
  Iterable get iterator => cards;

}

/// A deck is a pile that retains the knowledge of the cards in the deck, and helper functions
/// to duplicate.
class Deck extends CardPile {
  static const String undefinedName = "UNDEFINED";
  final List<Card> _addedCards = [];
  final Map<Suit, Map<int, Card>> _addedCardsBySuitRank = {};
  List<Card> get addedCards {return List<Card>.unmodifiable(_addedCards);}

  /// Duplicates the deck by adding all known cards into a new empty pile.
  CardPile duplicate({duplicateName}) {
    CardPile newPile = CardPile(duplicateName ?? '${name}_duplicate');
    newPile._cards.addAll(_addedCards);
    newPile.updateVisibility(allCards:true); //Ensure top card visibility is updated
    return newPile;
  }
  
  /// Adds each list of rank names to the suit and to the deck.
  /// @param rankNamesPerSuit a mapping of suits to list of rank names in that suit
  /// @param addSuitToName set to true to use the same name for the card as for the rankName (default true)
  ///   (e.g. '$rankName' vs '$rankName of ${suit.name}') 
  Deck(super.name, Map<Suit,List<String>> rankNamesPerSuit, {bool addSuitToName=true}) {
    for (var suit in rankNamesPerSuit.keys) {
      for (var name in (rankNamesPerSuit[suit]??[])) {
        addSuitToName ? 
          addNewCard(suit, name) :
          addNewCard(suit, name, cardName: name);
      }
    }
  }
  /// Constructor for an empty deck
  Deck.emptyDeck() : super('empty');

  /// Adds a new card to the deck. 
  addNewCard(Suit suit, String rankName, {String? cardName}) {
    if (rankName.toUpperCase() == undefinedName.toUpperCase()) {
      throw ArgumentError("Name can't be undefinedName");
    }

    // Add card to the pile
    Card newCard;
    bool isStandard52 = cardName==null;
    if (isStandard52) {
      newCard = Card.standard52(suit, rankName);
    } else {
      newCard = Card(suit, rankName, cardName);
    }
    addCard(newCard);

    //If not already added, add it.
    _addedCards.add(newCard);
    if (!_addedCardsBySuitRank.containsKey(suit)) {
      _addedCardsBySuitRank[suit] = {};
    }
    _addedCardsBySuitRank[suit]?[newCard.rank] = newCard;
  }

  /// Looks up the rank name by suit and rank number
  String rankName(Suit suit, int rank) {
    return suit.rankName(rank) ?? undefinedName;
  }

  /// Looks up the card name by suit and rank number
  String cardName(Suit suit, int rank) {
    return _addedCardsBySuitRank[suit]?[rank]?.name ?? undefinedName;
  }

  /// Looks up a copy of the card by suit and rank
  Card? cardByRank(Suit suit, int rank) {
    return _addedCardsBySuitRank[suit]?[rank];
  }

  /// Looks up a copy of the card by suit and rank name
  Card? cardByRankName(Suit suit, String rankName) {
    return _addedCardsBySuitRank[suit]?[suit.rankNumber(rankName)];
  }
}