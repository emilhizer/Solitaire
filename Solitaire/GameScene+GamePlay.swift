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
        return (currentDeck.unusedCards.count > 0) ? true : false
      case .Waste:
        return (wastePile.count > 0) ? true : false
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
      fatalError("Trying to move pile before it's setup")
    } // move those cards
    
  } // movePile
  
  private func startMovingCards(startingWithCard card: Card) {
    print("StartMovingCards")
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
  
  // MARK: - Move card to final location
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
      if !wiggle && !(
          (cardsInMotion.fromStack! == .Tableau) &&
          (cardsInMotion.fromStackNo == stackNo)
        ) {
        let playerMove = PlayerMove(playerAction: .MoveCard,
                                    cards: cardsInMotion.cards,
                                    fromStack: cardsInMotion.fromStack!,
                                    fromStackNo: cardsInMotion.fromStackNo,
                                    toStack: .Tableau,
                                    toStackNo: stackNo)
        playerMoves.append(playerMove)
      }
    } else if (stackType == .Foundation) && (cardsInMotion.cards.count == 1) {
      cardFoundations[stackNo].add(card: cardsInMotion.cards[0],
                                   withWiggle: wiggle,
                                   withAnimSpeed: cardAnimSpeed)
      if !wiggle && !(
          (cardsInMotion.fromStack! == .Foundation) &&
          (cardsInMotion.fromStackNo == stackNo)
        ) {
        let playerMove = PlayerMove(playerAction: .MoveCard,
                                    cards: cardsInMotion.cards,
                                    fromStack: cardsInMotion.fromStack!,
                                    fromStackNo: cardsInMotion.fromStackNo,
                                    toStack: .Foundation,
                                    toStackNo: stackNo)
        playerMoves.append(playerMove)
      }
    } else {
      fatalError("Cannot move cards in motion to final stack")
    }
  } // movePile:toStack:stackNumber
  
  // MARK: - Helpers
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
//    printUndoStack()
  } // resetTouches

  func printUndoStack() {
    print("\n --------")
    for i in 0..<playerMoves.count {
      let indexS = String(format: "%02d", i)
      print("\(indexS): \(playerMoves[i].playerAction)")
      if let cards = playerMoves[i].cards {
        if cards.count > 0 {
          for card in cards {
            card.printCard()
          } // loop through cards
        } else {
          print(" -- No cards")
        }
      } else {
        print(" -- No cards")
      }
    }
    print(" --------\n")
  } // printUndoStack
  
  func evaluateGameWon() {
    var foundationCardCount = 0
    for cardFoundation in cardFoundations {
      foundationCardCount += cardFoundation.pile.count
    } // loop through all foundations looking for full pile
    if foundationCardCount >= currentDeck.totalCardsInDeck {
      gameState = .Ending
      print("Winner, winner, chicken dinner!!!")
      animateWinning()
    }
  } // evaluateGameWon
  
  func animateWinning() {
    
    // Animate cards on foundations
    var delay = TimeInterval(0.5)
    let cardFlight = TimeInterval(2)
    for cardFoundation in cardFoundations {
      for card in cardFoundation.pile.reversed() {
        let delayAnim = SKAction.wait(forDuration: delay)
        let jumpTo = SKAction.jump(toHeight: card.size.height * 1.5,
                                   fromPosition: card.position,
                                   toPosition: dealerPosition,
                                   duration: cardFlight)
        let flipCard0 = SKAction.scaleX(to: 0, duration: cardFlight / 4)
        let flipCardFace = SKAction.run {
          card.flipOver()
        }
        let flipCard_1 = SKAction.scaleX(to: -1, duration: cardFlight / 4)
        let flipCard1 = SKAction.scaleX(to: 1, duration: cardFlight / 4)
        let flipCard = SKAction.sequence([flipCard0,
                                          flipCardFace,
                                          flipCard_1,
                                          flipCard0,
                                          flipCardFace,
                                          flipCard1])
        let groupAction = SKAction.group([jumpTo, flipCard])
        card.run(SKAction.sequence([delayAnim, groupAction]))
        delay += cardAnimSpeed
      } // loop through all cards in foundation
    } // loop through all foundations
    delay += 2
    runAfter(delay: delay) {
      self.restartGame(reshuffle: true)
    }
    
    // Animate you win! label
    youWinLabel.isHidden = false
    youWinLabel.xScale = 0
    youWinLabel.yScale = 0
    let labelDelay = SKAction.wait(forDuration: 0.5)
    let labelSpeed = TimeInterval(0.5)
    let scale1 = SKAction.scale(to: 1.5, duration: labelSpeed)
    scale1.timingMode = .easeIn
    let scale2 = SKAction.scale(to: 0.8, duration: labelSpeed)
    scale2.timingMode = .easeOut
    let scale3 = SKAction.scale(to: 1.1, duration: labelSpeed)
    scale3.timingMode = .easeIn
    let scale4 = SKAction.scale(to: 1.0, duration: labelSpeed)
    scale4.timingMode = .easeOut
    let scaleSeq = SKAction.sequence([labelDelay, scale1, scale2, scale3, scale4])
    youWinLabel.run(scaleSeq)
    
    // Play applause
    audioHelper.fadeOutSound(name: AudioName.Background,
                             fadeDuration: 1,
                             andStop: true)
    runAfter(delay: 0.5) {
      self.audioHelper.playSound(name: AudioName.Applause)
    }
    
  } // animateWinning
  
  // MARK: - Touch Execution
  func touchDown(atPoint pos: CGPoint) {
    print("Touch Down")
    settingsVolumeTouched = false
    settingsFXTouched = false
    
    if let firstNode = nodes(at: pos).first, firstNode.name == "Card" {
      if let card = Card.getCard(fromNode: firstNode) {
        let stackName = (card.onStack != nil) ? "\(card.onStack!)" : "No Stack"
        print("Touched card: \(card.getCardString()), from \(stackName)")
        if canMove(card: card) {
          cardTouched = card
          touchStarted = TimeInterval(Date().timeIntervalSince1970)
          firstTouchPos = pos
          lastTouchPos = pos
        }
      } // card touched
    } else if let firstNode = nodes(at: pos).first, firstNode.name == "StockCardBase" {
      if let resetWastePile = wastePile.resetPile(toPosition: stockLocation,
                                                  withAnimSpeed: cardAnimSpeed) {
        currentDeck.add(cards: resetWastePile)
        hideRestartArrow()
        let playerMove = PlayerMove(playerAction: .ResetWastePile)
        playerMoves.append(playerMove)
      }
    } else if hud.volumeTouched(at: pos) {
      settingsVolumeTouched = true
      hud.changeVolume(to: pos)
    } else if hud.fxTouched(at: pos) {
      settingsFXTouched = true
      hud.changeFX(to: pos)
    } else {
      print("No card or action button touched")
      let nodeTouched = nodes(at: pos).first?.name ?? "No node touched"
      print("Node: \(nodeTouched)")
    }
  } // touchDown
  
  func touchMoved(toPoint pos: CGPoint) {
    if let card = cardTouched {
      movePile(withStartingCard: card, toPoint: pos)
    } else if settingsVolumeTouched {
      hud.changeVolume(to: pos)
    } else if settingsFXTouched {
      hud.changeFX(to: pos)
    }
  } // touchMoved
  
  func touchUp(atPoint pos: CGPoint) {
    print("Touch Up")
    if let firstNode = nodes(at: pos).first, firstNode.name == "UndoButton" {
      print("Undo Button Pressed!")
      undoMove()
      resetTouches()
      return
    } else if let firstNode = nodes(at: pos).first, firstNode.name == "ReplayGameButton" {
      restartGame(reshuffle: false)
    } else if let firstNode = nodes(at: pos).first, firstNode.name == "NewGameButton" {
      restartGame(reshuffle: true)
    } else if let firstNode = nodes(at: pos).first, firstNode.name == "SettingsButton" {
      hud.showSettings()
      resetTouches()
      return
    } else if hud.buttonPressed(at: pos) {
      resetTouches()
      return
    }

    let dt = TimeInterval(Date().timeIntervalSince1970) - touchStarted
    let ds = firstTouchPos.distanceTo(pos)

    var isTapped = false
    // Tapped = time from touch down to up is < 800ms and distance < 10pxls
    //  Else, it's a move (not a tap)
    if (touchStarted > 0) && (dt < 0.8) && (ds < 10) {
      print(" -- Tapped !!!")
      isTapped = true
      if let card = cardTouched {
        // May not have any cards in motion on "perfect" tap
        if cardsInMotion.cards.count == 0 {
          startMovingCards(startingWithCard: card)
        } // no cards in motion prior to tap

        // If card is from tableau but can't be moved then see
        //  if any cards upwards on the tableau up pile can be
        //  moved
        // 1. Check if tapped card is from tableau
        if let stackNumber = card.stackNumber, card.onStack == .Tableau {
          // Return card(s) in motion to tableau and continue
          tableaus[stackNumber].add(cards: cardsInMotion.cards)
          // Get pileUp index of current card
          var pileUpIndexNo = tableaus[stackNumber].pileUp.index(of: card)!
          // 2. Check if card can be moved to foundation or another tableau
          var canMoveAnyCards = true
          while (canMove(toStack: .Foundation, checkDistance: false) == nil) &&
            (canMove(toStack: .Tableau, checkDistance: false) == nil) {
              // 3. No move found, try to get next card (upward) on tableau up pile
              if pileUpIndexNo > 0 {
                pileUpIndexNo -= 1
                cardsInMotion.cards = [tableaus[stackNumber].pileUp[pileUpIndexNo]]
              } else {
                // 4. If there's no "next card", then no moves found
                canMoveAnyCards = false
                break
              }
          } // while card tapped (or upward on pile) is NOT moveable
          if canMoveAnyCards {
            startMovingCards(startingWithCard: tableaus[stackNumber].pileUp[pileUpIndexNo])
          } else {
            startMovingCards(startingWithCard: card)
          }
        } // tapped card is from tableau
        
/*
        // If card is from tableau but can't be moved then see
        //  if any cards upwards on the tableau up pile can be
        //  moved
        // 1. Check if tapped card is from tableau
        if let stackNumber = card.stackNumber, card.onStack == .Tableau {
          // 2. Check if card can be moved to foundation or another tableau
          while (canMove(toStack: .Foundation, checkDistance: false) == nil) &&
            (canMove(toStack: .Tableau, checkDistance: false) == nil) {
              // 3. No move found, try to get next card (upward) on tableau up pile
              if let nextCardUp = tableaus[stackNumber].pileUp.last {
                tableaus[stackNumber].add(cards: cardsInMotion.cards)
                startMovingCards(startingWithCard: nextCardUp)
              } else {
                // 4. If there's no "next card", then return to original card and break
                tableaus[stackNumber].add(cards: cardsInMotion.cards)
                startMovingCards(startingWithCard: card)
                break
              }
          } // card tapped not moveable
        } // tapped card is from tableau
*/

      } // valid card tapped
    } // playing board tapped
    
    if (cardsInMotion.cards.count > 0) {
      
      // If moving from Stock, then cards only move to Waste Pile
      if cardsInMotion.fromStack == .Stock {
        for card in cardsInMotion.cards {
          card.onStack = .Waste
          card.stackNumber = nil
        }
        wastePile.add(cards: cardsInMotion.cards,
                      withWiggle: false,
                      withAnimSpeed: cardAnimSpeed)
        let playerMove = PlayerMove(playerAction: .TapStock,
                                    cards: cardsInMotion.cards,
                                    fromStack: .Stock,
                                    toStack: .Waste)
        playerMoves.append(playerMove)

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
            for card in cardsInMotion.cards {
              card.onStack = .Waste
              card.stackNumber = nil
            }
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
    
    evaluateGameWon()
    
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






