//
//  MemorizeApp.swift
//  Shared
//
//  Created by 李抗 on 2022/5/1.
//

import SwiftUI

@main
struct MemorizeApp: App {
    let game = EmojiMemoryGame(numberOfPairsOfCards: 10, ifShuffle: false)
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}
