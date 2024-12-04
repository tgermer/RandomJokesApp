//
//  Joke.swift
//  RandomJokesApp
//
//  Created by Tristan Germer on 04.12.24.
//

import SwiftUI

struct Joke: Codable {
    let id: Int
    let type: String
    let setup: String
    let punchline: String
}
