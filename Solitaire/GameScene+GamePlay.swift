//
//  GameScene+GamePlay.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  
  // MARK: - Rules
  func canMove(card: Card) -> Bool {
    if let stackType = card.onStack {
      switch stackType {
      case .Tableau:
        if let _ = card.stackNumber, card.facing == .Front {
          return true
        }
      case .Foundation:
        if let _ = card.stackNumber {
          return true
        }
      case .Stock:
        return true
      case .Waste:
        return true
      }
    }
    return false
  } // canMove:card
  
  // MARK: - Pile Movement
  func movePile(withStartingCard card: Card, toPoint pos: CGPoint) {
    
    if cardsInMotion.cards.count == 0 {
      startMovingCards(startingWithCard: card)
    } // pile now in motion
    
    let dsTouch = pos - lastTouchPos
    lastTouchPos = pos

    if cardsInMotion.cards.count > 0 {
      for moveCard in cardsInMotion.cards {
        moveCard.position += dsTouch
      }
    } else {
      fatalError("Trying to move pile before its setup")
    } // move those cards
    
  } // movePile
  
  private func startMovingCards(startingWithCard card: Card) {
    if let stackType = card.onStack {
      cardsInMotion.fromStack = stackType
      cardsInMotion.fromStackNo = card.stackNumber
      var removedCards = [Card]()

      switch stackType {
        
      case .Tableau, .Foundation:
        guard card.stackNumber != nil else {
          fatalError("Trying to move card from tableau/foundation, but card has no tableau/foundation number")
        }
        if stackType == .Tableau {
          if let getCards = tableaus[card.stackNumber!].getCards(fromPile: .Up,
                                                                 startingWith: card) {
            removedCards = getCards
          }
        } else {
          if let getCard = cardFoundations[card.stackNumber!].getCard() {
            removedCards = [getCard]
          }
        }
        
      case .Stock:
        if let get3Cards = currentDeck.get3Cards() {
          removedCards = get3Cards
        } else {
          fatalError("Moving stock cards when stock card pile is empty")
        }
        
      case .Waste:
        if let wasteCard = wastePile.getCard() {
          removedCards = [wasteCard]
        } else {
          fatalError("Moving waste card when waste card pile is empty")
        }
        
      } // switch stackType

      for moveCard in removedCards {
        moveCard.zPosition += 1000
      }
      cardsInMotion.cards = removedCards

    } else {
      fatalError("Trying to get/move non-existent card(s)")
    }
    
  } // private: startMovingCards
  
  func canMove(toStack stackType: StackType, checkDistance: Bool) -> Int? {
    switch stackType {
    case .Foundation:
      // If more than one card in motion, then can't stack on foundation
      if cardsInMotion.cards.count != 1 {
        return nil
      }
      for i in 0..<cardFoundations.count {
        if !((cardsInMotion.fromStack == stackType) && (cardsInMotion.fromStackNo == i)) {
          if cardFoundations[i].canMoveHere(card: cardsInMotion.cards[0],
                                            andCheckDistance: checkDistance) {
            return i
          }
        } // not trying to move on top of self
      }
    case .Tableau:
      for i in 0..<tableaus.count {
        guard cardsInMotion.cards.count > 0 else {
          fatalError("Evaluating move to tableau w/out any cards")
        }
        if !((cardsInMotion.fromStack == stackType) && (cardsInMotion.fromStackNo == i)) {
          if tableaus[i].canMoveHere(cards: cardsInMotion.cards,
                                     andCheckDistance: checkDistance) {
            return i
          }
        } // not trying to move on top of self
      }
    case .Stock:
      return nil
    case .Waste:
      return nil
    }
    return nil
  } // canMove:toStack
  
  func moveCards(toStack stackType: StackType, stackNumber stackNo: Int, withWiggle wiggle: Bool = false) {
    guard cardsInMotion.cards.count > 0 else {
      fatalError("No cards in motion when ending touch and trying to add cards to stack")
    }
    
    for card in cardsInMotion.cards {
      card.onStack = stackType
      card.stackNumber = stackNo
    }
    if stackType == .Tableau {
      tableaus[stackNo].add(cards: cardsInMotion.cards,
                            withWiggle: wiggle,
                            withAnimSpeed: cardAnimSpeed)
    } else if (stackType == .Foundation) && (cardsInMotion.cards.count == 1) {
      cardFoundations[stackNo].add(card: cardsInMotion.cards[0],
                                   withWiggle: wiggle,
                                   withAnimSpeed: cardAnimSpeed)
    } else {
      fatalError("Cannot move cards in motion to final stack")
    }
  } // movePile:toStack:stackNumber
  
  func animateRestartArrow() {
    if restartStockPile.isHidden == false {
      let rotateAction = SKAction.rotate(byAngle: -2 * π, duration: 60)
      let fadeOutAction = SKAction.fadeAlpha(by: -0.2, duration: 15)
      let fadeInAction = SKAction.fadeAlpha(by: 0.2, duration: 15)
      let fadeSequence = SKAction.sequence([fadeOutAction, fadeInAction, fadeOutAction, fadeInAction])
      let groupAction = SKAction.group([rotateAction, fadeSequence])
      let spinForever = SKAction.repeatForever(groupAction)
      restartStockPile.run(spinForever)
    }
  } // animateRestartArrow
  
  func hideRestartArrow() {
    restartStockPile.removeAllActions()
    restartStockPile.zRotation = 0
    restartStockPile.alpha = 0.5
    restartStockPile.isHidden = true
  } // hideRestartArrow

  func bumpWastePile() {
    wastePile.bumpThreeUp(withAnimSpeed: cardAnimSpeed)
    if wastePile.count == 0 {
      hideRestartArrow()
    }
  } // bumpWastePile
  
  func resetTouches() {
    cardsInMotion.reset()
    touchStarted = 0
    firstTouchPos = CGPoint.zero
    cardTouched = nil
  } // resetTouches

  
  // MARK: - Touch Execution
  func touchDown(atPoint pos: CGPoint) {
    print("Touch Down")
    if let firstNode = nodes(at: pos).first {
      if let card = Card.getCard(fromNode: firstNode) {
        let stackName = (card.onStack != nil) ? "\(card.onStack!)" : "No Stack"
        print("Touched card: \(card.value) of \(card.suit), facing \(card.facing), from \(stackName)")
        if canMove(card: card) {
          cardTouched = card
          touchStarted = TimeInterval(Date().timeIntervalSince1970)
          firstTouchPos = pos
          lastTouchPos = pos
        }
      } else if firstNode.name == "StockCardBase" {
        if let resetWastePile = wastePile.resetPile(toPosition: stockLocation,
                                                    withAnimSpeed: cardAnimSpeed) {
          currentDeck.add(cards: resetWastePile)
          hideRestartArrow()
        }
      } else {
        print("No card or action button touched")
      }
    }
  } // touchDown
  
  func touchMoved(toPoint pos: CGPoint) {
    if let card = cardTouched {
      movePile(withStartingCard: card, toPoint: pos)
    }
  } // touchMoved
  
  func touchUp(atPoint pos: CGPoint) {
    print("Touch Up")
    let dt = TimeInterval(Date().timeIntervalSince1970) - touchStarted
    let ds = firstTouchPos.distanceTo(pos)

    var isTapped = false
    if (touchStarted > 0) && (dt < 0.8) && (ds < 10) {
      print(" -- Tapped !!!")
      isTapped = true
      if let card = cardTouched {
        startMovingCards(startingWithCard: card)
      } // a valid card was touched
    } // tapped
    
    if (cardsInMotion.cards.count > 0) {
      
      // If moving from Stock, then cards only move to Waste Pile
      if cardsInMotion.fromStack == .Stock {
        wastePile.add(cards: cardsInMotion.cards,
                      withWiggle: isTapped,
                      withAnimSpeed: cardAnimSpeed)
        if currentDeck.unusedCards.count == 0 {
          restartStockPile.isHidden = false
          animateRestartArrow()
        }

      } else {
      
        guard ((cardsInMotion.fromStack != nil) &&
          (cardsInMotion.fromStackNo != nil)) ||
          (cardsInMotion.fromStack == .Waste)
        else {
          fatalError("Cards in motion but not from stack / stack number")
        }
        
        // Check if can move cards to foundation
        if let foundationNo = canMove(toStack: .Foundation, checkDistance: !isTapped) {
          moveCards(toStack: .Foundation, stackNumber: foundationNo)
          if cardsInMotion.fromStack! == .Tableau {
            tableaus[cardsInMotion.fromStackNo!].flipLowestDownCard(withAnimation: doCardFlipAnim,
                                                                    animSpeed: cardAnimSpeed)
          }
          if cardsInMotion.fromStack! == .Waste {
            bumpWastePile()
          }
        } // can move cards to Foundation
        
        // else check if can move cards to tableau
        else if let tableauNo = canMove(toStack: .Tableau,
                                        checkDistance: !isTapped) {
          moveCards(toStack: .Tableau, stackNumber: tableauNo)
          if cardsInMotion.fromStack! == .Tableau {
            tableaus[cardsInMotion.fromStackNo!].flipLowestDownCard(withAnimation: doCardFlipAnim,
                                                                    animSpeed: cardAnimSpeed)
          }
          if cardsInMotion.fromStack! == .Waste {
            bumpWastePile()
          }
        } // can move cards to Tableau
        
        // Else move cards back to original location
        else {
          if cardsInMotion.fromStack! == .Waste {
            wastePile.add(cards: cardsInMotion.cards,
                          withWiggle: isTapped,
                          withAnimSpeed: cardAnimSpeed)
          } else {
            moveCards(toStack: cardsInMotion.fromStack!,
                      stackNumber: cardsInMotion.fromStackNo!,
                      withWiggle: isTapped)
          }
        }
      } // Cards in motion not from stock pile
    } // cards are in motion
    
    resetTouches()
  } // touchUp
  
  func touchCancelled() {
    print("Touch Cancelled")
    if (cardsInMotion.cards.count > 0) &&
      !((cardsInMotion.fromStack != nil) && (cardsInMotion.fromStackNo != nil)) {
      moveCards(toStack: cardsInMotion.fromStack!,
                stackNumber: cardsInMotion.fromStackNo!)

    }
    resetTouches()
  } // touchCancelled

  
} // GameScene+GamePlay






