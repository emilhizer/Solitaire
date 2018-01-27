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
  
  func drawCard() -> Card? {
    if unusedCards.count > 0 {
      let drawnCard = unusedCards.remove(at: 0)
      usedCards.append(drawnCard)
      return drawnCard
    } else {
      return nil
    }
  } // drawCard
  
  func topCard() -> Card? {
    if unusedCards.count > 0 {
      let card = unusedCards[0]
      return card
    } else {
      return nil
    }
  } // topCard

  
  
  
  
  
  
  
  
} // CardDeck






