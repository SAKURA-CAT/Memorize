//
//  AspectVGrid.swift
//  Memorize (iOS)
//
//  Created by 李抗 on 2022/5/27.
//

import SwiftUI

// when we try to create a struct we can use <xx, xxx> to tell the translater which we “don't care”
struct AspectVGrid<Item, ItemView>: View where ItemView: View, Item: Identifiable  {
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    
    
    
    init(items:[Item], aspectRatio:CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView){
        self.aspectRatio = aspectRatio
        self.items = items
        self.content = content
    }
    
    
    
    
    var body: some View {
        GeometryReader{geometry in
            VStack{
                let width:CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridItem(width:width)], spacing: 0){
                    ForEach(items){item in
                        content(item).aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
    

    private func adaptiveGridItem(width: CGFloat) -> GridItem{
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat{
        var columnCount = 1
        var rowCount = itemCount
        repeat {
            let itemWidh = size.width / CGFloat(columnCount)
            let itemHeight = itemWidh / itemAspectRatio
            if CGFloat(rowCount) * itemHeight < size.height{
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        if columnCount > itemCount{
            columnCount = itemCount
        }
        return floor(size.width / CGFloat(columnCount))
    }
}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}
