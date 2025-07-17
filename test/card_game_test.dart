import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wwwy/pile_and_deck.dart';
import 'package:wwwy/card_and_suit.dart';

void main() {
  Game calc = Game();
  calc.toString;

  test('Creates one of each', () {
    String test= "Test";
    expect(Suit.numOfSuits, 0);
    
    Suit s1 = Suit(test);
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 0);
    Deck deck = Deck.emptyDeck(true);
    deck.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1);
    
    deck.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1, reason:"adding duplicate with allowDuplicates==true doesn't increment rank");
    expect(deck.length, 2, reason: 'Adding duplicate with allowDuplicates==true');  
    deck.addNewCard(s1, "t2");

    // TODO: test remove
    Card? firstT1 = deck.removeFirstMatchingCard(suit: s1);


    expect(() => Suit(" Test".trimLeft()), throwsA(isArgumentError), reason: "no duplicate Suits");
    
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 2);
    Suit s2 = Suit("Test2");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfRanks, 0);
    
    Deck deck2 = Deck.emptyDeck(false);
    deck2.addNewCard(s2, "t1");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfRanks, 1);
    deck2.addNewCard(s2, "t1");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfRanks, 1, reason: 'Adding unallowed duplicate cards silently leaves it unchanged');  
    expect(deck2.length, 1, reason: 'Adding unallowed duplicate cards silently leaves it unchanged');  
  });

  test('Create default names, weapons and locations, picks random ones', () {
    Suit.resetSuits();

    var clueDeck = ClueDeck();
    var deck = clueDeck.create();

    expect(Suit.numOfSuits, 3);
    
    expect(clueDeck.who.numOfRanks, 6);
    expect(clueDeck.what.numOfRanks, 6);
    expect(clueDeck.where.numOfRanks, 9);
    Suit why = Suit("why");
    expect(Suit.numOfSuits, 4);
  
    deck.shuffle();
    var size = deck.cards.length;

    Card? who1 = deck.removeFirstMatchingCard(suit: clueDeck.who);
    Card? what1 = deck.removeFirstMatchingCard(suit: clueDeck.what);
    Card? where1 = deck.removeFirstMatchingCard(suit: clueDeck.where);
    Card? why1 = deck.removeFirstMatchingCard(suit: why);
    expect(deck.cards.length, size-3, reason: "Expect 3 removed");
    debugPrint('$who1 + $what1 + $where1 + $why1');

    expect(who1?.suit, clueDeck.who);
    expect(what1?.suit, clueDeck.what);
    expect(where1?.suit, clueDeck.where);
    expect(why1?.suit, null, reason: "Expect no motives in default deck");
  });

  test('Create default 52 card deck, picks random ones', () {
    Suit.resetSuits();

    var cardDeck = DefaultCardDeck();
    var deck = cardDeck.create();

    expect(Suit.numOfSuits, 4);
    expect(cardDeck.hearts.numOfRanks, 13);
    expect(cardDeck.clubs.numOfRanks, 13);
    expect(cardDeck.spades.numOfRanks, 13);
    expect(cardDeck.diamonds.numOfRanks, 13);
    
    deck.shuffle();
    var size = deck.cards.length;
    expect(size, 52);
    expect(deck.length, 52);

    Card? h1 = deck.removeFirstMatchingCard(suit: cardDeck.hearts);
    Card? c1 = deck.removeFirstMatchingCard(suit: cardDeck.clubs);
    Card? s1 = deck.removeFirstMatchingCard(suit: cardDeck.spades);
    Card? d1 = deck.removeFirstMatchingCard(suit: cardDeck.diamonds);
    expect(deck.cards.length, size-4, reason: "Expect 4 removed");
    debugPrint('$h1 + $c1 + $s1 + $d1');

    expect(h1?.suit, cardDeck.hearts);
    expect(c1?.suit, cardDeck.clubs);
    expect(s1?.suit, cardDeck.spades);
    expect(d1?.suit, cardDeck.diamonds);
  });

    test('Create default 52+jokers card deck, picks random ones', () {
    Suit.resetSuits();

    var cardDeck = DefaultCardDeckWithJokers();
    var deck = cardDeck.create();

    expect(Suit.numOfSuits, 5);
    expect(cardDeck.hearts.numOfRanks, 13);
    expect(cardDeck.clubs.numOfRanks, 13);
    expect(cardDeck.spades.numOfRanks, 13);
    expect(cardDeck.diamonds.numOfRanks, 13);
    expect(cardDeck.jokers.numOfRanks, 2);
    
    deck.shuffle();
    var size = deck.cards.length;    
    expect(size, 54);
    expect(deck.length, 54);

    Card? h1 = deck.removeFirstMatchingCard(suit: cardDeck.hearts);
    Card? c1 = deck.removeFirstMatchingCard(suit: cardDeck.clubs);
    Card? s1 = deck.removeFirstMatchingCard(suit: cardDeck.spades);
    Card? d1 = deck.removeFirstMatchingCard(suit: cardDeck.diamonds);
    Card? j1 = deck.removeFirstMatchingCard(suit: cardDeck.jokers);
    expect(deck.cards.length, size-5, reason: "Expect 4 removed");
    debugPrint('$h1 + $c1 + $s1 + $d1 + $j1');
    
    expect(h1?.suit, cardDeck.hearts);
    expect(c1?.suit, cardDeck.clubs);
    expect(s1?.suit, cardDeck.spades);
    expect(d1?.suit, cardDeck.diamonds);
    expect(j1?.suit, cardDeck.jokers);
    
    Card? j2 = deck.removeFirstMatchingCard(suit: cardDeck.jokers);
    Card? jn = deck.removeFirstMatchingCard(suit: cardDeck.jokers);
    expect(j2?.suit, cardDeck.jokers);
    expect(jn?.suit, null);    
  });

  test('Test CardPile functionality', () {
  });
}
