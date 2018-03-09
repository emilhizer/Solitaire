//
//  GameScene+SettingsChanged.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation

extension GameScene: SettingsChangedDelegate {
  
  func volumeMuteChanged(to volumeMute: Bool) {
    self.volumeMute = volumeMute
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
    } else {
      audioHelper.setSoundVolume(ofSound: AudioName.Background,
                                 to: backgroundVolume)
      audioHelper.setSoundVolume(ofSound: AudioName.CardShuffle,
                                 to: soundFXVolume)
      audioHelper.setSoundVolume(ofSound: AudioName.Applause,
                                 to: soundFXVolume)
      for dealSound in dealSounds {
        audioHelper.setSoundVolume(ofSound: dealSound,
                                   to: soundFXVolume)
      }
    }
    print("Saving Volume Mute to UserDefaults: \(volumeMute)")
    UserDefaults.standard.set(volumeMute, forKey: UDKeys.VolumeMuted)
  } // volumeMuteChanged
    
  func volumeChanged(to level: Float) {
    backgroundVolume = level
    audioHelper.setSoundVolume(ofSound: AudioName.Background,
                               to: level)
    volumeMute = false
    hud.setVolumeMute(to: false)
    audioHelper.setSoundVolume(ofSound: AudioName.CardShuffle,
                               to: soundFXVolume)
    audioHelper.setSoundVolume(ofSound: AudioName.Applause,
                               to: soundFXVolume)
    for dealSound in dealSounds {
      audioHelper.setSoundVolume(ofSound: dealSound,
                                 to: soundFXVolume)
    }
  } // volumeChanged

  func fxVolumeChanged(to level: Float) {
    soundFXVolume = level
    audioHelper.setSoundVolume(ofSound: AudioName.CardShuffle,
                               to: level)
    audioHelper.setSoundVolume(ofSound: AudioName.Applause,
                               to: level)
    for dealSound in dealSounds {
      audioHelper.setSoundVolume(ofSound: dealSound,
                                 to: level)
    }
    let randomDeal = dealSounds[Int.random(dealSounds.count)]
    audioHelper.playSound(name: randomDeal,
                          withVolume: level)
    volumeMute = false
    hud.setVolumeMute(to: false)
    audioHelper.setSoundVolume(ofSound: AudioName.Background,
                               to: backgroundVolume)
  } // fxVolumeChanged
  
  func bigCardsChanged(to bigCards: Bool) {
    useBigCards = bigCards
  } // bigCardsChanged
  
  func settingsExited() {
    // Change face of cards
    for card in currentDeck.unusedCards {
      if useBigCards {
        card.useAltImage()
      } else {
        card.useMainImage()
      }
    } // unusedCards
    for card in currentDeck.usedCards {
      if useBigCards {
        card.useAltImage()
      } else {
        card.useMainImage()
      }
    } // usedCards

    print("\n-- Saving settings to User Defaults --\n")
    UserDefaults.standard.set(backgroundVolume, forKey: UDKeys.BgVolume)
    UserDefaults.standard.set(soundFXVolume, forKey: UDKeys.FXVolume)
    UserDefaults.standard.set(useBigCards, forKey: UDKeys.BigCards)
  } // settingsExited

} // extension GameScene+SettingsChanged
