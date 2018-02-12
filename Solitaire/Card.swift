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

enum StackType: Int {
  case Stock
  case Waste
  case Tableau
  case Foundation
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
  
  var onStack: StackType?
  var stackNumber: Int?
  var isTopOfWaste = false

  private var frontBackground: SKTexture
  private var frontTexture: SKTexture
  private var backTexture: SKTexture
  
  private var frontFaceNode: SKSpriteNode!
  private let frontFaceScale = CGFloat(0.95)
  
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
    
    name = "\(value) of \(suit)"
    
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
  
  func flipOver(withAnimation doAnim: Bool = false, animSpeed: TimeInterval = 0.1) {
    if doAnim {
      let flipHalfway = SKAction.scaleX(to: 0, y: 1, duration: animSpeed)
      flipHalfway.timingMode = .easeIn
      let doAction = SKAction.run {
        self.flipCard()
      }
      let flipToFull = SKAction.scaleX(to: 1, y: 1, duration: animSpeed)
      flipToFull.timingMode = .easeOut
      run(SKAction.sequence([flipHalfway, doAction, flipToFull]))
    } else {
      flipCard()
    }
  } // flipOver
  
  private func flipCard() {
    if facing == .Front {
      facing = .Back
      frontFaceNode.alpha = 0
      texture! = backTexture
    } else {
      facing = .Front
      frontFaceNode.alpha = 1
      texture! = frontBackground
    }
  } // private: flipCard
  
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

  func animate(toPos pos: CGPoint, duration: TimeInterval) {
    let moveAnim = SKAction.move(to: pos, duration: duration)
    run(moveAnim)
  }
  
  
  // MARK: - Class Functions
  static func getCard(fromNode node: SKNode) -> Card? {
    
    var notAtTopNode = true
    var currentNode = node
    
    while notAtTopNode {
      // Card found?
      if let card = currentNode as? Card {
        print("Found Card: \(card.suit); value: \(card.value); facing: \(card.facing)")
        return card
      } else {
        if let parentNode = currentNode.parent {
          currentNode = parentNode
        } else {
          notAtTopNode = false
        }
      } // card not found
    } // cycle upward through node tree
    
    return nil
  }
  
  func printCard() {
    let cardPos = "(" + String(format: "%0.0f", position.x) + ", " + String(format: "%0.0f", position.y) + ")"
    print("\(value) of \(suit) (\(facing)); pos: \(cardPos) - z: \(zPosition)")
  }
  func getCardString() -> String {
    let cardPos = "(" + String(format: "%0.0f", position.x) + ", " + String(format: "%0.0f", position.y) + ")"
    return "\(value) of \(suit) (\(facing)); pos: \(cardPos) - z: \(zPosition)"
  }
  
  
  
} // Card





