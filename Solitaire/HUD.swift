//
//  HUD.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/12/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


// MARK: - Protocols
protocol SettingsChangedDelegate: class {
  func volumeMuteChanged(to volumeMute: Bool)
  func volumeChanged(to level: Float)
  func fxVolumeChanged(to level: Float)
  func bigCardsChanged(to bigCards: Bool)
  func settingsExited()
}


// MARK: - Main Class
class HUD: SKNode {
  
  // MARK: - Protocol Delegates
  weak var settingsChangedDelegate: SettingsChangedDelegate?

  // En/Decoding Keys
  enum Keys {
    static var settingsChangedDelegate = "HUD.settingsChangedDelegate"
    static var hudSize = "HUD.hudSize"
    static var volumeMute = "HUD.volumeMute"
    static var bigCards = "HUD.bigCards"
    static var undoButton = "HUD.undoButton"
    static var newGameButton = "HUD.newGameButton"
    //  static var pauseButton = "HUD.pauseButton"
    static var replayButton = "HUD.replayButton"
    static var autoplayButton = "HUD.autoplayButton"
    static var autoplayShine = "HUD.autoplayShine"
    static var settingsButton = "HUD.settingsButton"
    static var volumeMuteButton = "HUD.volumeMuteButton"
    static var settingsMenu = "HUD.settingsMenu"
    static var settingsExit = "HUD.settingsExit"
    static var bgVolumeSlider = "HUD.bgVolumeSlider"
    static var bgVolumeSliderMask = "HUD.bgVolumeSliderMask"
    static var bgCropNode = "HUD.bgCropNode"
    static var fxVolumeSlider = "HUD.fxVolumeSlider"
    static var fxVolumeSliderMask = "HUD.fxVolumeSliderMask"
    static var fxCropNode = "HUD.fxCropNode"
    static var bigCardsButton = "HUD.bigCardsButton"
  } // Keys
  
  // MARK: - Properties
  var hudSize = CGSize.zero
  var undoButton: SKSpriteNode!
  var newGameButton: SKSpriteNode!
//  var pauseButton: SKSpriteNode!
  var replayButton: SKSpriteNode!
  var autoplayButton: SKSpriteNode!
  var autoplayShine: SKSpriteNode!
  var settingsButton: SKSpriteNode!
  var volumeMuteButton: SKSpriteNode!
  var volumeMute: Bool = false

  var settingsMenu = SKNode()
  var settingsExit: SKSpriteNode!
  var bgVolumeSlider: SKSpriteNode!
  var bgVolumeSliderMask: SKSpriteNode!
  var bgCropNode: SKCropNode!
  var fxVolumeSlider: SKSpriteNode!
  var fxVolumeSliderMask: SKSpriteNode!
  var fxCropNode: SKCropNode!
  var bigCardsButton: SKSpriteNode!
  var bigCards = false
  
  // MARK: - Save data
  override func encode(with aCoder: NSCoder) {
    print("encode -- HUD")
    aCoder.encode(settingsChangedDelegate, forKey: Keys.settingsChangedDelegate)
    aCoder.encode(hudSize, forKey: Keys.hudSize)
    aCoder.encode(volumeMute, forKey: Keys.volumeMute)
    aCoder.encode(bigCards, forKey: Keys.bigCards)
    
    aCoder.encode(newGameButton, forKey: Keys.newGameButton)
    //  aCoder.encode(pauseButton, forKey: Keys.pauseButton)
    aCoder.encode(replayButton, forKey: Keys.replayButton)
    aCoder.encode(autoplayButton, forKey: Keys.autoplayButton)
    aCoder.encode(autoplayShine, forKey: Keys.autoplayShine)
    aCoder.encode(settingsButton, forKey: Keys.settingsButton)
    aCoder.encode(volumeMuteButton, forKey: Keys.volumeMuteButton)
    aCoder.encode(settingsMenu, forKey: Keys.settingsMenu)
    aCoder.encode(settingsExit, forKey: Keys.settingsExit)
    aCoder.encode(bgVolumeSlider, forKey: Keys.bgVolumeSlider)
    aCoder.encode(bgVolumeSliderMask, forKey: Keys.bgVolumeSliderMask)
    aCoder.encode(bgCropNode, forKey: Keys.bgCropNode)
    aCoder.encode(fxVolumeSlider, forKey: Keys.fxVolumeSlider)
    aCoder.encode(fxVolumeSliderMask, forKey: Keys.fxVolumeSliderMask)
    aCoder.encode(fxCropNode, forKey: Keys.fxCropNode)
    aCoder.encode(bigCardsButton, forKey: Keys.bigCardsButton)

    super.encode(with: aCoder)
  } // encode
  
