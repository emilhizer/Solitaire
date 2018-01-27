//
//  Tableau.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation

enum PileType: Int {
  case Up = 0
  case Down
}

class Tableau {
  
  
  // MARK: - Properties
  var pileUp = [Card]()
  var pileDown = [Card]()
  
  
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(pile: PileType, card: Card) {
    addCard(toPile: pile, card: card)
  }
  
  
  // MARK: - Functions
  
  func addCard(toPile pile: PileType, card: Card) {
    switch pile {
    case .Up:
      pileUp.append(card)
    case .Down:
      pileDown.append(card)
    }
  } // addCard:toPile
  
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
  
  
  
  
  
} // Tableau




