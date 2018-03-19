//
//  GameScene+Observers.swift
//  Solitaire
//
//  Created by Eric Milhizer on 3/16/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation


extension GameScene {
  
  @objc func applicationDidBecomeActive() {
    print("\n  -- applicationDidBecomeActive")
    print("     -- Game State: \(gameState)")
    // Could resume from paused game state here
  }
  
  @objc func applicationWillResignActive() {
    print("\n  -- applicationWillResignActive")
    print("     -- Game State: \(gameState)")
    // Set game into paused game state here
  }
  
  @objc func applicationDidEnterBackground() {
    print("\n  -- applicationDidEnterBackground")
    print("     -- Game State: \(gameState)")
    // Only save game if user is playing
    // Any other state, don't save game, so game will load as new/fresh game
    if (gameState == .Playing) || (gameState == .Touching) || (gameState == .Animating) {
      saveGame()
    }
  }
  
  // Add Observers
  func addObservers() {
    print("Adding App Obeservers for Entering Background/Restoring")
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationDidBecomeActive),
                                           name: .UIApplicationDidBecomeActive,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationWillResignActive),
                                           name: .UIApplicationWillResignActive,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(applicationDidEnterBackground),
                                           name: .UIApplicationDidEnterBackground,
                                           object: nil)
  } // addObservers

  
  
  
} // GameScene+Observers






