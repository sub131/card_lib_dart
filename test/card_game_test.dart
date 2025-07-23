// MIT License
// Copyright (c) 2025 by sub131
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_cards/common_decks.dart';
import 'package:playing_cards/pile_and_deck.dart';
import 'package:playing_cards/card_and_suit.dart';

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
    Deck deck1 = Deck.emptyDeck();
    deck1.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1);
    
    deck1.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfRanks, 1, reason:"adding duplicate doesn't increment rank");
    expect(deck1.length, 2, reason: 'Adding duplicate');  
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
    
    Deck deck2 = Deck.emptyDeck();
    Suit s3 = Suit("Test3");
    deck2.addNewCard(s1, "t1");
    deck2.addNewCard(s2, "t1");
    deck2.addNewCard(s3, "t1");
    // d1=[t1s1] d3=[t1s3, t1s2, t1s1]
    deck2.addNewCard(s3, "t2");
    // d1=[t1s1] d3=[t2s3, t1s3, t1s2, t1s1]
    expect(deck2.whatIsCard(0)?.name, "t2 of Test3");
    expect(deck2.whatIsCard(1)?.name, "t1 of Test3");
    expect(deck2.whatIsCard(2)?.name, "t1 of Test2");
    expect(deck2.whatIsCard(3)?.name, "t1 of Test");  
    expect(deck2.whatIsCard(4)?.name, null);  

    deck2.moveAllMatchingCardsToPile(deck1, rankName: "t1");
    // d1=[t1s1, t1s2, t1s3, t1s1] d3=[t2s2]
    expect(deck1.whatIsCard(0)?.name, "t1 of Test");
    expect(deck1.whatIsCard(1)?.name, "t1 of Test2");
    expect(deck1.whatIsCard(2)?.name, "t1 of Test3");
    expect(deck1.whatIsCard(3)?.name, "t1 of Test");  
    expect(deck1.whatIsCard(4)?.name, null);  
    expect(deck2.whatIsCard(0)?.name, "t2 of Test3");  
    expect(deck2.whatIsCard(1)?.name, null);  
  });

  test('Create default names, weapons and locations, picks random ones', () {
    int prevSuitCount = Suit.numOfSuits;
    var deck = ClueDeck();

    expect(Suit.numOfSuits, 3+prevSuitCount);
    
    expect(ClueDeck.who.numOfRanks, 6);
    expect(ClueDeck.what.numOfRanks, 6);
    expect(ClueDeck.where.numOfRanks, 9);
    Suit why = Suit("why");
    expect(Suit.numOfSuits, 4+prevSuitCount);
  
    deck.shuffle();
    var size = deck.cards.length;

    Card? who1 = deck.removeFirstMatchingCard(suit: ClueDeck.who);
    Card? what1 = deck.removeFirstMatchingCard(suit: ClueDeck.what);
    Card? where1 = deck.removeFirstMatchingCard(suit: ClueDeck.where);
    Card? why1 = deck.removeFirstMatchingCard(suit: why);
    expect(deck.cards.length, size-3, reason: "Expect 3 removed");
    debugPrint('$who1 + $what1 + $where1 + $why1');

    expect(who1?.suit, ClueDeck.who);
    expect(what1?.suit, ClueDeck.what);
    expect(where1?.suit, ClueDeck.where);
    expect(why1?.suit, null, reason: "Expect no motives in default deck");
  });

  test('Create default 52 card deck, picks random ones', () {
    int prevSuitCount = Suit.numOfSuits;
    var deck = DefaultCardDeck();

    expect(Suit.numOfSuits, 4+prevSuitCount);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(DefaultCardDeck.clubs.numOfRanks, 13);
    expect(DefaultCardDeck.spades.numOfRanks, 13);
    expect(DefaultCardDeck.diamonds.numOfRanks, 13);
    
    deck.shuffle();
    var size = deck.cards.length;
    expect(size, 52);
    expect(deck.length, 52);

    Card? h1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.hearts);
    Card? c1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.clubs);
    Card? s1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.spades);
    Card? d1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.diamonds);
    expect(deck.cards.length, size-4, reason: "Expect 4 removed");
    debugPrint('$h1 + $c1 + $s1 + $d1');

    expect(h1?.suit, DefaultCardDeck.hearts);
    expect(c1?.suit, DefaultCardDeck.clubs);
    expect(s1?.suit, DefaultCardDeck.spades);
    expect(d1?.suit, DefaultCardDeck.diamonds);
  });

  test('Create default 52+jokers card deck, picks random ones', () {
    int prevSuitCount = Suit.numOfSuits;
    var deck = DefaultCardDeckWithJokers();

    expect(Suit.numOfSuits, 1+prevSuitCount);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(DefaultCardDeck.clubs.numOfRanks, 13);
    expect(DefaultCardDeck.spades.numOfRanks, 13);
    expect(DefaultCardDeck.diamonds.numOfRanks, 13);
    expect(DefaultCardDeckWithJokers.jokers.numOfRanks, 2);
    
    deck.shuffle();
    var size = deck.cards.length;    
    expect(size, 54);
    expect(deck.length, 54);

    Card? h1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.hearts);
    Card? c1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.clubs);
    Card? s1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.spades);
    Card? d1 = deck.removeFirstMatchingCard(suit: DefaultCardDeck.diamonds);
    Card? j1 = deck.removeFirstMatchingCard(suit: DefaultCardDeckWithJokers.jokers);
    expect(deck.cards.length, size-5, reason: "Expect 4 removed");
    debugPrint('$h1 + $c1 + $s1 + $d1 + $j1');
    
    expect(h1?.suit, DefaultCardDeck.hearts);
    expect(c1?.suit, DefaultCardDeck.clubs);
    expect(s1?.suit, DefaultCardDeck.spades);
    expect(d1?.suit, DefaultCardDeck.diamonds);
    expect(j1?.suit, DefaultCardDeckWithJokers.jokers);
    
    Card? j2 = deck.removeFirstMatchingCard(suit: DefaultCardDeckWithJokers.jokers);
    Card? jn = deck.removeFirstMatchingCard(suit: DefaultCardDeckWithJokers.jokers);
    expect(j2?.suit, DefaultCardDeckWithJokers.jokers);
    expect(jn?.suit, null);    
  });

  test('Test CardPile functionality', () {
    int prevSuitCount = Suit.numOfSuits;
    int cardsLeft = 54;
    var deck = DefaultCardDeckWithJokers();
    expect(Suit.numOfSuits, prevSuitCount);

    CardPile discard = CardPile();
    CardPile hand1 = CardPile();
    CardPile hand2 = CardPile();

    expect(deck.length, cardsLeft);
    expect(discard.length, 0);
    expect(hand1.length, 0);
    expect(hand2.length, 0);

    Suit s1 = deck.whatIsTopCard()!.suit;
    expect(s1, DefaultCardDeckWithJokers.jokers);
    
    // Deal 2 jokers to discard
    int cardsDelt = deck.dealCardsToPile(discard, 2);
    expect(cardsDelt, 2);
    cardsLeft -= cardsDelt;
    expect(deck.length, cardsLeft);
    expect(discard.length, 2);
    expect(hand1.length, 0);
    expect(hand2.length, 0);
    for (int i=0; i<2; i++) {
      expect(discard.whatIsCard(i)!.suit, s1);
    }

    // Check order of deal
    List<Card> top4 = [];
    for (int i=0; i<4; i++) {
      top4.add(deck.whatIsCard(i)!);
    }
    cardsDelt = deck.dealCards([hand1, hand2], 2);
    cardsLeft -= cardsDelt;
    expect(cardsDelt, 4);
    expect(deck.length, cardsLeft);
    expect(hand1.whatIsCard(1), top4[0]); // Former top card is bottom of hand1
    expect(hand2.whatIsCard(1), top4[1]); // Next card is bottom of hand2
    expect(hand1.whatIsCard(0), top4[2]); // Next card is top of hand1
    expect(hand2.whatIsCard(0), top4[3]); // Last card is top of hand2

    hand1.reverse(); // Swap order
    expect(hand1.whatIsCard(1), top4[2]); // Former top card is bottom of hand1
    expect(hand1.whatIsCard(0), top4[0]); // Next card is top of hand1

    // Test shuffle
    int trials = 0;
    while (trials < 100 && hand2.whatIsTopCard() == top4[3]) {
      hand2.shuffle();
      trials++;
    }
    expect(trials, greaterThan(0));
    
    // Try to deal more than cards left
    cardsDelt = deck.dealCardsToPile(discard, cardsLeft+1);
    expect(cardsDelt, cardsLeft);
    cardsLeft -= cardsDelt;
    expect(cardsLeft, 0);
    expect(deck.length, cardsLeft);

    // Remove
    Suit s2 = top4[0].suit;
    expect(hand1.removeTopCard(), top4[0]);
    expect(hand1.removeCard(1), null); 
    expect(hand1.removeCard(0), top4[2]);
    expect(hand1.isCardPresent(suit: s2), false);

    hand1.addCard(top4[0]);
    hand1.addCard(top4[2]);

    expect(hand1.moveCardToPile(hand2, 1), true);
    expect(hand1.moveCardToPile(hand2, 1), false); //Only one card
    expect(hand1.moveTopCardToPile(hand2), true);
    expect(hand1.moveTopCardToPile(hand2), false); //No cards left

    expect(hand2.length, 4);
    expect(hand2.moveCardsToPile(discard), true);

    expect(deck.length, 0);
    expect(discard.length, 54);
    expect(hand1.length, 0);
    expect(hand2.length, 0);

  });

  test('Test Deck functionality', () {
    DefaultCardDeck deck = DefaultCardDeck();
    
    expect(deck.addedCards.length, 52);
    expect(() => deck.addedCards.clear(), throwsUnsupportedError);
    expect(() => deck.addedCards.shuffle(), throwsUnsupportedError);
    
    CardPile dup = deck.duplicate();
    expect(dup.length, 52);
    for (int i=0; i< dup.length; i++) {
      expect(dup.whatIsCard(i), deck.whatIsCard(i));
    }
    expect(deck.rankName(DefaultCardDeck.hearts, 2), "two");
    expect(deck.rankName(DefaultCardDeck.clubs, 13), "king");
    expect(deck.cardName(DefaultCardDeck.diamonds, 5), "five of diamonds");
    expect(deck.cardName(DefaultCardDeck.spades, 11), "jack of spades");

    expect(deck.cardByRankName(DefaultCardDeck.hearts, "two")?.rank, 2);
    expect(deck.cardByRankName(DefaultCardDeck.clubs, "king")?.rank, 13);
    expect(deck.cardByRank(DefaultCardDeck.diamonds, 5)?.name, "five of diamonds");
    expect(deck.cardByRank(DefaultCardDeck.spades, 11)?.name, "jack of spades");
  });
}
