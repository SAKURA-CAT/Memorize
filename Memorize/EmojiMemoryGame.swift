//
//  EmojiMemoryGame.swift
//  Memorize (iOS)
//
//  Created by 李抗 on 2022/5/22.
//

import SwiftUI


class EmojiMemoryGame: ObservableObject{
    
    typealias Card = MemoryGame<String>.Card
    
    static let emojis = ["🙃", "😉", "😂", "😝", "😌", "🥹", "🤓", "😗", "🤨", "😉", "😅", "🥳", "🥸", "😏", "😛", "😋", "😘", "😍", "🥰", "🤩", "🤑", "🥴", "🤕", "🤮", "🤐", "🤔"]
    
    private static func createMemoryGame(_ numberOfPairsOfCards:Int, _ ifShuffle:Bool) -> MemoryGame<String> {
        MemoryGame<String>(numberOfPairsOfCards, shuffle: ifShuffle) {pairIndex in EmojiMemoryGame.emojis[pairIndex]}
    }
    
    @Published private var model: MemoryGame<String>
    
    private var numberOfPairsOfCards: Int
    
    private var ifShuffle: Bool
    
    // i am try to use a param to control if shuffle while debugging
    init(numberOfPairsOfCards:Int = 10, ifShuffle:Bool = true){
        self.numberOfPairsOfCards = numberOfPairsOfCards
        self.ifShuffle = ifShuffle
        model = EmojiMemoryGame.createMemoryGame(self.numberOfPairsOfCards, self.ifShuffle)
    }
    
//    var objectWillChange: ObservableObjectPublisher
    
    
    var cards:Array<Card>{
        return model.cards
    }
    
    // MARK: - Intent(s)
    func choose(_ card: Card){
//        objectWillChange.send()
        model.choose(card)
    }
    
    func shuffle(){
        model.shuffle()
    }
    
    func restart(){
        model = EmojiMemoryGame.createMemoryGame(self.numberOfPairsOfCards, self.ifShuffle)
    }
    
    func anotherCardWithSameContent(_ choosenCard: Card) -> Card?{
        for card in cards {
            if card.content == choosenCard.content && card.id != choosenCard.id{
                return card
            }
        }
        return nil
    }
}
