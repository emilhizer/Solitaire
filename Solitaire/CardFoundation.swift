//
//  CardFoundation.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class CardFoundation {
  
  
  // MARK: - Properties
  var basePosition = CGPoint.zero
  var pile = [Card]()
  
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(basePosition: CGPoint) {
    self.basePosition = basePosition
  }
  
  
  // MARK: - Functions
  
  func add(card: Card, withWiggle wiggle: Bool = false, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    let initialPosition = card.position
    let finalPosition = basePosition

    card.position = finalPosition

    var finalZPosition = CGFloat(0)
    if let currentZTop = pile.last?.zPosition {
      finalZPosition = currentZTop + CGFloat(10)
    }
    
    pile.append(card)
    
    let moveToStart = SKAction.move(to: initialPosition, duration: 0)
    let delayAction = SKAction.wait(forDuration: delay)
    let moveToFinal = SKAction.move(to: finalPosition, duration: animSpeed)
    moveToFinal.timingMode = .easeOut
    let runAfter = SKAction.run {
      card.zPosition = finalZPosition
      if wiggle {
        self.wiggleTopCard(withAnimSpeed: animSpeed)
      }
    }
    card.run(SKAction.sequence([moveToStart, delayAction, moveToFinal, runAfter]))
  } // add:card
  
  private func wiggleTopCard(withAnimSpeed animSpeed: TimeInterval = 0) {
    if let wiggleCard = pile.last {
      let origPos = wiggleCard.position
      let moveDown = SKAction.moveBy(x: 0,
                                      y: -wiggleCard.size.height / 3,
                                      duration: animSpeed / 2)
      moveDown.timingMode = .easeOut
      let moveUp = SKAction.move(to: origPos, duration: animSpeed / 2)
      moveUp.timingMode = .easeOut
      wiggleCard.run(SKAction.sequence([moveDown, moveUp]))
    }
  } // wiggleTopCard

  func getCard() -> Card? {
    if let poppedCard = pile.popLast() {
      poppedCard.onStack = nil
      poppedCard.stackNumber = nil
      return poppedCard
    }
    return nil
  } // getCard:fromPile
    
  func canMoveHere(card: Card, andCheckDistance checkDisatance: Bool = false) -> Bool {
    
    // Determine if cards are in right area to go on this foundation
    if checkDisatance {
      // Check x position
      let xDistance = abs(card.position.x - basePosition.x)
      if xDistance > (card.size.width / 2) {
        return false
      }
      // Check y position
      if card.position.y > (basePosition.y + (card.size.height / 2)) {
        return false
      }
      if card.position.y < (basePosition.y - card.size.height) {
        return false
      }
    }
    
    // Check if card rules allow move to this foundation
    // Only ace allowed on empty foundation
    if (pile.isEmpty) && (card.value == 1) {
      return true
    } else if pile.isEmpty {
      return false
    }
    
    // Can only stack next value of same suit
    if (card.value == pile.last!.value + 1) && (card.suit == pile.last!.suit) {
      return true
    }
    
    return false
  } // canMoveHere

  
  
  
  
} // CardFoundation
