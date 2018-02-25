//
//  GameScene+VolumeChanged.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation

extension GameScene: VolumeChangedDelegate {
  
  func volumeChanged(to level: Float) {
    backgroundVolume = level
    audioHelper.setSoundVolume(ofSound: AudioName.background,
                               to: level)
  } // volumeChanged

  func fxVolumeChanged(to level: Float) {
    soundFXVolume = level
    audioHelper.setSoundVolume(ofSound: AudioName.cardShuffle,
                               to: level)
    audioHelper.setSoundVolume(ofSound: AudioName.applause,
                               to: level)
    for dealSound in dealSounds {
      audioHelper.setSoundVolume(ofSound: dealSound,
                                 to: level)
    }
    let randomDeal = dealSounds[Int.random(dealSounds.count)]
    audioHelper.playSound(name: randomDeal,
                          withVolume: level)
  } // volumeChanged

} // extension GameScene+VolumeChanged
