//
//  AudioHelper.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/22/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import AVFoundation


class AudioHelper {
  
  // MARK: - Properties
  enum Constant {
    static var volumeAdjust: Float = 0.8
    static var bgVolumeAdjust: Float = 0.4
  }
  
  // Singleton
  static let sharedInstance = AudioHelper()
  
  // Sounds
  var sounds: [String: AVAudioPlayer] = [:]
  
  // MARK: - Init and Load
  private init() {
    
  } // init
  
  // MARK: - Private Methods
  
  // Setup sound (will not play the sound, just prep it for playing)
  private func setupSound(withFileNamed filename: String, andVolume volume: Float = 0, isBackground: Bool = false) -> AVAudioPlayer? {
    
    var sound: AVAudioPlayer
    
    let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let url = resourceUrl else {
      fatalError("Could not find file: \(filename)")
      //      return nil
    }
    
    do {
      try sound = AVAudioPlayer(contentsOf: url)
      let volumeAdjust = isBackground ? Constant.bgVolumeAdjust : Constant.volumeAdjust
      sound.numberOfLoops = isBackground ? -1 : 0
      sound.prepareToPlay()
      sound.volume = volume * volumeAdjust
      return sound
    }
      
    catch {
      fatalError("Could not create audio player!")
      //      return nil
    }
  } // setupSound

  
  // MARK: - Public Methods
  
  // Setup a new sound
  func setupGameSound(name: String, fileNamed: String, withVolume volume: Float = 0, isBackground: Bool = false) {
    if let sound = setupSound(withFileNamed: fileNamed,
                              andVolume: volume,
                              isBackground: isBackground) {
      sounds[name] = sound
    }
  } // setupGameSound
  
  // Play a sound
  func playSound(name: String, withVolume volume: Float? = nil, duration: TimeInterval? = nil, fadeDuration: TimeInterval = 0) {
    
    if let sound = sounds[name] {
      var finalVolume: Float
      if let volume = volume {
        if sound.numberOfLoops == -1 {
          finalVolume = volume * Constant.bgVolumeAdjust
        } else {
          finalVolume = volume * Constant.volumeAdjust
        }
      } else {
        finalVolume = sound.volume
      }
      sound.setVolume(0, fadeDuration: 0)
      let finalDuration = duration ?? sound.duration
      if finalDuration >= sound.duration {
        sound.currentTime = 0.0
      } else {
        sound.currentTime = sound.duration - finalDuration
      }
      
      sound.setVolume(finalVolume, fadeDuration: fadeDuration)

      sound.play()
      
    } else {
      fatalError("Sound: \(name) not found")
    }
  } // playSound
  
  func setSoundVolume(ofSound name: String, to volume: Float) {
    if let sound = sounds[name] {
      if sound.numberOfLoops == -1 {
        sound.setVolume(volume * Constant.bgVolumeAdjust, fadeDuration: 0)
      } else {
        sound.setVolume(volume * Constant.volumeAdjust, fadeDuration: 0)
      }
    }
  } // setSoundVolume
  
  // Fade out a sound (and optionally stop)
  func fadeOutSound(name: String, fadeDuration: TimeInterval, andStop: Bool = false) {
    if let sound = sounds[name] {
      sound.setVolume(0.0, fadeDuration: fadeDuration)
      if andStop {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + fadeDuration) {
          sound.stop()
        }
      }
    } else {
      fatalError("Sound: \(name) not found")
    }
  } // fadeOutSound
  
  // Stop All Sounds (after optional fade out)
  func stopAllSounds(withFadeOut duration: TimeInterval = 0) {
    // No fade out
    if duration == 0 {
      for (_, sound) in sounds {
        sound.stop()
      }
      // With fade out
    } else {
      for (_, sound) in sounds {
        sound.setVolume(0.0, fadeDuration: duration)
      }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
        for (_, sound) in self.sounds {
          sound.stop()
        }
      }
      
    }
  } // stopAllSounds
  
  // Get the length (in time) of an audio file
  func duration(ofSound soundName: String) -> TimeInterval {
    if let sound = sounds[soundName] {
      return sound.duration
    }
    return 0
  } // audioLength
  
  
  
  
  
  
} // AudioHelper