  // MARK: - Init
  required init?(coder aDecoder: NSCoder) {
    print("init(coder:) -- HUD")
    settingsChangedDelegate =
      aDecoder.decodeObject(forKey: Keys.settingsChangedDelegate) as? SettingsChangedDelegate
    hudSize = aDecoder.decodeCGSize(forKey: Keys.hudSize)
    volumeMute = aDecoder.decodeBool(forKey: Keys.volumeMute)
    bigCards = aDecoder.decodeBool(forKey: Keys.bigCards)
    
    newGameButton = aDecoder.decodeObject(forKey: Keys.newGameButton) as! SKSpriteNode
    //  pauseButton = aDecoder.decodeObject(forKey: Keys.pauseButton) as! SKSpriteNode
    replayButton = aDecoder.decodeObject(forKey: Keys.replayButton) as! SKSpriteNode
    autoplayButton = aDecoder.decodeObject(forKey: Keys.autoplayButton) as! SKSpriteNode
    autoplayShine = aDecoder.decodeObject(forKey: Keys.autoplayShine) as! SKSpriteNode
    settingsButton = aDecoder.decodeObject(forKey: Keys.settingsButton) as! SKSpriteNode
    volumeMuteButton = aDecoder.decodeObject(forKey: Keys.volumeMuteButton) as! SKSpriteNode
    settingsMenu = aDecoder.decodeObject(forKey: Keys.settingsMenu) as! SKNode
    settingsExit = aDecoder.decodeObject(forKey: Keys.settingsExit) as! SKSpriteNode
    bgVolumeSlider = aDecoder.decodeObject(forKey: Keys.bgVolumeSlider) as! SKSpriteNode
    bgVolumeSliderMask = aDecoder.decodeObject(forKey: Keys.bgVolumeSliderMask) as! SKSpriteNode
    bgCropNode = aDecoder.decodeObject(forKey: Keys.bgCropNode) as! SKCropNode
    fxVolumeSlider = aDecoder.decodeObject(forKey: Keys.fxVolumeSlider) as! SKSpriteNode
    fxVolumeSliderMask = aDecoder.decodeObject(forKey: Keys.fxVolumeSliderMask) as! SKSpriteNode
    fxCropNode = aDecoder.decodeObject(forKey: Keys.fxCropNode) as! SKCropNode
    bigCardsButton = aDecoder.decodeObject(forKey: Keys.bigCardsButton) as! SKSpriteNode

    super.init(coder: aDecoder)
//    setupHUD()
  } // init:coder

  init(size hudSize: CGSize, hide: Bool = false) {
    super.init()

    self.hudSize = hudSize
    isHidden = hide
    
    setupHUD()
  } // init:size

