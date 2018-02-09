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
  var wastePile: WastePile!
  
  
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
  var stockCardBase = SKSpriteNode()
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
    case Touching
    case Ending
  }
  var gameState: GameState = .Starting
  var priorGameState: GameState = .Ending
  
  // +GamePlay
  var firstTouchPos = CGPoint.zero
  var lastTouchPos = CGPoint.zero
  var touchStarted = TimeInterval(0)
  var cardTouched: Card?
  struct CardsInMotion {
    var cards = [Card]()
    var fromStack: StackType?
    var fromStackNo: Int?
    
    mutating func reset() {
      cards.removeAll()
      fromStack = nil
      fromStackNo = nil
    }
  } // CardsInMotion
  var cardsInMotion = CardsInMotion()

  
  // MARK: - Init and Setup
  override func didMove(to view: SKView) {
    
    loadGameInitData()
    
    setupBackground()
    
    setupDealer()
    
    parseCardsData(fromPList: gameInitData)
    
    currentDeck = cardDecks["52PlayingCardDeck"]

    setupCards()
    
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
  
  func setupCards() {
    if let cardWidth = currentDeck.cardWidth,
      let cardHeight = currentDeck.cardHeight {
      let cardsAcrossWidth = CGFloat(cardsAcross) * cardWidth
      cardScale = (size.width * (1-cardPadPercent)) / cardsAcrossWidth
      cardSize = CGSize(width: cardWidth * cardScale,
                        height: cardHeight * cardScale)
    } else {
      fatalError("Card width/heigh not found")
    }
    
    for card in currentDeck.unusedCards {
      card.setSize(to: cardSize)
      card.faceDown()
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
    stockCardBase = create(emptySlotSprite: "EmptySlot",
                           withSize: cardSize,
                           andPosition: stockLocation)
    stockCardBase.name = "StockCardBase"
    stockCardBase.zPosition = -10
    addChild(stockCardBase)
    
    let restartStockPile = SKSpriteNode(imageNamed: "RefreshArrow")
    restartStockPile.name = "RefreshStockPile"
    restartStockPile.setScale((cardSize.width / restartStockPile.size.width) * 0.70)
    restartStockPile.position = stockLocation
    restartStockPile.zPosition = -15
    addChild(restartStockPile)
    
    wasteLocation.x = stockLocation.x - (2 * cardSize.width)
    wasteLocation.y = cardFoundations[0].basePosition.y
    
    let wastePileHSpacing = (cardSize.width - cardHSpacing) / 2
    wastePile = WastePile(basePosition: wasteLocation,
                          cardSpacing: wastePileHSpacing)

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
        if let card = currentDeck.getCard() {
          if tableauCol == tableauRow {
            card.faceUp()
          } else {
            card.faceDown()
          }
          addChild(card)
          card.onStack = .Tableau
          card.stackNumber = tableauCol
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
    
    // Setup the Stock pile
    var currentZPos = CGFloat(10)
    for eachCard in currentDeck.unusedCards {
      eachCard.onStack = .Stock
      eachCard.position = stockLocation
      eachCard.setSize(to: cardSize)
      eachCard.zPosition = currentZPos
      eachCard.faceDown()
      eachCard.isHidden = true
      addChild(eachCard)
      currentZPos += 10
    }

    if let card = currentDeck.topCard() {
      card.isHidden = false
      card.position = dealerPosition
      print("Top of Current Deck is zPos: \(card.zPosition)")
      let wait = SKAction.wait(forDuration: cardAnimSpeed * TimeInterval(30))
      let moveAction = SKAction.move(to: stockLocation, duration: cardAnimSpeed * 4)
      let runAction = SKAction.run {
        for eachCard in self.currentDeck.unusedCards {
          eachCard.isHidden = false
        }
        self.gameState = .Playing
      }
      let sequence = SKAction.sequence([wait, moveAction, runAction])
      card.run(sequence)
    }
    
  } // deal
  
  
  
  
  
  
} // GameScene







