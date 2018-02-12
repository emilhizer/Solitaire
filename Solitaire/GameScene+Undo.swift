//
//  GameScene+Undo.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/10/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

  func undoMove () {
    if let playerMove = playerMoves.popLast() {
      print("\n!!! --- Undoing Move --- !!!")
      
      switch playerMove.playerAction {
      case .MoveCard:
        let undoFromStack = playerMove.toStack!
        let undoFromStackNo = playerMove.toStackNo
        let undoToStack = playerMove.fromStack!
        let undoToStackNo = playerMove.fromStackNo
        
        switch undoFromStack {
          
          // Undo move card(s) from Foundation
        case .Foundation:
          print("Undo from Foundation")
          let card = cardFoundations[undoFromStackNo!].getCard()!
          switch undoToStack {
            
            // From Foundation To Foundation
          case .Foundation:
            fatalError("Cannot undo from Foundation to Foundation")
            
            // From Foundation To Tableau
          case .Tableau:
            print("Undo to Tableau")
            card.onStack = .Tableau
            card.stackNumber = undoToStackNo
            tableaus[undoToStackNo!].undoFlipCardDown(withAnimation: doCardFlipAnim,
                                                      animSpeed: cardAnimSpeed)
            tableaus[undoToStackNo!].add(card: card,
                                         withAnimSpeed: cardAnimSpeed)
            
            // From Foundation To Stock
          case .Stock:
            fatalError("Cannot undo to Stock pile")
            
            // From Foundation To Waste
          case .Waste:
            print("Undo to Waste")
            card.onStack = .Waste
            card.stackNumber = nil
            wastePile.add(cards: [card],
                          withAnimSpeed: cardAnimSpeed)
            
          } // switch from Foundation to stack
          
          // Undo move card(s) from Tableau
        case .Tableau:
          print("Undo From Tableau")
          let topCard = playerMove.cards![0]
          let cards = tableaus[undoFromStackNo!].getCards(fromPile: .Up,
                                                          startingWith: topCard)!
          switch undoToStack {
            
          // From Tableau To Foundation
          case .Foundation:
            cards[0].onStack = .Foundation
            cards[0].stackNumber = undoToStackNo
            cardFoundations[undoToStackNo!].add(card: cards[0])
            
          // From Tableau To Tableau
          case .Tableau:
            print("Undo to Tableau")
            for card in cards {
              card.onStack = .Tableau
              card.stackNumber = undoToStackNo
            }
            tableaus[undoToStackNo!].undoFlipCardDown(withAnimation: doCardFlipAnim,
                                                      animSpeed: cardAnimSpeed)
            tableaus[undoToStackNo!].add(cards: cards,
                                         withAnimSpeed: cardAnimSpeed)
            
          // From Tableau To Stock
          case .Stock:
            fatalError("Cannot undo to Stock pile")
            
          // From Tableau To Waste
          case .Waste:
            print("Undo to Waste")
            for card in cards {
              card.onStack = .Waste
              card.stackNumber = nil
            }
            wastePile.add(cards: cards,
                          withAnimSpeed: cardAnimSpeed)
            
          } // switch from Tableau to stack
          
          // Undo move card(s) from Stock
        case .Stock:
          fatalError("Cannot undo from Stock pile")
          
          // Undo move card(s) from Waste
        case .Waste:
          fatalError("Cannot undo from Waste pile")

        } // switch from stack
        
        // Undo tap stock pile
      case .TapStock:
        print("TapStock")
        for _ in playerMove.cards! {

          let wasteCard = wastePile.getCard()!
          wasteCard.onStack = .Stock
          wasteCard.stackNumber = nil
          
          let topZPosition = (currentDeck.unusedCards.last?.zPosition ?? CGFloat(0)) + CGFloat(10)
          wastePile.returnToStock(card: wasteCard,
                                  stockPosition: stockLocation,
                                  stockZPosition: topZPosition,
                                  withAnimSpeed: cardAnimSpeed)
          currentDeck.add(card: wasteCard)
        }
        wastePile.resetThreeUp(withAnimSpeed: cardAnimSpeed)
        hideRestartArrow() // in +GamePlay
        
        // Undo reset waste pile
      case .ResetWastePile:
        print("\n ---- ResetWastePile")
        // Undo current deck to waste pile
        var resetWasteCards = [Card]()
        while let card = currentDeck.getCard() {
          card.onStack = .Waste
          card.stackNumber = nil
          resetWasteCards.append(card)
        }
        wastePile.resetWaste(cards: resetWasteCards,
                             withAnimSpeed: cardAnimSpeed)

        // Show restart arrow
        restartStockPile.isHidden = false
        animateRestartArrow()
        
      } // switch playerAction
    } // playerMove found
    
  } // undoMove




} // GameScene+Undo