  func setupHUD() {
    let buttonSize = CGSize(width: hudSize.width / 15,
                            height: hudSize.width / 15)
    let buttonSpacing = hudSize.width / 15
    var topRowRightPos = CGPoint(x: (hudSize.width / 2) - ((buttonSpacing + buttonSize.width) / 2),
                                 y: (hudSize.height / 2) - ((buttonSpacing + buttonSize.height) / 2))
    var topRowLeftPos = CGPoint(x: -(hudSize.width / 2) + ((buttonSpacing + buttonSize.width) / 2),
                                y: (hudSize.height / 2) - ((buttonSpacing + buttonSize.height) / 2))
    
    // Account for iPhone X having 30 pxl notch at top
    let deviceModel = UIDevice().type
    if deviceModel == .iPhoneX {
      topRowRightPos.y -= 30
      topRowLeftPos.y -= 30
    }
    
    var buttonPosition = topRowRightPos
    
    zPosition = 2000
    
    undoButton = SKSpriteNode(imageNamed: "UndoArrow")
    undoButton.name = "UndoButton"
    undoButton.size = buttonSize
    undoButton.position = buttonPosition
    undoButton.zPosition = zPosition + 1
    addChild(undoButton)
    
    buttonPosition -= CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    replayButton = SKSpriteNode(imageNamed: "RefreshPageArrow")
    replayButton.name = "ReplayGameButton"
    replayButton.size = buttonSize
    replayButton.position = buttonPosition
    replayButton.zPosition = zPosition + 1
    addChild(replayButton)
    
    buttonPosition -= CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    newGameButton = SKSpriteNode(imageNamed: "PlusButton")
    newGameButton.name = "NewGameButton"
    newGameButton.size = buttonSize
    newGameButton.position = buttonPosition
    newGameButton.zPosition = zPosition + 1
    addChild(newGameButton)
    
    //    buttonPosition -= CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    //    pauseButton = SKSpriteNode(imageNamed: "PauseButton")
    //    pauseButton.name = "PauseButton"
    //    pauseButton.size = buttonSize
    //    pauseButton.position = buttonPosition
    //    pauseButton.zPosition = zPosition + 1
    //    addChild(pauseButton)
    
    buttonPosition -= CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    autoplayButton = SKSpriteNode(imageNamed: "play")
    let heightRatio = autoplayButton.size.height / buttonSize.height
    autoplayButton.name = "AutoplayButton"
    autoplayButton.size = buttonSize
    autoplayButton.position = buttonPosition
    autoplayButton.zPosition = zPosition + 1
    autoplayButton.isHidden = true
    addChild(autoplayButton)
    
    autoplayShine = SKSpriteNode(imageNamed: "play-shine")
    autoplayShine.name = "AutoplayButton"
    autoplayShine.size = CGSize(width: autoplayShine.size.width / heightRatio,
                                height: autoplayShine.size.height / heightRatio)
    autoplayShine.anchorPoint = CGPoint(x: 0.5, y: 0)
    autoplayShine.position = CGPoint.zero
    autoplayShine.zPosition = zPosition + 10
    autoplayButton.addChild(autoplayShine)
    
    let swirlAction = SKAction.rotate(byAngle: -π, duration: 0.5)
    let fadeIn = SKAction.fadeIn(withDuration: 0.5)
    fadeIn.timingMode = .easeOut
    let group1 = SKAction.group([swirlAction, fadeIn])
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    fadeOut.timingMode = .easeIn
    let group2 = SKAction.group([swirlAction, fadeOut])
    let hide = SKAction.hide()
    let wait = SKAction.wait(forDuration: 1)
    let show = SKAction.unhide()
    let sequence = SKAction.sequence([group1, group2, hide, wait, show])
    let foreverAction = SKAction.repeatForever(sequence)
    autoplayShine.run(foreverAction)
    
    buttonPosition = topRowLeftPos
    //    settingsButton = SKSpriteNode(imageNamed: "SettingsButton")
    settingsButton = SKSpriteNode(imageNamed: "settings")
    settingsButton.name = "SettingsButton"
    settingsButton.size = buttonSize
    settingsButton.position = buttonPosition
    settingsButton.zPosition = zPosition + 1
    addChild(settingsButton)
    
    buttonPosition += CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    volumeMuteButton = SKSpriteNode(imageNamed: "volume_on")
    volumeMuteButton.name = "VolumeMute"
    volumeMuteButton.size = buttonSize
    volumeMuteButton.position = buttonPosition
    volumeMuteButton.zPosition = zPosition + 1
    addChild(volumeMuteButton)
    
    
    settingsMenu.name = "SettingsMenu"
    settingsMenu.isHidden = true
    settingsMenu.zPosition = zPosition + 100
    addChild(settingsMenu)
    
    let hudOrigin = CGPoint(x: -hudSize.width / 2,
                            y: -hudSize.height / 2)
    let grayOut = SKShapeNode(rect: CGRect(origin: hudOrigin,
                                           size: hudSize))
    grayOut.fillColor = .darkGray
    grayOut.alpha = 0.9
    grayOut.name = "SettingsExit"
    grayOut.zPosition = 1
    settingsMenu.addChild(grayOut)
    
    let settingsMenuBG = SKSpriteNode(imageNamed: "PopupBg")
    settingsMenuBG.position = CGPoint.zero
    settingsMenuBG.zPosition = 2
    settingsMenu.addChild(settingsMenuBG)
    
    let settingsLabel = SKSpriteNode(imageNamed: "SettingsLabel")
    settingsLabel.position = CGPoint(x: 0, y: 132)
    settingsLabel.zPosition = 10
    settingsMenu.addChild(settingsLabel)
    
    settingsExit = SKSpriteNode(imageNamed: "ExitButtonGray")
    settingsExit.name = "SettingsExit"
    settingsExit.position = CGPoint(x: 145, y: 145)
    settingsExit.zPosition = 10
    settingsMenu.addChild(settingsExit)
    
    let volumeLabel = SKSpriteNode(imageNamed: "VolumeLabel")
    volumeLabel.position = CGPoint(x: -96, y: 52)
    volumeLabel.zPosition = 10
    settingsMenu.addChild(volumeLabel)
    
    let soundFXLabel = SKSpriteNode(imageNamed: "SoundFXLabel")
    soundFXLabel.position = CGPoint(x: -105, y: -8)
    soundFXLabel.zPosition = 10
    settingsMenu.addChild(soundFXLabel)
    
    let bigCardsLabel = SKSpriteNode(imageNamed: "BigCardsLabel")
    bigCardsLabel.position = CGPoint(x: -102, y: -68)
    bigCardsLabel.zPosition = 10
    settingsMenu.addChild(bigCardsLabel)
    
    bgVolumeSlider = SKSpriteNode(imageNamed: "SliderOn")
    bgVolumeSlider.name = "VolumeSlider"
    bgVolumeSlider.anchorPoint = CGPoint(x: 0, y: 0.5)
    bgVolumeSliderMask = SKSpriteNode(imageNamed: "SliderMask")
    bgVolumeSliderMask.name = "BGSliderMask"
    bgVolumeSliderMask.anchorPoint = CGPoint(x: 0, y: 0.5)
    bgVolumeSliderMask.xScale = 7 / 16
    
    bgCropNode = SKCropNode()
    bgCropNode.name = "BGCropNode"
    bgCropNode.addChild(bgVolumeSlider)
    bgCropNode.maskNode = bgVolumeSliderMask
    bgCropNode.position = CGPoint(x: -34, y: 57)
    bgCropNode.zPosition = 10
    settingsMenu.addChild(bgCropNode)
    let bgVolumeSliderOff = SKSpriteNode(imageNamed: "SliderOff")
    bgVolumeSliderOff.name = "VolumeSliderOff"
    bgVolumeSliderOff.anchorPoint = CGPoint(x: 0, y: 0.5)
    bgVolumeSliderOff.position = CGPoint(x: -34, y: 57)
    bgVolumeSliderOff.zPosition = 8
    settingsMenu.addChild(bgVolumeSliderOff)
    
    fxVolumeSlider = SKSpriteNode(imageNamed: "SliderOn")
    fxVolumeSlider.name = "FXSlider"
    fxVolumeSlider.anchorPoint = CGPoint(x: 0, y: 0.5)
    fxVolumeSliderMask = SKSpriteNode(imageNamed: "SliderMask")
    fxVolumeSliderMask.name = "FXSliderMask"
    fxVolumeSliderMask.anchorPoint = CGPoint(x: 0, y: 0.5)
    fxVolumeSliderMask.xScale = 0.75
    fxCropNode = SKCropNode()
    fxCropNode.name = "FXCropNode"
    fxCropNode.addChild(fxVolumeSlider)
    fxCropNode.maskNode = fxVolumeSliderMask
    fxCropNode.position = CGPoint(x: -34, y: -3)
    fxCropNode.zPosition = 10
    settingsMenu.addChild(fxCropNode)
    
    let fxVolumeSliderOff = SKSpriteNode(imageNamed: "SliderOff")
    fxVolumeSliderOff.name = "FXSliderOff"
    fxVolumeSliderOff.anchorPoint = CGPoint(x: 0, y: 0.5)
    fxVolumeSliderOff.position = CGPoint(x: -34, y: -3)
    fxVolumeSliderOff.zPosition = 8
    settingsMenu.addChild(fxVolumeSliderOff)
    
    bigCardsButton = SKSpriteNode(imageNamed: "SwitchOff")
    bigCardsButton.name = "BigCardsSwitch"
    bigCardsButton.position = CGPoint(x: 128, y: -61)
    bigCardsButton.zPosition = 6
    settingsMenu.addChild(bigCardsButton)
  } // setupHUD()
  
