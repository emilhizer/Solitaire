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
  // -- Always loaded from plist
  var gameInitData = [String: Any]()
  var cardDecks = [String: CardDeck]()
  // -- Reloaded on restore from save
  var currentDeck: CardDeck!
  var originalDeck: CardDeck?
  var tableaus = [Tableau]()
  var cardFoundations = [CardFoundation]()
  var wastePile: WastePile!

  // Player Moves
  enum PlayerAction: Int {
    case MoveCard = 0
    case TapStock
    case ResetWastePile
  } // PlayerAction
  struct PlayerMove {
    var playerAction: PlayerAction
    var cards: [Card]?
    var fromStack: StackType?
    var fromStackNo: Int?
    var toStack: StackType?
    var toStackNo: Int?
    
    init (playerAction: PlayerAction) {
      guard playerAction == .ResetWastePile else {
        fatalError("Can only init w/out from/to stack using ResetWastePile")
      }
      self.playerAction = playerAction
    }
    init(playerAction: PlayerAction, cards: [Card], fromStack: StackType, toStack: StackType) {
      self.playerAction = playerAction
      self.cards = cards
      self.fromStack = fromStack
      self.toStack = toStack
    }
    init(playerAction: PlayerAction, cards: [Card], fromStack: StackType, fromStackNo: Int?, toStack: StackType, toStackNo: Int?) {
      self.playerAction = playerAction
      self.cards = cards
      self.fromStack = fromStack
      self.fromStackNo = fromStackNo
      self.toStack = toStack
      self.toStackNo = toStackNo
    }
  } // PlayerMove
  var playerMoves = [PlayerMove]()
  
  // Game Setup
  var feltImage = "Feltr2"
  var cardBackImage = "CardBackNU"
  var useBigCards = false
  var altFaceSuffix: String?
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
  var restartStockPile = SKSpriteNode()
  var youWinLabel = SKSpriteNode()
  
  // Audio Setup
  let audioHelper = AudioHelper.sharedInstance
  var dealSounds = [String]()
  enum AudioName {
    static var DealBaseName = "carddeal"
    static var CardShuffle = "cardshuffle"
    static var Background = "background"
    static var Applause = "applause"
  }
  var backgroundVolume: Float = 0.4
  var soundFXVolume: Float = 0.6
  var volumeMute: Bool = false
  
  // Heads Up Display
  var hud: HUD!
  var settingsVolumeTouched = false
  var settingsFXTouched = false

  // Game Control
  enum GameState: Int {
    case Starting = 0
    case Dealing
    case Playing
    case Touching
    case Animating
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
  var canAutoWin = false
  
  // User Default Keys
  enum UDKeys {
    static var VolumeMuted = "Setting.VolumeMuted"
    static var BgVolume = "Settings.BgVolume"
    static var FXVolume = "Settings.FXVolume"
    static var BigCards = "BigCards"
  }

  
  // MARK: - Init and Setup
  
  // Init
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("init:coder")
  } // init:coder
  
  override init(size: CGSize) {
    super.init(size: size)
    print("init:size")
    addObservers()
  }
  
  // Setup scene
  override func didMove(to view: SKView) {
    
    print("Init: Load game data")
    loadGameInitData()
    
    print("Init: Get User Defaults")
    getSavedDefaults()
    
    print("Init: Setup background")
    setupBackground()
    
    print("Init: Setup music")
    setupAudio()
    
    print("Init: Setup HUD")
    setupHUD()

    print("Init: Setup dealer")
    setupDealer()
    
    if gameState == .Starting {
      parseCardsData(fromPList: gameInitData)
      if let replayDeck = originalDeck {
        print("Init: Using previous replay deck")
        currentDeck = replayDeck
      } else {
        print("Init: Replay deck is nil")
        currentDeck = cardDecks["52PlayingCardDeck"]
        currentDeck.shuffleDeck()
        originalDeck = currentDeck.copy()
      }

      print("Init: Setup Cards")
      setupCards()
      
      print("Init: Start new game")
      startNewGame()
    }
    
  } // didMove:to view
  
  func loadGameInitData() {
    if let gameInitData = getPList(fromFile: "GameData") {
      self.gameInitData = gameInitData
    } else {
      fatalError("Could Not Load Game Data 'GameData.plist'")
    }
    
    parseGameSettings(fromPList: gameInitData)
  } // loadGameInitData
  
  func getSavedDefaults() {
    if let volumeMute = UserDefaults.standard.object(forKey: UDKeys.VolumeMuted) as? Bool {
      print("Retrieved Volume Mute, value: \(volumeMute)")
      self.volumeMute = volumeMute
    }
    if let backgroundVolume = UserDefaults.standard.object(forKey: UDKeys.BgVolume) as? Float {
      self.backgroundVolume = backgroundVolume
    }
    if let soundFXVolume = UserDefaults.standard.object(forKey: UDKeys.FXVolume) as? Float {
      self.soundFXVolume = soundFXVolume
    }
    if let useBigCards = UserDefaults.standard.object(forKey: UDKeys.BigCards) as? Bool {
      self.useBigCards = useBigCards
    }
  } // getSavedDefaults
  
  func setupBackground() {
    let background = SKSpriteNode(imageNamed: feltImage)
    let widthScale = size.width / background.size.width
    let heightScale = size.height / background.size.height
    let finalScale = max(widthScale, heightScale)
    background.setScale(finalScale)
    background.zPosition = -100
    background.name = "Background"
    addChild(background)
    
    youWinLabel = SKSpriteNode(imageNamed: "YouWinLabel")
    youWinLabel.position = CGPoint.zero
    youWinLabel.zPosition = 2000
    let widthSizeRatio = (size.width / 1.5) / youWinLabel.size.width
    youWinLabel.size = CGSize(width: size.width / 1.5,
                              height: youWinLabel.size.height * widthSizeRatio)
    youWinLabel.isHidden = true
    addChild(youWinLabel)
  } // setupBackground()
  
  func setupAudio() {
    audioHelper.setupGameSound(name: AudioName.Background,
                               fileNamed: "BigChill.m4a",
                               withVolume: 0,
                               isBackground: true)
    
    audioHelper.playSound(name: AudioName.Background,
                          fadeDuration: 0)
    
    let startingVolume = volumeMute ? 0 : backgroundVolume
    runAfter(delay: 0.1) {
      self.audioHelper.playSound(name: AudioName.Background,
                                 withVolume: startingVolume,
                                 fadeDuration: 1)
    }
    audioHelper.setupGameSound(name: AudioName.CardShuffle,
                               fileNamed: "cardshuffle.m4a",
                               withVolume: soundFXVolume)
    audioHelper.setupGameSound(name: AudioName.Applause,
                               fileNamed: "SmallCrowdApplause.m4a",
                               withVolume: soundFXVolume)
    for i in 0...9 {
      let dealName = AudioName.DealBaseName + "\(i)"
      audioHelper.setupGameSound(name: dealName,
                                 fileNamed: "\(dealName).m4a",
                                 withVolume: soundFXVolume)
      dealSounds.append(dealName)
    }
    // If volume muted then force all sound volumes to zero
    if volumeMute {
      audioHelper.setSoundVolume(ofSound: AudioName.Background,
                                 to: 0)
      audioHelper.setSoundVolume(ofSound: AudioName.CardShuffle,
                                 to: 0)
      audioHelper.setSoundVolume(ofSound: AudioName.Applause,
                                 to: 0)
      for dealSound in dealSounds {
        audioHelper.setSoundVolume(ofSound: dealSound,
                                   to: 0)
      }
    } // volume is muted
  } // setupBackgroundMusic
  
  func setupHUD() {
    hud = HUD(size: size, hide: false)
    addChild(hud)
    hud.settingsChangedDelegate = self
    hud.setVolume(to: backgroundVolume)
    hud.setFXVolume(to: soundFXVolume)
    // Note: this only sets the switch
    //  This does not change initial setup of the cards
    hud.setBigCardSwitch(to: useBigCards)
    hud.setVolumeMute(to: volumeMute)
  } // setupHUD
  
  func setupDealer() {
    dealerPosition.y = -(size.height / 2) * 1.3
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
      if useBigCards {
        card.useAltImage()
      } else {
        card.useMainImage()
      }
      card.isHidden = true
    }

    cardHSpacing = (size.width * cardPadPercent) / (CGFloat(cardsAcross) + 1)
    cardVSpacing = cardSize.height * 0.3
    
    print("Size: (\(size.width), \(size.height))")
    var foundationX = -(size.width / 2) + cardHSpacing + (cardSize.width / 2)
    var foundationY = (size.height / 2) - (1.5 * cardSize.height)

    // Account for iPhone X having 30 pxl notch at top
    let deviceModel = UIDevice().type
    print("-- Device Model Type: \(deviceModel)")
    if deviceModel == .iPhoneX {
      foundationY -= 30
    }
    print("FoundatationXY: (\(foundationX), \(foundationY)")
    for _ in 0...3 {
      let basePosition = CGPoint(x: foundationX, y: foundationY)
      let emptySlot = create(emptySlotSprite: "EmptySlot",
                             withSize: cardSize,
                             andPosition: basePosition)
      addChild(emptySlot)
      let cardFoundation = CardFoundation(basePosition: basePosition)
      let randSound = dealSounds[Int.random(dealSounds.count)]
      let soundFX = SKAction.run {
        self.audioHelper.playSound(name: randSound)
      }
      cardFoundation.soundFX = soundFX
      cardFoundations.append(cardFoundation)
      foundationX += cardSize.width + cardHSpacing
    }

    var tableauX = cardFoundations[0].basePosition.x
    var tableauYDistance: CGFloat
    if UIDevice().userInterfaceIdiom == .phone {
      tableauYDistance = 1.5 * cardSize.height
    } else {
      tableauYDistance = 1.3 * cardSize.height
    }
    let tableauY = foundationY - tableauYDistance
    for _ in 0..<cardsAcross {
      let basePosition = CGPoint(x: tableauX, y: tableauY)
      let newTableau = Tableau(basePosition: basePosition,
                               cardSpacing: cardVSpacing,
                               downSpacing: cardVSpacing / 3)
      let randSound = dealSounds[Int.random(dealSounds.count)]
      let soundFX = SKAction.run {
        self.audioHelper.playSound(name: randSound)
      }
      newTableau.soundFX = soundFX
      let emptySlot = create(emptySlotSprite: "EmptySlot",
                             withSize: cardSize,
                             andPosition: basePosition)
      addChild(emptySlot)
      tableaus.append(newTableau)
      tableauX += cardSize.width + cardHSpacing
    }
    
    stockLocation.x = -tableaus[0].basePosition.x
    stockLocation.y = cardFoundations[0].basePosition.y
    stockCardBase = create(emptySlotSprite: "EmptySlot",
                           withSize: cardSize,
                           andPosition: stockLocation)
    stockCardBase.name = "StockCardBase"
    stockCardBase.zPosition = -10
    addChild(stockCardBase)
    
    restartStockPile = SKSpriteNode(imageNamed: "RefreshArrow")
    restartStockPile.name = "RefreshStockPile"
    restartStockPile.setScale((cardSize.width / restartStockPile.size.width) * 0.70)
    restartStockPile.position = stockLocation
    restartStockPile.alpha = 0.5
    restartStockPile.isHidden = true
    restartStockPile.zPosition = -15
    addChild(restartStockPile)
    
    wasteLocation.x = stockLocation.x - (2 * cardSize.width)
    wasteLocation.y = cardFoundations[0].basePosition.y
    
    let wastePileHSpacing = (cardSize.width - cardHSpacing) / 2
    wastePile = WastePile(basePosition: wasteLocation,
                          cardSpacing: wastePileHSpacing)
    let randSound = dealSounds[Int.random(dealSounds.count)]
    let soundFX = SKAction.run {
      self.audioHelper.playSound(name: randSound)
    }
    wastePile.soundFX = soundFX

  } // setupCards
  
  func create(emptySlotSprite imageName: String, withSize emptySlotSize: CGSize, andPosition basePosition: CGPoint) -> SKSpriteNode {
    let emptySlot = SKSpriteNode(imageNamed: imageName)
    emptySlot.name = imageName
    emptySlot.size = emptySlotSize
    emptySlot.position = basePosition
    emptySlot.zPosition = -1
    return emptySlot
  } // get:emptySlotSprite
  
  func startNewGame() {
    gameState = .Dealing
    runAfter(delay: 1) {
      self.deal()
    }
  } // startNewGame
  
  func restartGame(reshuffle: Bool) {
    let gameScene = GameScene(size: size)
    
    if !reshuffle {
      gameScene.originalDeck = originalDeck
    }
    
    gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    gameScene.scaleMode = .aspectFill
    let transition = SKTransition.fade(withDuration: 1.5)
    view!.presentScene(gameScene, transition: transition)
  } // restartGame
  
  func deal() {
    var delay = TimeInterval(0)
    
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
          card.isHidden = true
          
          delay += cardAnimSpeed // * TimeInterval(cardCount)
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

    delay += cardAnimSpeed * 2
    if let card = currentDeck.topCard() {
      let randSound = dealSounds[Int.random(dealSounds.count)]
      card.isHidden = false
      card.position = dealerPosition
      let wait = SKAction.wait(forDuration: delay)
      let moveAction = SKAction.move(to: stockLocation, duration: cardAnimSpeed * 4)
      let playSound = SKAction.run {
        self.audioHelper.playSound(name: randSound)
      }
      let runAction = SKAction.run {
        for eachCard in self.currentDeck.unusedCards {
          eachCard.isHidden = false
        }
        self.gameState = .Playing
      }
      let sequence = SKAction.sequence([wait, moveAction, playSound, runAction])
      card.run(sequence)
    }
    
  } // deal
  
  
  
  
  
  
} // GameScene







