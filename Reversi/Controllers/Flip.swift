//
//  Flip.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/16.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

import Foundation

class Flip : SuperRule {
    
    // flipPosition()内で引数にitems配列を入れても値の代入ができないので、配列のプロパティを作ってitemsのコピーを作る
    var items = [[Int]]()
    // ひっくり返す石のIndexPathを入れる配列
    var animesItems = [Int]()
    init(arrays: [[Int]]) {
        items = arrays
    }
    
    
    
    func flipPosition(row: Int, col: Int, myAttackTurn: Bool) {
        for i in 0 ..< direction.count {
                var count = 1
                let rowDiff = direction[i][0]
                let colDiff = direction[i][1]
                var flipCount = 0
        
                while true {
                    let searchRow = row + (rowDiff * count)
                    let searchCol = col + (colDiff * count)
                    
                   // サーチ①
                    if (searchRow < 0 || searchRow >= 8) || (searchCol < 0 || searchCol >= 8) {
                        flipCount = 0
                        break
                    }
                    
                    if items[row + rowDiff * count][col + colDiff * count] == (myAttackTurn ? 2 : 1) {
                        flipCount += 1
                    }
                    else if items[row + rowDiff * count][col + colDiff * count] == (myAttackTurn ? 1 : 2) {
                        if flipCount > 0 {
                            for i in 0 ..< flipCount {
                                // 配列の要素の値を変更する
                                items[row + rowDiff * (i + 1)][col + colDiff * (i + 1)] = (myAttackTurn ? 1 : 2)
                                // 変更した配列番号をindexPathの形式に変更しanimesItemsに保存していく
                                animesItems.append(((row + rowDiff * (i + 1)) * items.count) + (col + colDiff * (i + 1)))
                            }
                        }
                        break
                    }
                    else if items[row + rowDiff * count][col + colDiff * count] == 0 {
                        flipCount = 0
                        break
                    }
                    count += 1
                }
        
                total += flipCount
        }
        // // ひっくり返した後、石を置いたポジションの配列に石を置く
        items[row][col] = (myAttackTurn ? 1 : 2)
    }
    
    func getItems() -> [[Int]] {
        return items
    }
    func getAnimesItems() -> [Int] {
        return animesItems
    }
    
}
