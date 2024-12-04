//
//  JokeTypeLabel.swift
//  RandomJokesApp
//
//  Created by Tristan Germer on 04.12.24.
//

import SwiftUI

struct JokeTypeLabel: View {
    var type: String

    var body: some View {
        if !type.isEmpty {
            Label(NSLocalizedString("jokeType_\(type.replacingOccurrences(of: "-", with: ""))", comment: ""), systemImage: "tag")
                .font(.caption2)
                .bold()
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.1))
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }
}

#Preview("Programming") {
    ZStack {
        Rectangle().fill(.blue.gradient)
            .rotationEffect(.degrees(180))
            .ignoresSafeArea()
        JokeTypeLabel(type: "programming")
    }
}

#Preview("Dad") {
    ZStack {
        Rectangle().fill(.brown.gradient)
            .rotationEffect(.degrees(180))
            .ignoresSafeArea()
        JokeTypeLabel(type: "dad")
    }
}
