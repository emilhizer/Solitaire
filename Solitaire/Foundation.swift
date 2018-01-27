//
//  Foundation.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation

class Foundation {
  
  
  // MARK: - Properties
  var pile = [Card]()
  
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  
  
  
  
} // Foundation
