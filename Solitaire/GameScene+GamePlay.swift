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
    if let _ = card.pileNumber, card.facing == .Front {
      return true
    }
    return false
  } // canMove:card
  
  func tableauToStack(card: Card) -> Tableau? {
    var columnWinner = -1
    var closestX = CGFloat(99999)
    let withinDistX = card.size.width / 2
    let withinDistY = card.size.height

    // Find closest column
    for i in 0...cardsAcross {
      let testDist = abs(card.position.x - tableaus[i].basePosition.x)
      if testDist < closestX {
        closestX = testDist
        columnWinner = i
      } // find a closer match?
    } // loop through tableaus
    
    if closestX <= withinDistX {
      if card.position.y <= tableaus[columnWinner].basePosition.y + (withinDistY / 2) {
        if tableaus[columnWinner].pileUp.count == 0 {
          if card.position.y >= tableaus[columnWinner].basePosition.y - withinDistY {
            return tableaus[columnWinner]
          } // empty tableau, card within range
        } else {
          let bottomY = tableaus[columnWinner].lastPosition.y
          if card.position.y >= bottomY - withinDistY {
            return tableaus[columnWinner]
          } // tableau with cards, card within range
        }
      } // card not too far above tableaus
    } // x distance is within range
    
    return nil
  } // tableauToStack:card

  // MARK: - Pile Movement
  func movePile(withStartingCard card: Card, toPoint pos: CGPoint) {
    
    if cardsInMotion.count == 0 {
      startMovingCards(startingWithCard: card)
    } // pile now in motion
    
    let dsTouch = pos - lastTouchPos
    lastTouchPos = pos

    if cardsInMotion.count > 0 {
      for moveCard in cardsInMotion {
        moveCard.position += dsTouch
      }
    } else {
      fatalError("Trying to move pile before its setup")
    } // move those cards
    
  } // movePile
  
  private func startMovingCards(startingWithCard card: Card) {
    if let pileNo = card.pileNumber,
      let removedCards = tableaus[pileNo].getCards(fromPile: .Up, startingWith: card) {
      cardsInMotion = removedCards
      cardsMovedFromTableauNo = pileNo
    } else {
      fatalError("Trying to get/move non-existent card(s) from pile")
    }
    for moveCard in cardsInMotion {
      moveCard.zPosition += 1000
      moveCard.pileNumber = nil
    }
  } // private: startMovingCards
  
  func movePile(toTableauNo tableauNo: Int) {
    guard cardsInMotion.count > 0 else {
      fatalError("No cards in motion when ending touch")
    }
    
    for card in cardsInMotion {
      card.pileNumber = tableauNo
    }
    tableaus[tableauNo].add(cards: cardsInMotion, withAnimSpeed: cardAnimSpeed)
    
    cardsInMotion.removeAll()
    cardsMovedFromTableauNo = nil
  } // movePile:toTableau
  
  
  // MARK: - Touch Execution
  func touchDown(atPoint pos: CGPoint) {
    print("Touch Down")
    if let firstNode = nodes(at: pos).first {
      if let card = Card.getCard(fromNode: firstNode) {
        print("Touched card: \(card.value) of \(card.suit), facing \(card.facing)")
        if canMove(card: card) {
          cardTouched = card
          touchStarted = TimeInterval(Date().timeIntervalSince1970)
          firstTouchPos = pos
          lastTouchPos = pos
        }
      } else {
        print("No card touched")
      }
    }
  } // touchDown
  
  func touchMoved(toPoint pos: CGPoint) {
    print("Touch Moved")
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
        cardsMovedFromTableauNo = card.pileNumber
        startMovingCards(startingWithCard: card)
      } // a valid card was touched
    } // tapped

    touchStarted = 0
    firstTouchPos = CGPoint.zero
    
    if let origTableauNo = cardsMovedFromTableauNo {
      var moveToTableauNo = origTableauNo
      for i in 0..<tableaus.count {
        if i != origTableauNo {
          if tableaus[i].canMoveHere(cards: cardsInMotion, andCheckDistance: !isTapped) {
            moveToTableauNo = i
            print("    -- Can move to tableau: \(moveToTableauNo)")
            break
          } // found move to tableau
        }
      } // loop through all tableaus
      movePile(toTableauNo: moveToTableauNo)
      if moveToTableauNo != origTableauNo {
        tableaus[origTableauNo].flipLowestDownCard(withAnimation: doCardFlipAnim,
                                                   animSpeed: cardAnimSpeed)
      }
    } // cards in motion have defined return location
   
    
  } // touchUp
  
  func touchCancelled() {
    print("Touch Cancelled")
    if let origTableauNo = cardsMovedFromTableauNo {
      movePile(toTableauNo: origTableauNo)
    }
    touchStarted = 0
    firstTouchPos = CGPoint.zero
  } // touchCancelled
  
  

  
  
  
} // GameScene+GamePlay






