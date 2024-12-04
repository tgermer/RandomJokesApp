//
//  JokeType.swift
//  RandomJokesApp
//
//  Created by Tristan Germer on 01.12.24.
//

import SwiftUI

enum JokeType: String, CaseIterable {
    case all = "https://official-joke-api.appspot.com/jokes/random"
    case general = "https://official-joke-api.appspot.com/jokes/general/random"
    case programming = "https://official-joke-api.appspot.com/jokes/programming/random"
    case knockKnock = "https://official-joke-api.appspot.com/jokes/knock-knock/random"
    case dad = "https://official-joke-api.appspot.com/jokes/dad/random"
    
    var displayName: String {
        switch self {
        case .all: return "Random of all Types"
        case .general: return "General"
        case .programming: return "Programming"
        case .knockKnock: return "Knock Knock"
        case .dad: return "Dad"
        }
    }
    
    var localizedName: String {
            switch self {
            case .all: return NSLocalizedString("jokeType_all", comment: "Random of all Types")
            case .general: return NSLocalizedString("jokeType_general", comment: "General")
            case .programming: return NSLocalizedString("jokeType_programming", comment: "Programming")
            case .knockKnock: return NSLocalizedString("jokeType_knockknock", comment: "Knock Knock")
            case .dad: return NSLocalizedString("jokeType_dad", comment: "Dad")
            }
        }
    
    // Gibt die URL des jeweiligen Typs zurück
    func urlString() -> String {
        return self.rawValue
    }
    
}

