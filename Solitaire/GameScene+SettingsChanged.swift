//
//  GameScene+SettingsChanged.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation

extension GameScene: SettingsChangedDelegate {
  
  func volumeChanged(to level: Float) {
    backgroundVolume = level
    audioHelper.setSoundVolume(ofSound: AudioName.Background,
                               to: level)
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
  } // fxVolumeChanged
  
  func bigCardsChanged(to bigCards: Bool) {
    //
  }
  
  func settingsExited() {
    print("\n-- Saving settings to User Defaults --\n")
    UserDefaults.standard.set(backgroundVolume, forKey: UDKeys.BgVolume)
    UserDefaults.standard.set(soundFXVolume, forKey: UDKeys.FXVolume)
    UserDefaults.standard.set(useBigCards, forKey: UDKeys.BigCards)
  } // settingsExited

} // extension GameScene+SettingsChanged
