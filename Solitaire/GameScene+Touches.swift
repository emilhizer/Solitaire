//
//  GameScene+Touches.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  
  
  // MARK: - Touches
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Determine if any nodes have actions in process
    var actionsInProcess = false
    enumerateChildNodes(withName: "//*") {
      (node, stop) in
      if node.name == "Card" && node.hasActions() {
        actionsInProcess = true
        print("Hey! Cards in motion!")
        stop.initialize(to: true)
      }
    }
    
    if !actionsInProcess {
      if gameState == .Playing {
        priorGameState = .Playing
        gameState = .Touching
        if let touch = touches.first {
          touchDown(atPoint: touch.location(in: self))
        }
      }
    } // no actions currently in process
  } // touchesBegan
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .Touching {
      if let touch = touches.first {
        touchMoved(toPoint: touch.location(in: self))
      }
    } else {
      touchCancelled()
    }
  } // touchesMoved
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .Touching {
      if let touch = touches.first {
        touchUp(atPoint: touch.location(in: self))
      }
    } else {
      touchCancelled()
    }
    gameState = priorGameState
  } // touchesEnded
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchCancelled()
    gameState = priorGameState
  } // touchesCancelled
  
  
} // GameScene+Touches






