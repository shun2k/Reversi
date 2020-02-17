//
//  Positionable.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/16.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

import Foundation

class Positionable : SuperRule {
    let array : [[Int]]
    let myAttack : Bool
    
    init(arrays: [[Int]], myAttacks: Bool) {
        array = arrays
        myAttack = myAttacks
    }
    
    func searchAll() -> Int {
        var positionable = 0
        for i in 0 ..< array.count {
            for j in 0 ..< array.count {
                // searchPositon()は石が置いてる場所もサーチしてしまうので、このif文で石が置いてる場所は飛ばすようにする
                if array[i][j] > 0 {
                    continue
                }
                let Pos = searchPosition(row: i, col: j, items: array, myAttackTurn: myAttack)
//                print("[\(i)][\(j)] = ",Pos)
                if Pos > 0 {
                    positionable += 1
                }
            }
        }
        return positionable
    }
}
