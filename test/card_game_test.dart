import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subsoft.cards/common_decks.dart';
import 'package:subsoft.cards/pile_and_deck.dart';
import 'package:subsoft.cards/card_and_suit.dart';

void main() {
  Game calc = Game();
  calc.toString;

  test('Creates one of each', () {

    /// Test addition of suits and cards
    String test= "Test";
    expect(Suit.numOfSuits, 0);
    
    Suit s1 = Suit(test);
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 0);
    Deck deck1 = Deck.emptyDeck(true);
    deck1.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1);
    
    deck1.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1, reason:"adding duplicate with allowDuplicates==true doesn't increment rank");
    expect(deck1.length, 2, reason: 'Adding duplicate with allowDuplicates==true');  
    deck1.addNewCard(s1, "t2");

    /// Test removal of matching cards and WhatIsCard functions 
    // [t2, t1, t1]
    expect(deck1.length, 3);
    expect(deck1.whatIsTopCard()?.name, "t2 of Test");
    expect(deck1.whatIsCard(0)?.name, "t2 of Test");
    expect(deck1.whatIsCard(1)?.name, "t1 of Test");
    expect(deck1.whatIsCard(2)?.name, "t1 of Test"); 
    Card? firstT1 = deck1.removeFirstMatchingCard(rankName: "t1");
    // [t2, t1] 
    expect(firstT1?.name, "t1 of Test");
    expect(deck1.length, 2);
    expect(deck1.whatIsTopCard()?.name, "t2 of Test");
    expect(deck1.whatIsCard(0)?.name, "t2 of Test");
    expect(deck1.whatIsCard(1)?.name, "t1 of Test");
    expect(deck1.whatIsCard(2)?.name, null);

    Card? nullCard = deck1.removeFirstMatchingCard(suit: s1, rank: 2, rankName: "t1");
    // [t2, t1] 
    expect(nullCard, null);
    Card? firstT2 = deck1.removeFirstMatchingCard(suit: s1, rank: 2);
    // [t1] 
    expect(firstT2?.name, "t2 of Test");
    expect(deck1.length, 1);
    expect(deck1.whatIsTopCard()?.name, "t1 of Test");
    expect(deck1.whatIsCard(0)?.name, "t1 of Test");
    expect(deck1.whatIsCard(1)?.name, null);
    expect(deck1.whatIsCard(2)?.name, null);  

    /// Test duplicate suits
    expect(() => Suit(" Test".trimLeft()), throwsA(isArgumentError), reason: "no duplicate Suits");
    
    /// Add second suit
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

    Deck deck3 = Deck.emptyDeck(true);
    Suit s3 = Suit("Test3");
    deck3.addNewCard(s1, "t1");
    deck3.addNewCard(s2, "t1");
    deck3.addNewCard(s3, "t1");
    // d1=[t1s1] d3=[t1s3, t1s2, t1s1]
    deck3.addNewCard(s3, "t2");
    // d1=[t1s1] d3=[t2s3, t1s3, t1s2, t1s1]
    expect(deck3.whatIsCard(0)?.name, "t2 of Test3");
    expect(deck3.whatIsCard(1)?.name, "t1 of Test3");
    expect(deck3.whatIsCard(2)?.name, "t1 of Test2");
    expect(deck3.whatIsCard(3)?.name, "t1 of Test");  
    expect(deck3.whatIsCard(4)?.name, null);  

    deck3.moveAllMatchingCardsToPile(deck1, rankName: "t1");
    // d1=[t1s1, t1s2, t1s3, t1s1] d3=[t2s2]
    expect(deck1.whatIsCard(0)?.name, "t1 of Test");
    expect(deck1.whatIsCard(1)?.name, "t1 of Test2");
    expect(deck1.whatIsCard(2)?.name, "t1 of Test3");
    expect(deck1.whatIsCard(3)?.name, "t1 of Test");  
    expect(deck1.whatIsCard(4)?.name, null);  
    expect(deck3.whatIsCard(0)?.name, "t2 of Test3");  
    expect(deck3.whatIsCard(1)?.name, null);  
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
