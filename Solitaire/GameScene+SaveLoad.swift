//
//  GameScene+SaveLoad.swift
//  Solitaire
//
//  Created by Eric Milhizer on 3/16/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation


extension GameScene {
  
  // Class function to create/get the path name to the saved game file
  class func savedGameURL() -> URL? {
    let fileManager = FileManager.default
    
    guard let directory = fileManager.urls(for: .libraryDirectory,
                                           in: .userDomainMask).first
      else { return nil }
    
    let saveURL = directory.appendingPathComponent("SavedGames")
    
    do {
      try fileManager.createDirectory(atPath: saveURL.path,
                                      withIntermediateDirectories: true,
                                      attributes: nil)
    } catch let error as NSError {
      fatalError("Failed to create directory \(error.debugDescription)")
    }
    
    return saveURL.appendingPathComponent("saved-game")
  } // class func: savedGameURL
  
  // Class function to retrieve this class and applicable structures
  class func loadGame() -> GameScene? {
    print("-- Trying to load game from saved data")
    var loadedGameScene: GameScene?
    
    if let retrieveURL = GameScene.savedGameURL() {
      print("  -- Found saved game URL: \(retrieveURL)")
      if FileManager.default.fileExists(atPath: retrieveURL.path) {
        print("    -- Unarchiving...")
        loadedGameScene = NSKeyedUnarchiver.unarchiveObject(withFile: retrieveURL.path) as? GameScene
        GameScene.removeSavedGame()
        print("Sucessfully Retrieved data from: \(retrieveURL.path)")
      }
    }
    
    return loadedGameScene
  } // class func: loadGame
  
  // Class function to remove saved game data from device
  class func removeSavedGame() {
    print("Trying to remove saved game data")
    if let url = GameScene.savedGameURL() {
      print("Removing saved game data at: \(url)")
      _ = try? FileManager.default.removeItem(at: url)
    }
  } // class func: removeSavedGame
  
  // Save this class and applicable structures
  func saveGame() {
    if let filePath = GameScene.savedGameURL()?.path {
      print("Saving data to: \(filePath)")
      NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
  } // saveGame

  
  
  
  
  
} // GameScene+SaveLoad