  func showAutoplayButton() {
    autoplayButton.alpha = 0
    autoplayButton.isHidden = false
    let fadeIn = SKAction.fadeIn(withDuration: 1)
    fadeIn.timingMode = .easeIn
    autoplayButton.run(fadeIn)
  } // showAutoPlayButton
  
  func hideUndoButton() {
    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
    let hideAfter = SKAction.run {
      self.undoButton.isHidden = true
    }
    undoButton.run(SKAction.sequence([fadeOut, hideAfter]))
  } // hideUndoButton
  
  func buttonPressed(at pos: CGPoint) -> Bool {
    if let firstNode = nodes(at: pos).first, firstNode.name == "SettingsExit" {
      hideSettings()
      settingsChangedDelegate?.settingsExited()
      return true
    } else if let firstNode = nodes(at: pos).first, firstNode.name == "BigCardsSwitch" {
      toggleBigCards()
      return true
    }
    return false
  } // hudButtonPressed
  
  func volumeTouched(at pos: CGPoint) -> Bool {
    if let firstNode = nodes(at: pos).first, firstNode.name == "VolumeSlider" {
      return true
    }
    return false
  } // volumeTouched

  func fxTouched(at pos: CGPoint) -> Bool {
    if let firstNode = nodes(at: pos).first, firstNode.name == "FXSlider" {
      return true
    }
    return false
  } // fxTouched
  
