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
  func volumeChanged(to level: Float)
  func fxVolumeChanged(to level: Float)
  func bigCardsChanged(to bigCards: Bool)
  func settingsExited()
}


// MARK: - Main Class
class HUD: SKNode {
  
  // MARK: - Protocol Delegates
  weak var settingsChangedDelegate: SettingsChangedDelegate?

  // MARK: - Properties
  var hudSize: CGSize!
  var undoButton: SKSpriteNode!
  var newGameButton: SKSpriteNode!
  var pauseButton: SKSpriteNode!
  var replayButton: SKSpriteNode!
  var settingsButton: SKSpriteNode!
  
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
  
  // MARK: - Init
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(size hudSize: CGSize, hide: Bool = false) {
    
    super.init()

    self.hudSize = hudSize
    let buttonSize = CGSize(width: hudSize.width / 15,
                            height: hudSize.width / 15)
    let buttonSpacing = hudSize.width / 15
    let topRowRightPos = CGPoint(x: (hudSize.width / 2) - ((buttonSpacing + buttonSize.width) / 2),
                                 y: (hudSize.height / 2) - ((buttonSpacing + buttonSize.height) / 2))
    let topRowLeftPos = CGPoint(x: -(hudSize.width / 2) + ((buttonSpacing + buttonSize.width) / 2),
                                y: (hudSize.height / 2) - ((buttonSpacing + buttonSize.height) / 2))
    
    var buttonPosition = topRowRightPos

    isHidden = hide
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

    buttonPosition -= CGPoint(x: buttonSpacing + buttonSize.width, y: 0)
    pauseButton = SKSpriteNode(imageNamed: "PauseButton")
    pauseButton.name = "PauseButton"
    pauseButton.size = buttonSize
    pauseButton.position = buttonPosition
    pauseButton.zPosition = zPosition + 1
//    addChild(pauseButton)

    buttonPosition = topRowLeftPos
    settingsButton = SKSpriteNode(imageNamed: "SettingsButton")
    settingsButton.name = "SettingsButton"
    settingsButton.size = buttonSize
    settingsButton.position = buttonPosition
    settingsButton.zPosition = zPosition + 1
    addChild(settingsButton)

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
    grayOut.name = "GrayOut"
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

  } // init:size
  
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






