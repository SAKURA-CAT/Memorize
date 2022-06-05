//
//  MemoryGame.swift
//  Memorize (iOS)
//
//  Created by 李抗 on 2022/5/22.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable{
    private(set) var cards: Array<Card>
    
    private var score: Double = 0
    
    private var indexOfTheOneAndTheOnlyFaceUpCard: Int?{
        get{ cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly}
        set{ cards.indices.forEach({cards[$0].isFaceUp = ($0 == newValue)})}
    }
    
    mutating func choose(_ card: Card){
//        if let choosenIndex = index(of: card){
        if let choosenIndex = cards.firstIndex(where: {$0.id == card.id}) ,
            !cards[choosenIndex].isFaceUp,
            !cards[choosenIndex].isMatched {  // find the card the user chooses, and the card is not faceUp, not Matched
            
            if let potentialMatchIndex = indexOfTheOneAndTheOnlyFaceUpCard{  // find the card the user has already chosen
                if cards[choosenIndex].content == cards[potentialMatchIndex].content{
                    cards[choosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    
                    // sum the score, average(cards[choosenIndex], cards[potentialMatchIndex])
//                    score = score + (cards[choosenIndex].bonusRemaining + cards[potentialMatchIndex].bonusRemaining) / 2
//                    print(score)
                }
                cards[choosenIndex].isFaceUp = true
            }else{  // if not (the user not chosen card, OR, the user has chosen two cards), let the card be the potenial card
                    // and let else which is not matched face down
                indexOfTheOneAndTheOnlyFaceUpCard = choosenIndex
            }
        }
    }
    
    mutating func shuffle(){
        cards.shuffle()
    }
    
    // we use the interface the Array provide to replcace it, so i make it private
    private func index(of card: Card) -> Int?{
        for i in 0..<cards.count {
            if cards[i].id == card.id{
                return i
            }
        }
        return nil // bogus! if we can't find the card, program will crash
    }
    
    init(_ numberOfPairsOfCards: Int, shuffle:Bool, createCardContent: (Int) -> CardContent){
        // cards = Array<Card>()
        // swift can infer the cards type
        cards = []
        // add numberOfPairsOfCards x 2 cards to cards array
        for pairIndex in 0..<numberOfPairsOfCards{
            let content  = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
        if shuffle{
            cards.shuffle()
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp = false{
            didSet{
                if isFaceUp{
                    startUsingBonusTime()
                }else{
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false{
            didSet{
                // it must be false -> true
                stopUsingBonusTime()
            }
        }
        var content: CardContent
        var id: Int
        
        
        // MARK: - Bonus Time
        // this could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up
        
        // can be zero which means "no bonus avaliable" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long the card has ever been faced up
        private var faceUpTime: TimeInterval{
            if let lastFaceUpdate = self.lastFaceUpDate{
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpdate)
            }else{
                return pastFaceUpTime
            }
        }
        
        
        var lastFaceUpDate:Date?
        
        
        var pastFaceUpTime: TimeInterval = 0
        
        
        // we use it to
        var bonusTimeRemaining: TimeInterval{
            return max(0, bonusTimeLimit - faceUpTime)
        }
        
        var bonusRemaining: Double{
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining / bonusTimeLimit : 0
        }
        
        var hasEarnedBonus:Bool{
            isMatched && bonusTimeRemaining > 0
        }
        
        var isConsumingBonusTime: Bool{
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime(){
            if isConsumingBonusTime, lastFaceUpDate == nil{
                lastFaceUpDate = Date()
            }
        }
        
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime(){
            pastFaceUpTime = faceUpTime
            if !isMatched{
                self.lastFaceUpDate = nil
            }
        }
        
    }
    
    
}

extension Array{
    var oneAndOnly: Element?{
        if self.count == 1{
            return self.first
        }else{
            return nil
        }
    }
}
