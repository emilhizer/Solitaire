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
  
  // En/Decoding Keys
  enum Keys {
    static var currentDeck = "GS.currentDeck"
    static var originalDeck = "GS.originalDeck"
    static var tableaus = "GS.tableaus"
    static var cardFoundations = "GS.cardFoundations"
    static var wastePile = "GS.wastePile"
    static var feltImage = "GS.feltImage"
    static var cardBackImage = "GS.cardBackImage"
    static var useBigCards = "GS.useBigCards"
    static var altFaceSuffix = "GS.altFaceSuffix"
    static var cardPadPercent = "GS.cardPadPercent"
    static var cardHSpacing = "GS.cardHSpacing"
    static var cardVSpacing = "GS.cardVSpacing"
    static var cardScale = "GS.cardScale"
    static var cardSize = "GS.cardSize"
    static var cardsAcross = "GS.cardsAcross"
    static var dealerPosition = "GS.dealerPosition"
    static var stockLocation = "GS.stockLocation"
    static var stockCardBase = "GS.stockCardBase"
    static var wasteLocation = "GS.wasteLocation"
    static var wasteHorizSpacing = "GS.wasteHorizSpacing"
    static var cardAnimSpeed = "GS.cardAnimSpeed"
    static var doCardFlipAnim = "GS.doCardFlipAnim"
    static var restartStockPile = "GS.restartStockPile"
    static var youWinLabel = "GS.youWinLabel"
    static var hud = "GS.hud"
    static var settingsVolumeTouched = "GS.settingsVolumeTouched"
    static var settingsFXTouched = "GS.settingsFXTouched"
    static var gameState = "GS.gameState"
    static var priorGameState = "GS.priorGameState"
    static var canAutoWin = "GS.canAutoWin"
    static var firstTouchPos = "GS.firstTouchPos"
    static var lastTouchPos = "GS.lastTouchPos"
    static var touchStarted = "GS.touchStarted"
    static var cardTouched = "GS.cardTouched"
    
    // Structure: cardsInMotion
    static var CIMcards = "GS.CIM.cards"
    static var CIMfromStack = "GS.CIM.fromStack"
    static var CIMfromStackNo = "GS.CIM.fromStackNo"

    // Structure: playerMoves
    static var PMplayerMoves = "GS.PM.playerMoves"
    static var PMplayerAction = "GS.PM.playerAction"
    static var PMcards = "GS.PM.cards"
    static var PMfromStack = "GS.PM.fromStack"
    static var PMfromStackNo = "GS.PM.fromStackNo"
    static var PMtoStack = "GS.PM.toStack"
    static var PMtoStackNo = "GS.PM.toStackNo"
  } // Keys
  
  // MARK: - Properties
  
  // Game Data
  // -- Set by parent
  var loadFromSave = false
  
  // -- Always loaded from plist
  var gameInitData = [String: Any]()
  var cardDecks = [String: CardDeck]()
  // -- Reloaded on restore from save
  var currentDeck: CardDeck!
  var originalDeck: CardDeck?
  var tableaus = [Tableau]()
  var cardFoundations = [CardFoundation]()
  var wastePile: WastePile!

  // Player Moves History
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
//  var cardBackImage = "CardBackNU"
  var cardBackImage = "CardBackBasic"
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

  // MARK: - Save data
  override func encode(with aCoder: NSCoder) {
    print("encode -- GameScene")
    aCoder.encode(currentDeck, forKey: Keys.currentDeck)
    if originalDeck != nil {
      aCoder.encode(originalDeck, forKey: Keys.originalDeck)
    }
    aCoder.encode(tableaus, forKey: Keys.tableaus)
    aCoder.encode(cardFoundations, forKey: Keys.cardFoundations)
    aCoder.encode(wastePile, forKey: Keys.wastePile)
    aCoder.encode(feltImage, forKey: Keys.feltImage)
    aCoder.encode(cardBackImage, forKey: Keys.cardBackImage)
    aCoder.encode(useBigCards, forKey: Keys.useBigCards)
    if altFaceSuffix != nil {
      aCoder.encode(altFaceSuffix, forKey: Keys.altFaceSuffix)
    }
    aCoder.encode(cardPadPercent, forKey: Keys.cardPadPercent)
    aCoder.encode(cardHSpacing, forKey: Keys.cardHSpacing)
    aCoder.encode(cardVSpacing, forKey: Keys.cardVSpacing)
    aCoder.encode(cardScale, forKey: Keys.cardScale)
    aCoder.encode(cardSize, forKey: Keys.cardSize)
    aCoder.encode(cardsAcross, forKey: Keys.cardsAcross)
    aCoder.encode(dealerPosition, forKey: Keys.dealerPosition)
    aCoder.encode(stockLocation, forKey: Keys.stockLocation)
    aCoder.encode(stockCardBase, forKey: Keys.stockCardBase)
    aCoder.encode(wasteLocation, forKey: Keys.wasteLocation)
    aCoder.encode(wasteHorizSpacing, forKey: Keys.wasteHorizSpacing)
    aCoder.encode(cardAnimSpeed, forKey: Keys.cardAnimSpeed)
    aCoder.encode(doCardFlipAnim, forKey: Keys.doCardFlipAnim)
    aCoder.encode(restartStockPile, forKey: Keys.restartStockPile)
    aCoder.encode(youWinLabel, forKey: Keys.youWinLabel)
    
    aCoder.encode(hud, forKey: Keys.hud)
    aCoder.encode(settingsVolumeTouched, forKey: Keys.settingsVolumeTouched)
    aCoder.encode(settingsFXTouched, forKey: Keys.settingsFXTouched)

    aCoder.encode(gameState.rawValue, forKey: Keys.gameState)
    aCoder.encode(priorGameState.rawValue, forKey: Keys.priorGameState)
    aCoder.encode(canAutoWin, forKey: Keys.canAutoWin)
    aCoder.encode(firstTouchPos, forKey: Keys.firstTouchPos)
    aCoder.encode(lastTouchPos, forKey: Keys.lastTouchPos)
    aCoder.encode(touchStarted, forKey: Keys.touchStarted)
    if cardTouched != nil {
      aCoder.encode(cardTouched, forKey: Keys.cardTouched)
    }
    
    // Structure: cardsInMotion
    if cardsInMotion.cards.count > 0 {
      aCoder.encode(cardsInMotion.cards, forKey: Keys.CIMcards)
      if cardsInMotion.fromStack != nil {
        aCoder.encode(cardsInMotion.fromStack!.rawValue, forKey: Keys.CIMfromStack)
      }
      if cardsInMotion.fromStackNo != nil {
        aCoder.encode(cardsInMotion.fromStackNo!, forKey: Keys.CIMfromStackNo)
      }
    } // cardsInMotion
    
    // Structure: playerMoves
    var pMplayerAction = [Int]()
    var pMcards = [[Card]?]()
    var pMfromStack = [Int?]()
    var pMfromStackNo = [Int?]()
    var pMtoStack = [Int?]()
    var PMtoStackNo = [Int?]()
    for playerMove in playerMoves {
      pMplayerAction.append(playerMove.playerAction.rawValue)
      pMcards.append(playerMove.cards)
      pMfromStack.append(playerMove.fromStack?.rawValue)
      pMfromStackNo.append(playerMove.fromStackNo)
      pMtoStack.append(playerMove.toStack?.rawValue)
      PMtoStackNo.append(playerMove.toStackNo)
    }
    aCoder.encode(pMplayerAction, forKey: Keys.PMplayerAction)
    aCoder.encode(pMcards, forKey: Keys.PMcards)
    aCoder.encode(pMfromStack, forKey: Keys.PMfromStack)
    aCoder.encode(pMfromStackNo, forKey: Keys.PMfromStackNo)
    aCoder.encode(pMtoStack, forKey: Keys.PMtoStack)
    aCoder.encode(PMtoStackNo, forKey: Keys.PMtoStackNo)
    
    super.encode(with: aCoder)
  } // encode
  
  // MARK: - Init
  required init?(coder aDecoder: NSCoder) {
    print("init(coder:) -- Card")
    currentDeck = aDecoder.decodeObject(forKey: Keys.currentDeck) as! CardDeck
    originalDeck = aDecoder.decodeObject(forKey: Keys.originalDeck) as? CardDeck
    tableaus = aDecoder.decodeObject(forKey: Keys.tableaus) as! [Tableau]
    cardFoundations = aDecoder.decodeObject(forKey: Keys.cardFoundations) as! [CardFoundation]
    wastePile = aDecoder.decodeObject(forKey: Keys.wastePile) as! WastePile
    feltImage = aDecoder.decodeObject(forKey: Keys.feltImage) as! String
    cardBackImage = aDecoder.decodeObject(forKey: Keys.cardBackImage) as! String
    useBigCards = aDecoder.decodeBool(forKey: Keys.useBigCards)
    print("Use Big Cards: \(useBigCards)")
    altFaceSuffix = aDecoder.decodeObject(forKey: Keys.altFaceSuffix) as? String
    cardPadPercent = aDecoder.decodeObject(forKey: Keys.cardPadPercent) as! CGFloat
    cardHSpacing = aDecoder.decodeObject(forKey: Keys.cardHSpacing) as! CGFloat
    cardVSpacing = aDecoder.decodeObject(forKey: Keys.cardVSpacing) as! CGFloat
    cardScale = aDecoder.decodeObject(forKey: Keys.cardScale) as! CGFloat
    cardSize = aDecoder.decodeCGSize(forKey: Keys.cardSize)
    cardsAcross = aDecoder.decodeInteger(forKey: Keys.cardsAcross)
    dealerPosition = aDecoder.decodeCGPoint(forKey: Keys.dealerPosition)
    stockLocation = aDecoder.decodeCGPoint(forKey: Keys.stockLocation)
    stockCardBase = aDecoder.decodeObject(forKey: Keys.stockCardBase) as! SKSpriteNode
    wasteLocation = aDecoder.decodeCGPoint(forKey: Keys.wasteLocation)
    wasteHorizSpacing = aDecoder.decodeObject(forKey: Keys.wasteHorizSpacing) as! CGFloat
    cardAnimSpeed = aDecoder.decodeDouble(forKey: Keys.cardAnimSpeed) // as! TimeInterval
    doCardFlipAnim = aDecoder.decodeBool(forKey: Keys.doCardFlipAnim)
    restartStockPile = aDecoder.decodeObject(forKey: Keys.restartStockPile) as! SKSpriteNode
    youWinLabel = aDecoder.decodeObject(forKey: Keys.youWinLabel) as! SKSpriteNode

    hud = aDecoder.decodeObject(forKey: Keys.hud) as! HUD
    settingsVolumeTouched = aDecoder.decodeBool(forKey: Keys.settingsVolumeTouched)
    settingsFXTouched = aDecoder.decodeBool(forKey: Keys.settingsFXTouched)

    gameState = GameState(rawValue:
      aDecoder.decodeInteger(forKey: Keys.gameState))!
    priorGameState = GameState(rawValue:
      aDecoder.decodeInteger(forKey: Keys.priorGameState))!
    canAutoWin = aDecoder.decodeBool(forKey: Keys.canAutoWin)
    firstTouchPos = aDecoder.decodeCGPoint(forKey: Keys.firstTouchPos)
    lastTouchPos = aDecoder.decodeCGPoint(forKey: Keys.lastTouchPos)
    touchStarted = aDecoder.decodeDouble(forKey: Keys.touchStarted) // as! TimeInterval
    cardTouched = aDecoder.decodeObject(forKey: Keys.cardTouched) as? Card
    
    // Structure: cardsInMotion
    if let cimCards = aDecoder.decodeObject(forKey: Keys.CIMcards) as? [Card] {
      cardsInMotion.cards = cimCards
      if aDecoder.containsValue(forKey: Keys.CIMfromStack) {
        cardsInMotion.fromStack = StackType(rawValue:
          aDecoder.decodeInteger(forKey: Keys.CIMfromStack))!
      }
      if aDecoder.containsValue(forKey: Keys.CIMfromStackNo) {
        cardsInMotion.fromStackNo = aDecoder.decodeInteger(forKey: Keys.CIMfromStackNo)
      }
    }
    
    // Structure: playerMoves
    let pMplayerActionRawValues = aDecoder.decodeObject(forKey: Keys.PMplayerAction) as? [Int]
    let pMcards = aDecoder.decodeObject(forKey: Keys.PMcards) as? [[Card]?]
    let pMfromStackRawValues = aDecoder.decodeObject(forKey: Keys.PMfromStack) as? [Int?]
    let pMfromStackNos = aDecoder.decodeObject(forKey: Keys.PMfromStackNo) as? [Int?]
    let pMtoStackRawValues = aDecoder.decodeObject(forKey: Keys.PMtoStack) as? [Int?]
    let pMtoStackNos = aDecoder.decodeObject(forKey: Keys.PMtoStackNo) as? [Int?]
    if let pMplayerActionRawValues = pMplayerActionRawValues {
      var playerMove: PlayerMove
      for i in 0..<pMplayerActionRawValues.count {
        let pMplayerAction = PlayerAction(rawValue: pMplayerActionRawValues[i])!
        if let pMcards = pMcards?[i] {
          let pMfromStack = StackType(rawValue: pMfromStackRawValues![i]!)!
          let pMtoStack = StackType(rawValue: pMtoStackRawValues![i]!)!
          playerMove = PlayerMove(
            playerAction: pMplayerAction,
            cards: pMcards,
            fromStack: pMfromStack,
            fromStackNo: pMfromStackNos?[i],
            toStack: pMtoStack,
            toStackNo: pMtoStackNos?[i])
        } else {
          playerMove = PlayerMove(playerAction: pMplayerAction)
        }
        playerMoves.append(playerMove)
      } // iterate through player moves
    } // has history of player moves
    
    super.init(coder: aDecoder)
    
    addObservers()
    
    // Setup sound effect actions
    let soundFX = SKAction.run {
      let randSound = self.dealSounds[Int.random(self.dealSounds.count)]
      self.audioHelper.playSound(name: randSound)
    }
    for cardFoundation in cardFoundations {
      cardFoundation.soundFX = soundFX
    }
    for tableau in tableaus {
      tableau.soundFX = soundFX
    }
    wastePile.soundFX = soundFX

  } // init:coder

  override init(size: CGSize) {
    super.init(size: size)
    print("init:size")
    addObservers()
  }
  
  // MARK: - Load and Setup
  // Setup scene
  override func didMove(to view: SKView) {
    
    print("Init: Load game data")
    loadGameInitData()
    
    print("Init: Get card properties from plist")
    parseCardsData(fromPList: gameInitData)
    
    print("Init: Get User Defaults")
    getSavedDefaults()
    
    print("Init: Setup audio - based on user defaults")
    setupAudio()
    
    if !loadFromSave {
      print("Init: Setup background")
      setupBackground()

      print("Init: Setup HUD")
      setupHUD()
      
      print("Init: Setup dealer")
      setupDealer()
    
      if let replayDeck = originalDeck, gameState == .Starting {
        print("Init: Using previous replay deck")
        currentDeck = replayDeck
      } else {
        print("Init: Replay deck is nil")
        currentDeck = cardDecks["52PlayingCardDeck"]
        currentDeck.shuffleDeck()
        originalDeck = currentDeck.copy()
      }

      print("Init: Setup cards for new game")
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
    print(" -- background size: \(background.size)")
    let widthScale = size.width / background.size.width
    let heightScale = size.height / background.size.height
    let finalScale = max(widthScale, heightScale)
    print("\n -- finalScale: \(finalScale)")
    background.setScale(finalScale)
    background.zPosition = -100
    background.name = "Background"
    addChild(background)
    print(" -- Added Backround: \(background)")
    
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
                               fileNamed: "SpaceBackround.m4a",
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
    
    let soundFX = SKAction.run {
      let randSound = self.dealSounds[Int.random(self.dealSounds.count)]
      self.audioHelper.playSound(name: randSound)
    }

    print("FoundatationXY: (\(foundationX), \(foundationY)")
    for _ in 0...3 {
      let basePosition = CGPoint(x: foundationX, y: foundationY)
      let emptySlot = create(emptySlotSprite: "EmptySlot",
                             withSize: cardSize,
                             andPosition: basePosition)
      addChild(emptySlot)
      let cardFoundation = CardFoundation(basePosition: basePosition)
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







