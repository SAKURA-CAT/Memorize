//
//  EmojiMemoryGameView.swift
//  Shared
//
//  Created by 李抗 on 2022/5/1.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var  game: EmojiMemoryGame
    
    @Namespace private var dealingNamespace
    
     
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card){
        dealt.insert(card.id)
    }
    
    func dealAllCards(){
        for card in game.cards{
            deal(card)
        }
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool{
        return !dealt.contains(card.id)
    }
    
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation{
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}){
            delay = Double(index) * CardConstants.totalDealDuration / Double(game.cards.count)
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    var deckBody: some View{
        ZStack{
            ForEach(game.cards.filter({isUndealt($0)})){ card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
            }
        }
        .frame(width: CardConstants.undealWidth, height: CardConstants.undealHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
            // "deal" my cards
            for card in game.cards{
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    private struct CardConstants{
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealHeight:CGFloat = 90
        static let undealWidth = undealHeight * aspectRatio
    }
    
    
    var gameView: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in cardView(for: card) })
            .foregroundColor(CardConstants.color)
    }
    
    var shuffle:some View{
        Button("shuffle"){
            withAnimation {
                game.shuffle()
            }
        }
    }
    
    var restart:some View{
        Button("Restart"){
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom){
            VStack{
                gameView
                HStack{
                    shuffle
                    Spacer()
                    restart
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    private func zIndex(of card:EmojiMemoryGame.Card) -> Double{
        -Double(game.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    @ViewBuilder
    private func cardView(for card: EmojiMemoryGame.Card) -> some View{
        if isUndealt(card) || (card.isMatched && !card.isFaceUp){
            Color.clear
        }else{
            CardView(card: card)
            .padding(4)
            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
            .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
            .zIndex(zIndex(of:card))
            .onTapGesture {
                withAnimation {
                    game.choose(card)
                }
            }
        }
    }
}



struct CardView: View{
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaing:Double = 0
    
    var body: some View{
        GeometryReader(content: { geometry in
            ZStack{
                Group{
                    if card.isConsumingBonusTime{
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1-animatedBonusRemaing)*360 - 90))  // left is 0
                            .onAppear{
                                animatedBonusRemaing = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaing = 0
                                }
                            }
                    }else{
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1-card.bonusRemaining) * 360 - 90))
                    }
                }
                .padding(DrawingConstant.circlePadding)
                .opacity(DrawingConstant.circleOpacity)
                Text(card.isMatched ? "❤️‍🔥" : card.content)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .font(Font.system(size:DrawingConstant.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
                
            }
            .cardify(isFaceUp: card.isFaceUp)
        })
    }
    
    // calculate the scale rate
    private func scale(thatFits: CGSize) -> CGFloat {
        DrawingConstant.textSize(in: thatFits) / DrawingConstant.fontSize
    }
    
    
    private func font(in size: CGSize) -> Font{
        Font.system(size:DrawingConstant.textSize(in: size))
    }
    
    // we can use private struct define and collect our constant
    private struct DrawingConstant{
        static let fontSize:CGFloat = 32  // base font size
        static let mininumFont:CGFloat = 1.0
        static let radioOfFont:CGFloat = 0.7
        static let circlePadding:CGFloat = 5
        static let circleOpacity:CGFloat = 0.6
        
        // input a CGSize, return a CGFloat that fit the size.
        static func textSize(in size: CGSize) -> CGFloat{
            max(min(size.height, size.width) * radioOfFont, mininumFont)
        }
    }
}
 



// 这部分用于便捷展示
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame(ifShuffle: true)
//        if let firstCard = game.cards.first{
//            game.choose(firstCard)
//        }
//        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
    }
}
