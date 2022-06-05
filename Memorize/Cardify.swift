//
//  Cardify.swift
//  Memorize (iOS)
//
//  Created by 李抗 on 2022/5/29.
//

import SwiftUI

struct Cardify: Animatable, ViewModifier{
    var rotation: Double // in degrees
    
    var animatableData: Double{
        get{rotation}
        set{rotation = newValue}
    }
    
    
    init(isFaceUp:Bool){
        rotation = isFaceUp ? 0 : 180  // faceUP : 0
    }
    
    func body(content: Content) -> some View {
        ZStack{
            let shape = RoundedRectangle(cornerRadius: DrawingConstant.conerRadius)
            if rotation < 90 {  // 如果需要正面朝上
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstant.lineWidth)
            } else{  // 如果需要反面朝上
                shape.fill()
            }
            content.opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, -1, 0))
    }
    
    // we can use private struct define and collect our constant
    private struct DrawingConstant{
        static let conerRadius:CGFloat = 10
        static let lineWidth:CGFloat = 3.0
    }
}


extension View{
    func cardify(isFaceUp: Bool) -> some View{
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
