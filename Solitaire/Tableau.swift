//
//  Tableau.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

enum PileType: Int {
  case Up = 0
  case Down
}

class Tableau {
  
  
  // MARK: - Properties
  var basePosition = CGPoint.zero
  var pileUp = [Card]()
  var pileDown = [Card]()
  var lastPosition: CGPoint {
    if let lastUpCardPosition = pileUp.last?.position {
      return lastUpCardPosition
    } else if let lastDownCardPostion = pileDown.last?.position {
      return lastDownCardPostion
    } else {
      return basePosition
    }
  } // lowestPosition
  var totalCards: Int {
    return pileDown.count + pileUp.count
  }
  var isEmpty: Bool {
    return totalCards == 0 ? true : false
  }
  var upCardSpacing: CGFloat
  var downCardSpacing: CGFloat
  var zBasePosition = CGFloat(100)
  
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(basePosition: CGPoint, cardSpacing: CGFloat = 0, downSpacing: CGFloat? = nil) {
    self.basePosition = basePosition
    self.upCardSpacing = cardSpacing
    if let downSpacing = downSpacing {
      self.downCardSpacing = downSpacing
    } else {
      self.downCardSpacing = self.upCardSpacing
    }
  } // init
  
  
  // MARK: - Functions
  
  func add(card: Card, withWiggle wiggle: Bool = false, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    
    let initialPosition = card.position
    var finalPosition = lastPosition
    
    if !isEmpty {
      let cardSpacing = (card.facing == .Front) ? upCardSpacing : downCardSpacing
      finalPosition.y -= cardSpacing
    }

    // Initiall move card to it's final position
    //   because subequent cards depend upon this cards final position
    card.position = finalPosition
    
    if card.facing == .Front {
      pileUp.append(card)
    } else {
      pileDown.append(card)
    }
    let zPositionFinal = zBasePosition + (10 * CGFloat(totalCards))

    // Need to move card (temporarily) back to initial position
    //   so we can animate from initial pos to final pos
    let moveToStart = SKAction.move(to: initialPosition, duration: 0)
    let delayAction = SKAction.wait(forDuration: delay)
    let moveToFinal = SKAction.move(to: finalPosition, duration: animSpeed)
    moveToFinal.timingMode = .easeOut
    let runAfter = SKAction.run {
      card.zPosition = zPositionFinal
      if wiggle && (card.facing == .Front) {
        self.wiggleCard(card: card, withAnimSpeed: animSpeed)
      }
    }
    card.run(SKAction.sequence([moveToStart, delayAction, moveToFinal, runAfter]))

  } // add:card
  
  func add(cards: [Card], withWiggle wiggle: Bool = false, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    guard cards.count > 0 else {
      fatalError("No cards provided to add to pile")
    }
    
    for card in cards {
      add(card: card, withWiggle: wiggle, withAnimSpeed: animSpeed, delay: delay)
    } // loop through all cards
  } // add:cards
  
  private func wiggleCard(card: Card, withAnimSpeed animSpeed: TimeInterval = 0) {
    let origPos = card.position
    let moveDown = SKAction.moveBy(x: 0,
                                   y: -card.size.height / 3,
                                   duration: animSpeed / 2)
    moveDown.timingMode = .easeOut
    let moveUp = SKAction.move(to: origPos, duration: animSpeed / 2)
    moveUp.timingMode = .easeOut
    card.run(SKAction.sequence([moveDown, moveUp]))
  } // wiggleTopCard

  func getCard(fromPile pile: PileType) -> Card? {
    switch pile {
    case .Up:
      if pileUp.count > 0 {
        return pileUp.popLast()
      }
    case .Down:
      if pileDown.count > 0 {
        return pileDown.popLast()
      }
    }
    return nil
  } // getCard:fromPile
  
  func getCards(fromPile pile: PileType, startingWith card: Card) -> [Card]? {
    switch pile {
    case .Up:
      if card.facing != .Front { return nil }
      
      if let cardIndex = pileUp.index(of: card) {
        var returnArray = [Card]()
        for _ in cardIndex..<pileUp.count {
          returnArray.insert(pileUp.popLast()!, at: 0)
          returnArray[0].onStack = nil
          returnArray[0].stackNumber = nil
        }
        return returnArray
      } else {
        return nil
      }
    case .Down:
      if card.facing != .Back { return nil }
      
      if let cardIndex = pileDown.index(of: card) {
        var returnArray = [Card]()
        for _ in cardIndex..<pileDown.count {
          returnArray.insert(pileDown.popLast()!, at: 0)
          returnArray[0].onStack = nil
          returnArray[0].stackNumber = nil
        }
        return returnArray
      } else {
        return nil
      }
    } // switch pile
  } // getCards:fromPile
  
  func canMoveHere(cards: [Card], andCheckDistance checkDisatance: Bool = false) -> Bool {
    guard cards.count > 0 else {
      fatalError("Trying to evaluate empty card stack")
    }
    
    // Determine if cards are in right area to go on this stack
    if checkDisatance {
      // Check x position
      let xDistance = abs(cards[0].position.x - lastPosition.x)
      if xDistance > (cards[0].size.width / 2) {
        return false
      }
      // Check y position
      if cards[0].position.y > (basePosition.y + (cards[0].size.height / 2)) {
        return false
      }
      if cards[0].position.y < (lastPosition.y - cards[0].size.height) {
        return false
      }
    }
    
    // Check if card rules allow move to this tableau
    // Can't stack aces
    if cards[0].value == 1 {
      return false
    }
    // Can only stack kings on open tableau
    if (totalCards == 0) && (cards[0].value == 13) {
      return true
    } else if (totalCards == 0) {
      return false
    }
    // Can only stack one lower value of opposite color
    guard pileUp.count > 0 else {
      fatalError("Only pile down cards on tableau")
    }
    if (cards[0].value == pileUp.last!.value - 1) && (cards[0].suitColor != pileUp.last!.suitColor) {
      return true
    }

    return false
  } // canMoveHere
  
  func flipLowestDownCard(withAnimation doAnim: Bool = false, animSpeed: TimeInterval = 0) {
    // If moving cards from middle of up pile then don't try to flip down pile card
    if pileUp.count != 0  {
      return
    }
    
    if let poppedCard = pileDown.popLast() {
      poppedCard.flipOver(withAnimation: doAnim, animSpeed: animSpeed)
      pileUp.append(poppedCard)
    }
  } // flipLowestDownCard
  
  func undoFlipCardDown(withAnimation doAnim: Bool = false, animSpeed: TimeInterval = 0) {
    // If more than one card facing up, then don't flip anything over
    if pileUp.count != 1 {
      return
    }
    
    if let poppedCard = pileUp.popLast() {
      poppedCard.flipOver(withAnimation: doAnim, animSpeed: animSpeed)
      pileDown.append(poppedCard)
    }
  } // undoFlipCardDown

  func printPileUp() {
    print("\nTableau Up:")
    printCards(cards: pileUp)
  }
  func printPileDown() {
    print("\nTableau Down:")
    printCards(cards: pileDown)
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
  
  
} // Tableau




