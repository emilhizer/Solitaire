//
//  GameScene.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/21/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  // Game Data
  var gameInitData = [String: Any]()
  var cardDecks = [String: CardDeck]()
  var currentDeck: CardDeck!
  var tableaus = [Tableau]()
  var cardFoundations = [CardFoundation]()
  var stock = [Card]()
  var waste = [Card]()
  
  
  // Game Setup
  var feltImage = "Feltr2"
  var cardBackImage = "CardBackNU"
  var cardPadPercent = CGFloat(0.1)
  var cardHSpacing = CGFloat(0)
  var cardVSpacing = CGFloat(0)
  var cardScale = CGFloat(0)
  var cardSize = CGSize.zero
  var cardsAcross = 7
  var dealerPosition = CGPoint.zero
  var stockLocation = CGPoint.zero
  var wasteLocation = CGPoint.zero
  var wasteHorizSpacing = CGFloat(0.20)
  var cardAnimSpeed = TimeInterval(0.1)
  var doCardFlipAnim = true

  // Game Control
  enum GameState: Int {
    case Starting = 0
    case Dealing
    case Playing
    case Animating
    case Ending
  }
  var gameState: GameState = .Starting
  
  // +GamePlay
  var firstTouchPos = CGPoint.zero
  var lastTouchPos = CGPoint.zero
  var touchStarted = TimeInterval(0)
  var cardTouched: Card?
  var cardsInMotion = [Card]()
  var cardsMovedFromTableauNo: Int?

  
  // MARK: - Init and Setup
  override func didMove(to view: SKView) {
    
    loadGameInitData()
    
    setupBackground()
    
    setupDealer()
    
    parseCardsData(fromPList: gameInitData)
    
    currentDeck = cardDecks["52PlayingCardDeck"]

    setupCardLocations()
    
    startNewGame()
    
  } // didMove:to view
  
  func loadGameInitData() {
    if let gameInitData = getPList(fromFile: "GameData") {
      self.gameInitData = gameInitData
    } else {
      fatalError("Could Not Load Game Data 'GameData.plist'")
    }
  } // loadGameInitData
  
  func setupBackground() {
    let background = SKSpriteNode(imageNamed: feltImage)
    let widthScale = size.width / background.size.width
    let heightScale = size.height / background.size.height
    let finalScale = max(widthScale, heightScale)
    background.setScale(finalScale)
    background.zPosition = -100
    background.name = "Background"
    addChild(background)
  } // setupBackground()
  
  func setupDealer() {
    dealerPosition.y = -(size.height / 2) * 1.1
  } // setupDealer
  
  func setupCardLocations() {
    if let cardWidth = currentDeck.cardWidth,
      let cardHeight = currentDeck.cardHeight {
      let cardsAcrossWidth = CGFloat(cardsAcross) * cardWidth
      cardScale = (size.width * (1-cardPadPercent)) / cardsAcrossWidth
      cardSize = CGSize(width: cardWidth * cardScale,
                        height: cardHeight * cardScale)
    } else {
      fatalError("Card width/heigh not found")
    }

    cardHSpacing = (size.width * cardPadPercent) / (CGFloat(cardsAcross) + 1)
    cardVSpacing = cardSize.height * 0.2
    
    var tableauX = -(size.width / 2) + cardHSpacing + (cardSize.width / 2)
    let tableauY = size.height * (1/4)
    for _ in 0..<cardsAcross {
      let basePosition = CGPoint(x: tableauX, y: tableauY)
      let newTableau = Tableau(basePosition: basePosition,
                               cardSpacing: cardVSpacing)
      let emptySlot = create(emptySlotSprite: "EmptySlot",
                                     withSize: cardSize,
                                     andPosition: basePosition)
      addChild(emptySlot)
      tableaus.append(newTableau)
      tableauX += cardSize.width + cardHSpacing
    }

    var foundationX = tableaus[0].basePosition.x
    let foundationY = (size.height / 2) - cardSize.height
    for _ in 0...3 {
      let basePosition = CGPoint(x: foundationX, y: foundationY)
      let emptySlot = create(emptySlotSprite: "EmptySlot",
                             withSize: cardSize,
                             andPosition: basePosition)
      addChild(emptySlot)
      cardFoundations.append(CardFoundation(basePosition: basePosition))
      foundationX += cardSize.width + cardHSpacing
    }

    stockLocation.x = -tableaus[0].basePosition.x
    stockLocation.y = cardFoundations[0].basePosition.y
    
    wasteLocation.x = stockLocation.x - (2 * cardSize.width)
    wasteLocation.y = cardFoundations[0].basePosition.y

  } // setupCardLocations
  
  func create(emptySlotSprite imageName: String, withSize emptySlotSize: CGSize, andPosition basePosition: CGPoint) -> SKSpriteNode {
    let emptySlot = SKSpriteNode(imageNamed: imageName)
    emptySlot.name = imageName
    emptySlot.size = emptySlotSize
    emptySlot.position = basePosition
    emptySlot.zPosition = -1
    return emptySlot
  } // get:emptySlotSprite
  
  func startNewGame() {
    
    currentDeck.shuffleDeck()
    
    gameState = .Dealing
    deal()
    
  } // startNewGame
  
  func deal() {
    
    var cardCount = 0
    for tableauRow in 0..<cardsAcross {
      for tableauCol in tableauRow..<cardsAcross {
        if let card = currentDeck.drawCard() {
          if tableauCol != tableauRow { card.flipOver() }
          addChild(card)
          card.setSize(to: cardSize)
          card.pileNumber = tableauCol
          card.position = dealerPosition
          card.zPosition = 1000

          let delay = cardAnimSpeed * TimeInterval(cardCount)
          tableaus[tableauCol].add(card: card,
                                   withAnimSpeed: cardAnimSpeed,
                                   delay: delay)
        } // draw card
        cardCount += 1
      } // for tableauCol
    } // for tableauRow

    // Animate the deal
    /*
    var cardCount = 0
    for tableauRow in 0..<cardsAcross {
      for tableauCol in tableauRow..<cardsAcross {
        var card: Card
        if tableauCol == tableauRow {
          card = tableaus[tableauCol].pileUp[0]
        } else {
          card = tableaus[tableauCol].pileDown[tableauRow]
        }
        let cardFinalPosition = card.position
        card.position = dealerPosition
        
        let wait = SKAction.wait(forDuration: cardAnimSpeed * TimeInterval(cardCount))
        let moveAction = SKAction.move(to: cardFinalPosition, duration: cardAnimSpeed)
        let sequence = SKAction.sequence([wait, moveAction])
        card.run(sequence)
        cardCount += 1
      } // for tableauCol
    } // for tableauRow
    */
    
    // Setup the Stock pile
    if let card = currentDeck.topCard() {
      card.faceDown()
      card.position = dealerPosition
      card.name = "StockCard"
      card.setSize(to: cardSize)
      card.zPosition = 1000
      addChild(card)
      let wait = SKAction.wait(forDuration: cardAnimSpeed * TimeInterval(30))
      let moveAction = SKAction.move(to: stockLocation, duration: cardAnimSpeed * 4)
      let runAction = SKAction.run {
        self.gameState = .Playing
      }
      let sequence = SKAction.sequence([wait, moveAction, runAction])
      card.run(sequence)
    }
    
  } // deal
  
  
  
  
  
  
} // GameScene







