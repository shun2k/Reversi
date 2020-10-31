//
//  Opponent.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/16.
//  Copyright © 2020 岸本俊祐. All rights reserved.
// opponent側がどのcellを選ぶかを決定するモジュール

import Foundation

class Opponent : Flip {
    var opponentPosition : Int = 0
    private let strongArray = [0, 7, 56, 63, 2, 5, 16, 18, 21, 23, 40, 40, 42, 45, 47, 58, 61]
    private let weakArray = [1, 6, 8, 15, 48, 57, 62, 9, 14, 49, 54]
    var otherArray = [Int]()
    var opponentSelectedArray = [Int]()
//    private var items = [[Int]]()
    override init(arrays: [[Int]]) {
        super.init(arrays: arrays)
        for i in 0 ..< items.count * items.count {
            // どちらにも当てはまらない場合、otherArrayに入れる
            if !strongArray.contains(i) && !weakArray.contains(i) {
                otherArray.append(i)
            }
        }
        // otherArrayの並び順をシャッフルする
        otherArray.shuffle()
        // opponentSelectedArrayに優先順位の高いものから値を入れていく
        opponentSelectedArray = strongArray + otherArray + weakArray
    }
    
    // 優先順位の高い順番に石を置けるかどうかをチェックする
    func checkAndFlip() {
        for i in 0 ..< opponentSelectedArray.count {
            let row = opponentSelectedArray[i] / items.count
            let col = opponentSelectedArray[i] % items.count
            if items[row][col] == 0 {
                //置ける場所があった時の処理
                if searchPosition(row: row, col: col, items: items, myAttackTurn: false) > 0 {
                    // ひっくり返す処理
                    flipPosition(row: row, col: col, myAttackTurn: false)
                    opponentPosition = opponentSelectedArray[i]
                    break
                }
            }
        }
    }
    
    // 相手が置いた石の場所を取り出す
    func getOpponentPosition() -> Int {
        return opponentPosition
    }
}
