import 'package:flutter_test/flutter_test.dart';

import 'package:wwwy/game.dart';
import 'package:wwwy/card.dart';

void main() {
  Game calc = Game();
  calc.addOne(2);

  test('Creates one of each', () {
    String test= "Test";
    expect(Suit.numOfSuits, 0);
    
    Suit s1 = Suit(test);
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfCards, 0);
    Deck deck = Deck.emptyDeck(true);
    deck.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfCards, 1);
    
    deck.addNewCard(s1, "t1");
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfCards, 2, reason:"adding duplicate with allowDuplicates==true");

    expect(() => Suit(" Test".trimLeft()), throwsA(isArgumentError), reason: "no duplicate Suits");
    
    expect(Suit.numOfSuits, 1);
    expect(s1.numOfCards, 2);
    Suit s2 = Suit("Test2");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfCards, 0);
    
    Deck deck2 = Deck.emptyDeck(false);
    deck2.addNewCard(s2, "t1");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfCards, 1);
    deck2.addNewCard(s2, "t1");
    expect(Suit.numOfSuits, 2);
    expect(s2.numOfCards, 1, reason: 'Adding duplicate cards silently leaves it unchanged');  
  });
  test('Create default names, weapons and locations, picks random ones', () {
    Suit.resetSuits();

    var clueDeck = ClueDeck();
    var deck = clueDeck.createDeck();

    expect(Suit.numOfSuits, 3);
    
    expect(clueDeck.who.numOfCards, 6);
    expect(clueDeck.what.numOfCards, 6);
    expect(clueDeck.where.numOfCards, 9);
    Suit why = Suit("why");
    expect(Suit.numOfSuits, 4);
  
    deck.shuffle();
    var size = deck.cards.length;

    Card? who1 = deck.removeFirst(clueDeck.who);
    Card? what1 = deck.removeFirst(clueDeck.what);
    Card? where1 = deck.removeFirst(clueDeck.where);
    Card? why1 = deck.removeFirst(why);
    expect(deck.cards.length, size-3, reason: "Expect 3 removed");
    print('$who1 + $what1 + $where1 + $why1');

    expect(who1?.suit, clueDeck.who);
    expect(what1?.suit, clueDeck.what);
    expect(where1?.suit, clueDeck.where);
    expect(why1?.suit, null, reason: "Expect no motives in default deck");
  });

  test('Create default names, weapons and locations, picks random ones', () {
    Suit.resetSuits();

    var cardDeck = DefaultCardDeck();
    var deck = cardDeck.createDeck();

    expect(Suit.numOfSuits, 4);
    expect(cardDeck.hearts.numOfCards, 13);
    expect(cardDeck.clubs.numOfCards, 13);
    expect(cardDeck.spades.numOfCards, 13);
    expect(cardDeck.diamonds.numOfCards, 13);
    
    deck.shuffle();
    var size = deck.cards.length;

    Card? h1 = deck.removeFirst(cardDeck.hearts);
    Card? c1 = deck.removeFirst(cardDeck.clubs);
    Card? s1 = deck.removeFirst(cardDeck.spades);
    Card? d1 = deck.removeFirst(cardDeck.diamonds);
    expect(deck.cards.length, size-4, reason: "Expect 4 removed");
    print('$h1 + $c1 + $s1 + $d1');

    expect(h1?.suit, cardDeck.hearts);
    expect(c1?.suit, cardDeck.clubs);
    expect(s1?.suit, cardDeck.spades);
    expect(d1?.suit, cardDeck.diamonds);
  });
}
