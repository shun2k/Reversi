//
//  Flip.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/16.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

// ユーザーが指定した場所に石を置き、石をひっくり返す位置の値を返すためのクラス

import Foundation

class Flip : SuperRule {
    // 現在の石の状態から、変化させた後の状態のデータを入れるための配列
    // flipPosition()内で引数にitems配列を入れても値の代入ができないので、配列のプロパティを作ってitemsのコピーを作る
    var items = [[Int]]()
    // ひっくり返す石をアニメーション表現するため、石の位置のIndexPathを入れるための配列
    var animesItems = [Int]()
    // 現在の石の位置をitemsに代入
    init(arrays: [[Int]]) {
        items = arrays
    }
    
    // 指定した位置に石を置いて、石の状態が変化した配列を返すメソッド
    // 指定した位置から８方向を順番に調べていく、
    func flipPosition(row: Int, col: Int, myAttackTurn: Bool) {
        for i in 0 ..< direction.count {
                var count = 1
                let rowDiff = direction[i][0]
                let colDiff = direction[i][1]
                var flipCount = 0
        
                while true {
                    let searchRow = row + (rowDiff * count)
                    let searchCol = col + (colDiff * count)
                    
                   // サーチ１ 枠外をサーチした場合は処理を終わる
                    if (searchRow < 0 || searchRow >= 8) || (searchCol < 0 || searchCol >= 8) {
                        flipCount = 0
                        break
                    }
                    // サーチ２ 自分の石と違う石の場合、flipCountを＋１する
                    if items[row + rowDiff * count][col + colDiff * count] == (myAttackTurn ? 2 : 1) {
                        flipCount += 1
                    }
                    // サーチ３　現在サーチしている場所が、自分の石と同じかを調べる
                    else if items[row + rowDiff * count][col + colDiff * count] == (myAttackTurn ? 1 : 2) {
                        // flipCountが１以上の場合、flipCount分の石をひっくり返して、配列に保存する
                        if flipCount > 0 {
                            for i in 0 ..< flipCount {
                                // flipCount分の石の値を変更する
                                items[row + rowDiff * (i + 1)][col + colDiff * (i + 1)] = (myAttackTurn ? 1 : 2)
                                // 変更した配列番号をindexPathの形式に変更しanimesItemsに保存していく
                                animesItems.append(((row + rowDiff * (i + 1)) * items.count) + (col + colDiff * (i + 1)))
                            }
                        }
                        // flipCountが０の場合、この方向のサーチを終え、別方向のサーチに入る
                        break
                    }
                        // 値0は石を置いてない場所を表す。石を置いてない場所であればサーチを終え、次の方向のサーチに移る
                    else if items[row + rowDiff * count][col + colDiff * count] == 0 {
                        flipCount = 0
                        break
                    }
                    count += 1
                }
        
                total += flipCount
        }
        // ひっくり返した後、石を置いたポジションの配列に石を置く
        items[row][col] = (myAttackTurn ? 1 : 2)
    }
    
    // flipPosition()後の配列の値を返すメソッド
    func getItems() -> [[Int]] {
        return items
    }
    // ひっくり返すアニメーション処理するため、処理する位置の配列を返すメソッド
    func getAnimesItems() -> [Int] {
        return animesItems
    }
    
}
