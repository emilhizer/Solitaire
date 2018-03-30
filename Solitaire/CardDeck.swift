//
//  CardDeck.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

class CardDeck: NSObject, NSCoding {
  
  // En/Decoding Keys
  enum Keys {
    static var unusedCards = "CardDeck.unusedCards"
    static var usedCards = "CardDeck.usedCards"
    static var deckName = "CardDeck.deckName"
  } // Keys
  
  var unusedCards = [Card]()
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
  var totalCardsInDeck: Int {
    return unusedCards.count + usedCards.count
  }
  
  // MARK: - Save (encode) data
  func encode(with aCoder: NSCoder) {
    print("encode -- CardDeck")
    aCoder.encode(unusedCards, forKey: Keys.unusedCards)
    aCoder.encode(usedCards, forKey: Keys.usedCards)
    aCoder.encode(deckName, forKey: Keys.deckName)
  }
  
  // MARK: - Init
  // Note can use "convenience" if we need to call self.init after we decode some setup data
  //  required convenience init?(coder aDecoder: NSCoder) {
  required init?(coder aDecoder: NSCoder) {
    print("init(coder:) -- CardDeck")
    deckName = aDecoder.decodeObject(forKey: Keys.deckName) as! String
    unusedCards = aDecoder.decodeObject(forKey: Keys.unusedCards) as! [Card]
    usedCards = aDecoder.decodeObject(forKey: Keys.usedCards) as! [Card]
  }

  init(deckName: String, initialCards: [Card]? = nil) {
    print("Init: CardDeck")
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

  func copy() -> CardDeck {
    var copyDeck = [Card]()
    
    for card in unusedCards {
      let copyCard = card.copy() as! Card
      copyDeck.append(copyCard)
    }
    return CardDeck(deckName: self.deckName,
                    initialCards: copyDeck)
  } // copy
  
  func printUnusedCards() {
    print("\nUnused Cards (on Stock):")
    printCards(cards: unusedCards)
  }
  func printUsedCards() {
    print("\nUsed Cards (in play):")
    printCards(cards: usedCards)
  }
  
  private func printCards(cards: [Card]) {
    if cards.count > 0 {
      for i in 0..<cards.count {
        let indexS = String(format: "%02d", i)
        print("\(indexS): \(cards[i].getCardString())")
      }
    } else {
      print("Empty")
    }
  }

  
  
  
  
  
  
} // CardDeck






