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
  var foundations = [[Card]]()
  var stock = [Card]()
  var waste = [Card]()
  
  
  // Game Setup
  var feltImage = "Feltr2"
  var cardBackImage = "CardBackNU"
  var cardPadPercent = CGFloat(0.1)
  var cardPadding = CGFloat(0)
  var cardScale = CGFloat(0)
  var cardSize = CGSize.zero
  var cardsAcross = CGFloat(7)
  var dealerPosition = CGPoint.zero
  var tableauStartLocation = CGPoint.zero
  var tableauHiddenVertSpacing = CGFloat(0.15)
  var tableauStackVertSpacing = CGFloat(0.20)
  var foundationStartLocation = CGPoint.zero
  var stockLocation = CGPoint.zero
  var wasteLocation = CGPoint.zero
  var wasteHorizSpacing = CGFloat(0.20)

  
  // Game Play
  enum GameState: Int {
    case Starting = 0
    case Dealing
    case Playing
    case Ending
  }
  var gameState: GameState = .Starting
  
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
      let cardsAcrossWidth = cardsAcross * cardWidth
      cardScale = (size.width * (1-cardPadPercent)) / cardsAcrossWidth
      cardSize = CGSize(width: cardWidth * cardScale,
                        height: cardHeight * cardScale)
    } else {
      fatalError("Card width/heigh not found")
    }

    cardPadding = (size.width * cardPadPercent) / (cardsAcross + 1)
    
    tableauStartLocation.x = -(size.width / 2) + cardPadding + (cardSize.width / 2)
    tableauStartLocation.y = size.height * (1/4)

    foundationStartLocation.x = tableauStartLocation.x
    foundationStartLocation.y = (size.height / 2) - cardSize.height

    stockLocation.x = -tableauStartLocation.x
    stockLocation.y = foundationStartLocation.y
    
    wasteLocation.x = stockLocation.x - (2 * cardSize.width)
    wasteLocation.y = foundationStartLocation.y

  } // setupCardLocations
  
  func startNewGame() {
    
    currentDeck.shuffleDeck()
    
    gameState = .Dealing
    deal()
    
  } // startNewGame
  
  func deal() {
    var cardPosition = tableauStartLocation
    var cardCount = 0
    let dealTiming = TimeInterval(0.1)
    
    for pileCol in 0...6 {
      cardPosition.x = tableauStartLocation.x + (CGFloat(pileCol) * (cardSize.width + cardPadding))
      for pileRow in pileCol...6 {
        if let card = currentDeck.drawCard() {
          if pileRow != pileCol { card.flipOver() }
          addChild(card)
          card.setSize(to: cardSize)
          card.zPosition = 10 + CGFloat(cardCount)
          card.position = dealerPosition
          
          if pileRow == pileCol {
            tableaus.append(Tableau(pile: .Up, card: card))
          } else {
            tableaus[pileCol].addCard(toPile: .Down, card: card)
          }

          let wait = SKAction.wait(forDuration: dealTiming * TimeInterval(cardCount))
          let moveAction = SKAction.move(to: cardPosition, duration: dealTiming)
          let sequence = SKAction.sequence([wait, moveAction])
          card.run(sequence)
        } // card
        cardPosition.x += cardPadding + cardSize.width
        cardCount += 1
      } // for j
      cardPosition.y -= cardSize.height * tableauHiddenVertSpacing
    } // for i
    
    if let card = currentDeck.topCard() {
      card.faceDown()
      card.position = dealerPosition
      card.name = "StockCard"
      card.setSize(to: cardSize)
      card.zPosition = 100
      addChild(card)
      let wait = SKAction.wait(forDuration: dealTiming * TimeInterval(30))
      let moveAction = SKAction.move(to: stockLocation, duration: dealTiming * 4)
      let runAction = SKAction.run {
        self.gameState = .Playing
      }
      let sequence = SKAction.sequence([wait, moveAction, runAction])
      card.run(sequence)
    }
    
  } // deal
  
  
  
  
  
  
} // GameScene