  func setVolume(to level: Float) {
    var volumeLevel = CGFloat(level.clamped(0, 1))
    volumeLevel = round(volumeLevel * 16) / 16
    bgVolumeSliderMask.xScale = volumeLevel
  } // setVolume
  
  func changeVolume(to pos: CGPoint) {
    var touchPointX = convert(pos, to: self).x
    let volumeOrigX = bgCropNode.position.x
    let volumeWidth = bgVolumeSlider.size.width
    touchPointX.clamp(volumeOrigX, volumeOrigX + volumeWidth)
//    touchPointX = max(touchPointX,
//                      volumeOrigX)
//    touchPointX = min(touchPointX,
//                      volumeOrigX + volumeWidth)
    var scaleX = (touchPointX - volumeOrigX) / volumeWidth
    scaleX = round(scaleX * 16) / 16
    bgVolumeSliderMask.xScale = scaleX
    settingsChangedDelegate?.volumeChanged(to: Float(scaleX))
  } // changeVolume
  
  func changeFX(to pos: CGPoint) {
    var touchPointX = convert(pos, to: self).x
    let volumeOrigX = fxCropNode.position.x
    let volumeWidth = fxVolumeSlider.size.width
    touchPointX.clamp(volumeOrigX, volumeOrigX + volumeWidth)
//    touchPointX = max(touchPointX,
//                      volumeOrigX)
//    touchPointX = min(touchPointX,
//                      volumeOrigX + volumeWidth)
    var scaleX = (touchPointX - volumeOrigX) / volumeWidth
    scaleX = round(scaleX * 16) / 16
    fxVolumeSliderMask.xScale = scaleX
    settingsChangedDelegate?.fxVolumeChanged(to: Float(scaleX))
  } // changeFX

  func setFXVolume(to level: Float) {
    var fxVolumeLevel = CGFloat(level.clamped(0, 1))
    fxVolumeLevel = round(fxVolumeLevel * 16) / 16
    fxVolumeSliderMask.xScale = fxVolumeLevel
  } // setVolume
  
  func showSettings() {
    settingsMenu.isHidden = false
  } // showSettings
  
  func hideSettings() {
    settingsMenu.isHidden = true
  } // hideSettings
  
  func setVolumeMute(to volumeMute: Bool) {
    if volumeMute {
      volumeMuteButton.texture = SKTexture(imageNamed: "volume_off")
    } else {
      volumeMuteButton.texture = SKTexture(imageNamed: "volume_on")
    }
    self.volumeMute = volumeMute
  } // setVolumeMute
  
  func toggleVolumeMute() {
    if volumeMute {
      volumeMuteButton.texture = SKTexture(imageNamed: "volume_on")
    } else {
      volumeMuteButton.texture = SKTexture(imageNamed: "volume_off")
    }
    volumeMute = !volumeMute
    settingsChangedDelegate?.volumeMuteChanged(to: volumeMute)
  } // toggleVolumeMute
  
  func setBigCardSwitch(to bigCards: Bool) {
    if bigCards {
      bigCardsButton.texture = SKTexture(imageNamed: "SwitchOn")
    } else {
      bigCardsButton.texture = SKTexture(imageNamed: "SwitchOff")
    }
    self.bigCards = bigCards
  } // setBigCardSwitch

  func toggleBigCards() {
    if bigCards {
      bigCardsButton.texture = SKTexture(imageNamed: "SwitchOff")
    } else {
      bigCardsButton.texture = SKTexture(imageNamed: "SwitchOn")
    }
    bigCards = !bigCards
    settingsChangedDelegate?.bigCardsChanged(to: bigCards)
  } // toggleBigCards

} // HUD






