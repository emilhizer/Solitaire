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
  
  func add(card: Card) {
    pile.append(card)
  } // add:card
  
  func getCard() -> Card? {
    if pile.count > 0 {
      return pile.popLast()
    }
    return nil
  } // getCard:fromPile
  
  
  
  
  
} // CardFoundation
