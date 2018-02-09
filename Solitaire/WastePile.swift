//
//  WastePile.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/4/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class WastePile {
  
  
  // MARK: - Properties
  private var basePosition = CGPoint.zero
  private var baseZPosition = CGFloat(10)
  private var pile = [Card]()
  private var spacing = CGFloat(0)
  
  private var threeUpPositions = [CGPoint]()
  private var threeUpCards = [Card]()
  
  private struct AnimateCard {
    var card: Card
    var origPos: CGPoint
  }
  private var animateCards = [AnimateCard]()
  
  var count: Int {
    return pile.count
  }
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(basePosition: CGPoint, cardSpacing spacing: CGFloat) {
    self.basePosition = basePosition
    self.spacing = spacing
    threeUpPositions.append(basePosition)
    var nextPostion = basePosition + CGPoint(x: spacing, y: 0)
    threeUpPositions.append(nextPostion)
    nextPostion += CGPoint(x: spacing, y: 0)
    threeUpPositions.append(nextPostion)
  } // init
  
  
  // MARK: - Functions
  
  func add(cards: [Card], withWiggle wiggle: Bool = false, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    guard ((cards.count > 0) && (cards.count <= 3)) else {
      fatalError("Can only add between 1 and 3 cards to Waste Pile")
    }
    animateCards.removeAll()
    for card in cards {
      
      let zAdder = CGFloat(10)
      var finalZPosition: CGFloat
      if let topCard = pile.last {
        finalZPosition = topCard.zPosition + zAdder
      } else {
        finalZPosition = baseZPosition
      }
      
      card.zPosition = finalZPosition
      
      let animateCard = AnimateCard(card: card,
                                    origPos: card.position)
      
      addToThreeUp(card: card)
      
      animateCards.append(animateCard)

      card.onStack = .Waste
      pile.append(card)
    } // loop through (up to 3) cards

    for i in 0..<animateCards.count {
      // Animate (need to add card flipping over animation !!!)
      let finalDelay = delay + (animSpeed * TimeInterval(i))
      let finalPosition = animateCards[i].card.position
      let moveToStart = SKAction.move(to: animateCards[i].origPos, duration: 0)
      let delayAction = SKAction.wait(forDuration: finalDelay)
      let moveToFinal = SKAction.move(to: finalPosition, duration: animSpeed)
      moveToFinal.timingMode = .easeOut
      let runWhileMoving = SKAction.run {
        if self.animateCards[i].card.facing == .Back {
          self.animateCards[i].card.flipOver(withAnimation: true, animSpeed: animSpeed)
        }
      }
      let moveCombo = SKAction.group([moveToFinal, runWhileMoving])
      self.animateCards[i].card.run(SKAction.sequence([moveToStart, delayAction, moveCombo]))
    } // loop through (up to 3) cards
    print("Added thee cards to Waste Pile")
  } // add:card
  
  private func addToThreeUp(card: Card) {
    if threeUpCards.count == 3 {
      for i in 0...1 {
        threeUpCards[i] = threeUpCards[i+1]
        threeUpCards[i].position = threeUpPositions[i]
      }
      let _ = threeUpCards.popLast()!
    }
    card.position = threeUpPositions[threeUpCards.count]
    threeUpCards.append(card)
  } // addToThreeUp
  
  func bumpThreeUp(withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) {
    if (pile.count > 2) && (threeUpCards.count == 2) {
      let animTime = animSpeed / 2
      let newThreeUpCardIndex = pile.count - 3
      threeUpCards.insert(pile[newThreeUpCardIndex], at: 0)
      for i in (1...2).reversed() {
        let finalDelay = delay + (animTime * TimeInterval(2 - i))
        let finalPosition = threeUpPositions[i]
        let delayAction = SKAction.wait(forDuration: finalDelay)
        let moveToFinal = SKAction.move(to: finalPosition, duration: animTime)
        moveToFinal.timingMode = .easeOut
        let runFinal = SKAction.run {
          self.threeUpCards[i].position = finalPosition
        }
        threeUpCards[i].run(SKAction.sequence([delayAction, moveToFinal, runFinal]))
      } // loop through threeUp cards
    } // proper card config to bump the ThreeUp stack
  } // bumpThreeUp
  
  func getCard() -> Card? {
    if let poppedCard = pile.popLast() {
      poppedCard.onStack = nil
      poppedCard.stackNumber = nil
      if threeUpCards.count > 0 {
        let _ = threeUpCards.popLast()
      }
      return poppedCard
    }
    return nil
  } // getCard:fromPile
  
  func resetPile(toPosition stockPosition: CGPoint, withAnimSpeed animSpeed: TimeInterval = 0, delay: TimeInterval = 0) -> [Card]? {
    if pile.count > 0 {
      let animTime = animSpeed / TimeInterval(min(pile.count, 10))
      var newZPos = CGFloat(10)
      var newDelay = delay
      for card in pile.reversed() {
        let delayAction = SKAction.wait(forDuration: newDelay)
        let moveTo = SKAction.move(to: stockPosition, duration: animTime)
        let runWhileMoving = SKAction.run {
          card.flipOver(withAnimation: true, animSpeed: animTime)
        }
        let moveCombo = SKAction.group([moveTo, runWhileMoving])
        let runFinal = SKAction.run {
          card.position = stockPosition
          card.zPosition = newZPos
          card.onStack = .Stock
        }
        card.run(SKAction.sequence([delayAction, moveCombo, runFinal]))
        newZPos += 10
        newDelay += animTime
      } // loop through all cards (in reverse order)
      let returnArray = Array(pile.reversed())
      pile.removeAll()
      threeUpCards.removeAll()
      return returnArray
    } else {
      return nil
    }
  } // reset pile
  
  
} // WastePile











