//
//  Pie.swift
//  Memorize (iOS)
//
//  Created by 李抗 on 2022/5/28.
//

import SwiftUI

struct Pie:Shape{
    // we wan't the pie be cartoon so they can't be let
    var startAngle: Angle
    var endAngle: Angle
    // if we define clockwise as let people who use Pie can't change the clockwise value because let can only define onece while the initialization included
    var clockwise: Bool = false
    
    var animatableData: AnimatablePair<Double, Double>{
        get{
            AnimatablePair(startAngle.radians, endAngle.radians)
        }
        set{
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y:rect.midY)
        let radius = min(rect.width, rect.width) / 2
        let start = CGPoint(
            x: center.x + radius * CGFloat(cos(startAngle.radians)),
            y: center.y + radius * CGFloat(sin(startAngle.radians))
        )
        var p = Path()
        
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockwise  // (0, 0) is on the left top
        )
        p.addLine(to: center)
        return p
    }
}
