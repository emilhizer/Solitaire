//
//  GameScen+Touches.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/27/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  
  
  // MARK: - Touch Execution
  func touchDown(atPoint pos : CGPoint) {
    print("Touch Down")
    if let firstNode = nodes(at: pos).first {
      if let card = Card.getCard(fromNode: firstNode) {
        print("Touched card: \(card)")
      } else {
        print("No card touched")
      }
    }
  } // touchDown
  
  func touchMoved(toPoint pos : CGPoint) {
  } // touchMoved
  
  func touchUp(atPoint pos : CGPoint) {
  } // touchUp

  func touchCancelled() {
    
  } // touchCancelled
  
  
  
  
  // MARK: - Touches
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .Playing {
      if let touch = touches.first {
        touchDown(atPoint: touch.location(in: self))
      }
    }
  } // touchesBegan
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .Playing {
      if let touch = touches.first {
        touchMoved(toPoint: touch.location(in: self))
      }
    } else {
      touchCancelled()
    }
  } // touchesMoved
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if gameState == .Playing {
      if let touch = touches.first {
        touchUp(atPoint: touch.location(in: self))
      }
    } else {
      touchCancelled()
    }
  } // touchesEnded
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchCancelled()
  } // touchesCancelled

  
  
  
  
  
} // GameScene+Touches






