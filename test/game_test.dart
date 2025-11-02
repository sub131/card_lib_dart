// MIT License
// Copyright (c) 2025 by sub131
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_cards/common_decks.dart';
import 'package:playing_cards/pile_and_deck.dart';
import 'package:playing_cards/card_and_suit.dart';

void main() {

  int scoreBlackJack(CardPile pile) {
    int sum = 0;
    bool hasAce = false;
    for (Card card in pile.iterator) {
      if (card.rank > 10) {
        sum += 10;
      } else {
        sum += card.rank;
      }
      if (card.rank == 1) {
        hasAce = true;
      }
    }
    if (hasAce && sum <= 11) {
      sum += 10;
    }
    return sum;
  }
  test('Test Score blackjack', () {
    var deck = DefaultCardDeck();
    expect(Suit.numOfSuits, 4);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(scoreBlackJack(deck), (55+30)*4);

    var testNormal = CardPile('scoreTest');
    expect(scoreBlackJack(testNormal), 0);
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.diamonds, rankName:"two");
    expect(scoreBlackJack(testNormal), 2);
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.diamonds, rank:7);
    expect(scoreBlackJack(testNormal), 9);
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.diamonds, rank:1);
    expect(scoreBlackJack(testNormal), 20, reason: "Expect ace to count as 11 if <= 10"); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.spades, rank:1);
    expect(scoreBlackJack(testNormal), 21, reason: "Expect second ace to count as 1"); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rank:1);
    expect(scoreBlackJack(testNormal), 12, reason: "Expect all aces to count as 1 if > 10 "); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rank:9);
    expect(scoreBlackJack(testNormal), 21); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rank:11);
    expect(scoreBlackJack(testNormal), 31, reason: "Expect ranks > 10 to count as 10"); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rank:12);
    expect(scoreBlackJack(testNormal), 41, reason: "Expect ranks > 10 to count as 10"); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rankName:"king");
    expect(scoreBlackJack(testNormal), 51, reason: "Expect ranks > 10 to count as 10"); 

    testNormal.moveCardsToPile(deck);
    expect(scoreBlackJack(testNormal), 0);
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rank:1);
    expect(scoreBlackJack(testNormal), 11, reason: "Expect all aces to count as 1 if <= 10 "); 
    deck.moveFirstMatchingCardToPile(testNormal, suit:DefaultCardDeck.hearts, rankName:"queen");
    expect(scoreBlackJack(testNormal), 21, reason: "Testing blackjack"); 
    testNormal.reverse();
    expect(scoreBlackJack(testNormal), 21, reason: "Testing blackjack"); 
 });
 
  playBlackJack(Deck deck) {
    var size = deck.cards.length;
    expect(size, 52);
    expect(deck.length, 52);

    var player1 = CardPile('player1');
    var player2 = CardPile('player2');
    var player3 = CardPile('player3');
    var player4 = CardPile('player4');
    var dealer = CardPile('dealer');
    var players = [player1, player2, player3, player4, dealer];

    Card? topCard = deck.whatIsTopCard();
    Card? dealerCard1 = deck.whatIsCard(4);
    Card? dealerCard2 = deck.whatIsCard(9);

    deck.dealCards(players, 2);
    expect(dealer.whatIsTopCard(), dealerCard2);
    expect(dealer.whatIsCard(1), dealerCard1);
    expect(player1.whatIsCard(1), topCard);

    //Player1 hits until 21 or busts
    int score1 = scoreBlackJack(player1);
    while (score1 < 21) {
      //hit
      debugPrint('Player1 has $player1 = $score1 and hits');
      deck.moveTopCardToPile(player1);

      score1 = scoreBlackJack(player1);
    }
    expect(score1 >= 21, true);
    if (score1 <= 21) {
      debugPrint('Player1 has $player1 = $score1 and stays');
    } else {
      debugPrint('Player1 has $player1 = $score1 and has busted');
    }

    //Player 2 stays
    int score2 = scoreBlackJack(player2);
    if (score2 <= 21) {
      debugPrint('Player2 has $player2 = $score2 and stays');
    } else {
      debugPrint('Player2 has $player2 = $score2 and has busted');
    }
    expect(score2 <= 21, true, reason: "Player 2 isn't hitting so can't bust");

    //Player 3 doubles down
    int score3 = scoreBlackJack(player3);
    if (score3 < 21) {
      debugPrint('Player3 has $player3 = $score3 and doubles down');
      deck.moveTopCardToPile(player3);
      score3 = scoreBlackJack(player3);
    }
    if (score3 <= 21) {
      debugPrint('Player3 has $player3 = $score3 and stays');
    } else {
      debugPrint('Player3 has $player3 = $score3 and has busted');
    }

    //Player 4 hits until higher than dealer's showing card + 10
    int dealerVisible = dealer.whatIsCard(1)?.rank ?? 10;
    if (dealerVisible > 10) {
      dealerVisible = 10 + 10;
    } else if (dealerVisible == 1) {
      dealerVisible = 11+10;
    } else {
      dealerVisible = dealerVisible + 10;
    }
    int score4 = scoreBlackJack(player4);
    while (score4 < dealerVisible) {
      //hit
      debugPrint('Player4 has $player4 = $score4 and hits');
      deck.moveTopCardToPile(player4);

      score4 = scoreBlackJack(player4);
    }
    if (score4 <= 21) {
      debugPrint('Player4 has $player4 = $score4 and stays');
    } else {
      debugPrint('Player4 has $player4 = $score4 and has busted');
    }

    //dealer hits until 17
    int dealerScore = scoreBlackJack(dealer);
    while (dealerScore < 17) {
      //hit
      debugPrint('Dealer has $dealer = $dealerScore and hits');
      deck.moveTopCardToPile(dealer);

      dealerScore = scoreBlackJack(dealer);
    }
    if (dealerScore <= 21) {
      debugPrint('Dealer has $dealer = $dealerScore and stays');
    } else {
      debugPrint('Dealer has $dealer = $dealerScore and has busted');
    }

    //Print results
    players.remove(dealer);
    List<int> scores = [score1, score2, score3, score4];
    for (int i=0; i<players.length; i++) {
      if (scores[i] <= 21 && (dealerScore > 21 || scores[i] > dealerScore)) {
        //Didn't bust and either dealer busted or we beat them
        if (scores[i] == 21 && players[i].length==2) {
          debugPrint('Player${i+1} has won with a natural blackjack!');
        } else {
          debugPrint('Player${i+1} has won!');
        }
      } else if (scores[i] > 21 || (dealerScore <= 21 && scores[i] < dealerScore)) {
        //Busted or lost
        debugPrint('Player${i+1} has lost!');
      } else if (dealerScore == 21 && scores[i] == 21) { //Ties are left
        if (dealer.length == 2 && players[i].length > 2) {
          debugPrint('Player${i+1} has lost to the dealer\'s natural blackjack!');
        } else if (dealer.length > 2 && players[i].length == 2) {
          debugPrint('Player${i+1} has won with a natural blackjack!');
        } else if (dealer.length == 2 && players[i].length == 2) {
          debugPrint('Player${i+1} has tied, natural blackjack to natural blackjack!');
        } else {
          debugPrint('Player${i+1} has tied.');
        }
      } else { //Tied, but not at 21
        expect(scores[i], dealerScore, reason: "Tie requires scores to match");
        debugPrint('Player${i+1} has tied.');
      }
    }
  }

  test('Play blackjack random', () {
    var deck = DefaultCardDeck();

    expect(Suit.numOfSuits, 4);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(DefaultCardDeck.clubs.numOfRanks, 13);
    expect(DefaultCardDeck.spades.numOfRanks, 13);
    expect(DefaultCardDeck.diamonds.numOfRanks, 13);
    
    deck.shuffle();
    playBlackJack(deck);
  });
  test('Play blackjack all natural players, dealer 21', () {
    var deck = DefaultCardDeck();

    expect(Suit.numOfSuits, 4);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(DefaultCardDeck.clubs.numOfRanks, 13);
    expect(DefaultCardDeck.spades.numOfRanks, 13);
    expect(DefaultCardDeck.diamonds.numOfRanks, 13);
    
    //Stack the deck
    CardPile aces = CardPile('aces');
    CardPile kings = CardPile('kings');
    CardPile dealer = CardPile('dealer');
    deck.moveAllMatchingCardsToPile(aces, rank: 1);
    deck.moveAllMatchingCardsToPile(kings, rank: 13);
    deck.moveFirstMatchingCardToPile(dealer, rank: 12);
    deck.moveFirstMatchingCardToPile(dealer, rank: 2);
    deck.moveFirstMatchingCardToPile(dealer, rank: 9);

    dealer.moveTopCardToPile(deck); //Move 9
    dealer.moveTopCardToPile(deck); //Move 2
    kings.moveCardsToPile(deck); //Move kings
    dealer.moveTopCardToPile(deck); //Move queen
    aces.moveCardsToPile(deck);//Move aces

    //Should be ace, ace, ace, ace, queen (dealer)
    //          king, king, king, king, 2 (dealer) with 9 as next hit card    
    playBlackJack(deck);
  });
  test('Play blackjack almost all natural players, dealer natural', () {
    var deck = DefaultCardDeck();

    expect(Suit.numOfSuits, 4);
    expect(DefaultCardDeck.hearts.numOfRanks, 13);
    expect(DefaultCardDeck.clubs.numOfRanks, 13);
    expect(DefaultCardDeck.spades.numOfRanks, 13);
    expect(DefaultCardDeck.diamonds.numOfRanks, 13);
    
    //Stack the deck
    CardPile aces = CardPile('aces');
    CardPile kings = CardPile('kings');
    CardPile dealer = CardPile('dealer');
    CardPile otherPlayer = CardPile('otherPlayer');
    deck.moveAllMatchingCardsToPile(aces, rank: 1);
    deck.moveAllMatchingCardsToPile(kings, rank: 13);
    deck.moveFirstMatchingCardToPile(dealer, rank: 12);
    deck.moveFirstMatchingCardToPile(dealer, rank: 2);
    deck.moveFirstMatchingCardToPile(dealer, rank: 9);
    deck.moveFirstMatchingCardToPile(otherPlayer, rank: 2);
    deck.moveFirstMatchingCardToPile(otherPlayer, rank: 9);

    aces.moveTopCardToPile(deck); //Return one ace

    dealer.moveTopCardToPile(deck); //Move 9
    otherPlayer.moveTopCardToPile(deck); //Move 9
    dealer.moveTopCardToPile(deck); //Move 2
    kings.moveCardsToPile(deck); //Move kings
    dealer.moveTopCardToPile(deck); //Move queen
    aces.moveCardsToPile(deck);//Move aces
    otherPlayer.moveTopCardToPile(deck); //Move 2

    //Should be 2, ace, ace, ace, queen (dealer)
    //       king, king, king, king, 2 (dealer) with two 9s as next hit card    
    playBlackJack(deck);
  });

  test('Play poker with jokers', () {
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
    
    //@TODO
  });
}
