//
//  NSObject+Extensions.swift
//  Solitaire
//
//  Created by Eric Milhizer on 2/24/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
  
  // Run block of code after delay of _ seconds
  func runAfterDelay(delayInSeconds: Int,
                     runBlock: @escaping ()->Void) {
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delayInSeconds), execute: {
      runBlock()
    })
  }
  
  // Run block of code after delay
  func runAfter(delay: TimeInterval, runBlock: @escaping ()->Void) {
    let milliDelay = Int(delay * 1000)
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + .milliseconds(milliDelay), execute: {
        runBlock()
    })
  }
  
} // Extension NSObject

