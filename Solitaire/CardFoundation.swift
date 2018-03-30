//
//  CardFoundation.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class CardFoundation: NSObject, NSCoding {
  
  // En/Decoding Keys
  enum Keys {
    static var basePosition = "CardFoundation.basePosition"
    static var pile = "CardFoundation.pile"
    static var soundFX = "CardFoundation.soundFX"
  } // Keys
  
  // MARK: - Properties
  var basePosition = CGPoint.zero
  var pile = [Card]()
  
  var soundFX: SKAction?
  
  // MARK: - Save data
  func encode(with aCoder: NSCoder) {
    print("encode -- CardFoundation")
    aCoder.encode(basePosition, forKey: Keys.basePosition)
    aCoder.encode(pile, forKey: Keys.pile)
    // Note soundFX is a run-block and may not be encodable
    //   may need to reapply soundFX at GameScene level back into this object
    //   when restoring from save (decoding)
//    if let optionalSoundFX = soundFX {
//      aCoder.encode(optionalSoundFX, forKey: Keys.soundFX)
//    }
    // Not encoding/decoding animations - let's see what happens...
  } // encode
  
  // MARK: - Init
  required init?(coder aDecoder: NSCoder) {
    print("init(coder:) -- CardFoundation")
    basePosition = aDecoder.decodeCGPoint(forKey: Keys.basePosition)
    pile = aDecoder.decodeObject(forKey: Keys.pile) as! [Card]
//    soundFX = aDecoder.decodeObject(forKey: Keys.soundFX) as? SKAction
  } // init:coder

  init(basePosition: CGPoint) {
    self.basePosition = basePosition
  }
  
  
  // MARK: - Functions
  
  func add(card: Card, withWiggle wiggle: Bool = false, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    // Need to pre / post-move card because the data-location
    //  of the card's final location needs to be available immediately
    //  to the game play engine (i.e., to evaluate where to "jump" cards
    //  "from position" if game is won
    
    let initialPosition = card.position
    let finalPosition = basePosition

    card.position = finalPosition

    pile.append(card)
    let finalZPosition = CGFloat(self.pile.count * 10)
    
    let moveToStart = SKAction.move(to: initialPosition, duration: 0)
    let delayAction = SKAction.wait(forDuration: delay)
    let moveToFinal = SKAction.move(to: finalPosition, duration: animSpeed)
    moveToFinal.timingMode = .easeOut
    var groupMove: SKAction
    if let soundFX = soundFX, !wiggle {
      groupMove = SKAction.group([moveToFinal, soundFX])
    } else {
      groupMove = moveToFinal
    }
    let runAfter = SKAction.run {
      card.zPosition = finalZPosition
      if wiggle {
        self.wiggleTopCard(withAnimSpeed: animSpeed)
      }
    }
    card.run(SKAction.sequence([moveToStart, delayAction, groupMove, runAfter]))
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
//      poppedCard.onStack = nil
//      poppedCard.stackNumber = nil
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

  func printCards() {
    print("\nFoundation:")
    printCards(cards: pile)
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

  
  
  
} // CardFoundation
