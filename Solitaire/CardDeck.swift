//
//  CardDeck.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

class CardDeck {
  
  var unusedCards: [Card]
  var usedCards = [Card]()
  var deckName: String
  var cardWidth: CGFloat? {
    if unusedCards.count > 0 {
      return unusedCards[0].size.width
    } else if usedCards.count > 0 {
      return usedCards[0].size.width
    } else {
      return nil
    }
  }
  var cardHeight: CGFloat? {
    if unusedCards.count > 0 {
      return unusedCards[0].size.height
    } else if usedCards.count > 0 {
      return usedCards[0].size.height
    } else {
      return nil
    }
  }
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(deckName: String, initialCards: [Card]? = nil) {
    if let initialCards = initialCards {
      unusedCards = initialCards
    } else {
      unusedCards = [Card]()
    }
    self.deckName = deckName
  } // init
  
  func shuffleDeck() {
    var tempDeck = unusedCards + usedCards
    unusedCards.removeAll()
    usedCards.removeAll()
    while tempDeck.count > 0 {
      let cardPos = Int.random(tempDeck.count)
      let shuffledCard = tempDeck.remove(at: cardPos)
      unusedCards.append(shuffledCard)
    }
    print("Deck \(deckName) shuffled")
  } // shuffleDeck
  
  func getCard() -> Card? {
    if let poppedCard = unusedCards.popLast() {
      usedCards.append(poppedCard)
      return poppedCard
    }
    return nil
  } // drawCard
  
  func get3Cards() -> [Card]? {
    var threeCards = [Card]()
    for _ in 0...2 {
      if let getCard = getCard() {
        threeCards.append(getCard)
      } else {
        break
      }
    } // get (up to) 3 cards
    return (threeCards.count > 0) ? threeCards : nil
  } // get3Cards
  
  func add(card: Card) {
    if let foundIndex = usedCards.index(of: card) {
      usedCards.remove(at: foundIndex)
      unusedCards.append(card)
    }
  } // add:card
  
  func add(cards: [Card]) {
    for card in cards {
      add(card: card)
    }
  } // add:cards
  
  func topCard() -> Card? {
    if let card = unusedCards.last {
      return card
    } else {
      return nil
    }
  } // topCard

  
  
  
  
  
  
  
  
} // CardDeck






