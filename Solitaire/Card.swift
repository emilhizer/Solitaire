//
//  Card.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/21/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

enum CardFacing: Int {
  case Front = 0
  case Back
}

enum Suit: Int {
  case Spades = 0
  case Diamonds
  case Clubs
  case Hearts
}

enum SuitColor: Int {
  case Black = 0
  case Red
}

class Card: SKSpriteNode {
  
  // MARK: - Properties
  var suit: Suit
  var suitColor: SuitColor {
    if (suit == .Spades) || (suit == .Clubs) {
      return .Black
    } else {
      return .Red
    }
  }
  var value: Int
  var facing: CardFacing = .Front
  
  private var frontBackground: SKTexture
  private var frontTexture: SKTexture
  private var backTexture: SKTexture
  
  private var frontFaceNode: SKSpriteNode!
  private let frontFaceScale = CGFloat(0.98)
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(suit: Suit, value: Int, frontImage: String, backImage: String, frontBackground: String = "CardFrontTexture") {

    self.frontBackground = SKTexture(imageNamed: frontBackground)
    self.suit = suit
    self.value = value
    frontTexture = SKTexture(imageNamed: frontImage)
    backTexture = SKTexture(imageNamed: backImage)
    
    super.init(texture: self.frontBackground,
               color: .clear,
               size: self.frontBackground.size())
    
    frontFaceNode = SKSpriteNode(texture: frontTexture)
    frontFaceNode.size = CGSize(width: size.width * frontFaceScale,
                                height: size.height * frontFaceScale)
    frontFaceNode.name = "FrontFace"
    frontFaceNode.zPosition = 1
    addChild(frontFaceNode)
    
    
  } // init
  
  
  // MARK: - Functions
  func setSize(to newSize: CGSize) {
    size = newSize
    frontFaceNode.size = CGSize(width: newSize.width * frontFaceScale,
                                height: newSize.height * frontFaceScale)
  } // setSize
  
  func flipOver(withAnimation: Bool = false) {
    if facing == .Front {
      facing = .Back
      frontFaceNode.alpha = 0
      texture! = backTexture
    } else {
      facing = .Front
      frontFaceNode.alpha = 1
      texture! = frontBackground
    }
  } // flipOver
  
  func faceDown() {
    if facing != .Back {
      facing = .Back
      frontFaceNode.alpha = 0
      texture! = backTexture
    }
  } // faceDown
  
  func faceUp() {
    if facing != .Front {
      facing = .Front
      frontFaceNode.alpha = 1
      texture! = frontBackground
    }
  } // faceUp

  
  
  // MARK: - Class Functions
  static func getCard(fromNode node: SKNode) -> Card? {
    
    var notAtTopNode = true
    var currentNode = node
    
    while notAtTopNode {
      // Card found?
      if let card = currentNode as? Card {
        print("Found Card: \(card)")
        print(" -- Card suit: \(card.suit); value: \(card.value); facing: \(card.facing)")
        return card
      } else {
        if let parentNode = currentNode.parent {
          currentNode = parentNode
          print("Stepping up through node tree, current node: \(currentNode)")
        } else {
          notAtTopNode = false
        }
      } // card not found
    } // cycle upward through node tree
    
    return nil
  }
  
  
  
  
} // Card





