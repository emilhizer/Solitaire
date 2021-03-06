//
//  Card.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/21/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - Global Enums
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


// MARK: - Main Class
class Card: SKSpriteNode {
  
  // En/Decoding Keys
  enum Keys {
    static var suit = "Card.suit"
    static var value = "Card.value"
    static var facing = "Card.facing"
    static var onStack = "Card.onStack"
    static var stackNumber = "Card.stackNumber"
    static var isTopOfWaste = "Card.isTopOfWaste"
    static var frontImageName = "Card.frontImageName"
    static var altFrontImageName = "Card.altFrontImageName"
    static var backImageName = "Card.backImageName"
    static var frontBackgroundName = "Card.frontBackgroundName"
    static var frontBackground = "Card.frontBackground"
    static var frontTexture = "Card.frontTexture"
    static var altFrontTexture = "Card.altFrontTexture"
    static var backTexture = "Card.backTexture"
    static var frontFaceNode = "Card.frontFaceNode"
    static let frontFaceScale = "Card.frontFaceScale"
  } // Keys
  
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
  
  private var frontImageName: String
  private var altFrontImageName: String?
  private var backImageName: String
  private var frontBackgroundName: String

  private var frontBackground: SKTexture
  private var frontTexture: SKTexture
  private var altFrontTexture: SKTexture?
  private var backTexture: SKTexture
  
  private var frontFaceNode: SKSpriteNode!
  private var frontFaceScale = CGFloat(0.95)
  
  // MARK: - Save data
  override func encode(with aCoder: NSCoder) {
    print("encode -- Card")
    aCoder.encode(suit.rawValue, forKey: Keys.suit)
    aCoder.encode(value, forKey: Keys.value)
    aCoder.encode(facing.rawValue, forKey: Keys.facing)
    if onStack != nil {
      aCoder.encode(onStack!.rawValue, forKey: Keys.onStack)
    }
    if stackNumber != nil {
      aCoder.encode(stackNumber!, forKey: Keys.stackNumber)
    }
    aCoder.encode(isTopOfWaste, forKey: Keys.isTopOfWaste)
    aCoder.encode(frontImageName, forKey: Keys.frontImageName)
    if altFrontImageName != nil {
      aCoder.encode(altFrontImageName!, forKey: Keys.altFrontImageName)
    }
    aCoder.encode(backImageName, forKey: Keys.backImageName)
    aCoder.encode(frontBackgroundName, forKey: Keys.frontBackgroundName)
    aCoder.encode(frontBackground, forKey: Keys.frontBackground)
    aCoder.encode(frontTexture, forKey: Keys.frontTexture)
    if altFrontTexture != nil {
      aCoder.encode(altFrontTexture!, forKey: Keys.altFrontTexture)
    }
    aCoder.encode(backTexture, forKey: Keys.backTexture)
    aCoder.encode(frontFaceNode, forKey: Keys.frontFaceNode)
    aCoder.encode(frontFaceScale, forKey: Keys.frontFaceScale)
    
    super.encode(with: aCoder)
  } // encode
  
  // MARK: - Init
  required init?(coder aDecoder: NSCoder) {
    print("init(coder:) -- Card")
    suit = Suit(rawValue: aDecoder.decodeInteger(forKey: Keys.suit))!
    value = aDecoder.decodeInteger(forKey: Keys.value)
    facing = CardFacing(rawValue: aDecoder.decodeInteger(forKey: Keys.facing))!
    if aDecoder.containsValue(forKey: Keys.onStack) {
      onStack = StackType(rawValue: aDecoder.decodeInteger(forKey: Keys.onStack))
    }
    if aDecoder.containsValue(forKey: Keys.stackNumber) {
      stackNumber = aDecoder.decodeInteger(forKey: Keys.stackNumber)
    }
    isTopOfWaste = aDecoder.decodeBool(forKey: Keys.isTopOfWaste)
    frontImageName = aDecoder.decodeObject(forKey: Keys.frontImageName) as! String
    altFrontImageName = aDecoder.decodeObject(forKey: Keys.altFrontImageName) as? String
    backImageName = aDecoder.decodeObject(forKey: Keys.backImageName) as! String
    frontBackgroundName = aDecoder.decodeObject(forKey: Keys.frontBackgroundName) as! String
    frontBackground = aDecoder.decodeObject(forKey: Keys.frontBackground) as! SKTexture
    frontTexture = aDecoder.decodeObject(forKey: Keys.frontTexture) as! SKTexture
    altFrontTexture = aDecoder.decodeObject(forKey: Keys.altFrontTexture) as? SKTexture
    backTexture = aDecoder.decodeObject(forKey: Keys.backTexture) as! SKTexture
    frontFaceNode = aDecoder.decodeObject(forKey: Keys.frontFaceNode) as! SKSpriteNode
    frontFaceScale = aDecoder.decodeObject(forKey: Keys.frontFaceScale) as! CGFloat
    super.init(coder: aDecoder)
  } // init:coder

  init(suit: Suit, value: Int, frontImage: String, altFrontImage: String? = nil, backImage: String, frontBackground: String = "CardFrontTexture") {

    self.frontImageName = frontImage
    self.altFrontImageName = altFrontImage
    self.backImageName = backImage
    self.frontBackgroundName = frontBackground
    
    self.frontBackground = SKTexture(imageNamed: frontBackground)
    self.suit = suit
    self.value = value

    frontTexture = SKTexture(imageNamed: frontImage)
    backTexture = SKTexture(imageNamed: backImage)

    super.init(texture: self.frontBackground,
               color: .clear,
               size: self.frontBackground.size())

    if let altFrontImage = altFrontImage {
      altFrontTexture = SKTexture(imageNamed: altFrontImage)
    }

    name = "Card"
    
    frontFaceNode = SKSpriteNode(texture: frontTexture)
    frontFaceNode.size = CGSize(width: size.width * frontFaceScale,
                                height: size.height * frontFaceScale)
    frontFaceNode.name = "Card"
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
  
  func useAltImage() {
    if let altFontTexture = altFrontTexture {
      frontFaceNode.texture! = altFontTexture
    }
  } // useAltImage
  
  func useMainImage() {
    frontFaceNode.texture! = frontTexture
  } // useMainImage
  
  override func copy() -> Any {
    return Card(suit: self.suit,
                value: self.value,
                frontImage: self.frontImageName,
                altFrontImage: self.altFrontImageName,
                backImage: self.backImageName,
                frontBackground: self.frontBackgroundName)
  }
  
//  func animate(toPos pos: CGPoint, duration: TimeInterval) {
//    let moveAnim = SKAction.move(to: pos, duration: duration)
//    run(moveAnim)
//  }
//  
  
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





