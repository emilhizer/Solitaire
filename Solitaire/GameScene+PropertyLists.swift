//
//  GameScene+PropertyLists.swift
//  Solitaire
//
//  Created by Eric Milhizer on 1/21/18.
//  Copyright © 2018 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

  func parseCardsData(fromPList plist: [String: Any]) {
    print("-- Parsing Cards Data")
    if let cardsDict = plist["Cards"] as? [String: Any] {
      for (key, value) in cardsDict {
        if let cards = value as? [[String: Any]] {
          let cardDeck = parseDeck(withCards: cards)
          cardDecks[key] = CardDeck(deckName: key, initialCards: cardDeck)
          print("Adding New Deck: \(key) of \(cardDeck.count) cards")
        }
      }
      print("Number of decks found: \(cardDecks.count)")
    } // "Cards" dictionary
    
  } // parseCardsData
  
  func parseDeck(withCards cards: [[String: Any]]) -> [Card] {
    var cardDeck = [Card]()
    for card in cards {
      if let frontImage = card["Name"] as? String,
        let suitName = card["Suit"] as? String,
        let value = card["Value"] as? Int {

        var cardSuit: Suit
        switch suitName {
        case "Spades":
          cardSuit = .Spades
        case "Diamonds":
          cardSuit = .Diamonds
        case "Clubs":
          cardSuit = .Clubs
        case "Hearts":
          cardSuit = .Hearts
        default:
          fatalError("Unknown suit found parsing cards dictionary: \(suitName)")
        } // turn suit string to enum
        
        var altFrontImage: String?
        if let altFaceSuffix = altFaceSuffix {
          altFrontImage = frontImage + altFaceSuffix
        }
        
        let newCard = Card(suit: cardSuit,
                           value: value,
                           frontImage: frontImage,
                           altFrontImage: altFrontImage,
                           backImage: cardBackImage)
        
        cardDeck.append(newCard)
      } // found all keys in card dictionary
    } // loop through all cards array
    
    return cardDeck
  } // deckDict2Deck
  
  func parseGameSettings(fromPList plist: [String: Any]) {
    print("-- Parsing Game Settings Data")
    if let settingsDict = plist["Settings"] as? [String: Any] {
      if let altFaceSuffix = settingsDict["AltFaceSuffix"] as? String {
        self.altFaceSuffix = altFaceSuffix
        print("  -- Found Alt Face Suffix: \(altFaceSuffix)")
      }
    } // "Settings" dictionary
    
  } // parseGameSettings

  
  // MARK: - Get Property List from .plist file
  func getPList(fromFile fileName: String) -> [String: Any]? {
    // If fileName doesn't have .plist then add it
    var finalFileName = fileName
    if let fileURL = URL(string: fileName), fileURL.pathExtension == "plist" {
      finalFileName = (fileURL.deletingPathExtension)().absoluteString
    }
    print("Getting PLIST Data from: \(finalFileName)")
    
    guard let fileURL = Bundle.main.url(forResource: finalFileName,
                                        withExtension: "plist") else {
                                          print("Could not find PList file: \(fileName).plist")
                                          return nil
    }
    guard let data = try? Data(contentsOf: fileURL) else {
      print("Could not find PList data in file: \(fileURL)")
      return nil
    }
    
    guard let result = try?
      PropertyListSerialization.propertyList(
        from: data,
        options: [],
        format: nil) as? [String: Any]
      else {
        print("PList data not in correct format: \(data)")
        return nil
    }
    
    return result
  } // getPList
  
  
  
  
  
  
  
} // GameScene + PropertyLists
