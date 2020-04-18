//
//  SuperRule.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/16.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

// ユーザーがタッチした場所に石を置けるかどうかを調べるためのクラス

import Foundation

class SuperRule {
    // 調べる方向、上、右上、右、右下、下、左下、左、左上の順番
    let direction = [[-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1]]
    var total = 0
    
    func searchPosition(row: Int, col: Int, items: [[Int]], myAttackTurn: Bool) -> Int {
        for i in 0 ..< direction.count {
                    var count = 1
                    let rowDiff = direction[i][0]
                    let colDiff = direction[i][1]
                    var flipCount = 0
                    var whileCount = 0      // コメント用の変数
            
                    while true {
                        
                        let searchRow = row + (rowDiff * count)
                        let searchCol = col + (colDiff * count)
                        // コメント用の定数 ++++++++++++++++++++++++++++++++++
                        whileCount += 1
        //                print("row:", searchRow, " col:", searchCol, "\(whileCount)回目")
                        // +++++++++++++++++++++++++++++++++++++++++++++++
                        
                        // サーチ①　枠の外に出るとループを抜ける
                        if (searchRow < 0 || searchRow >= items.count) || (searchCol < 0 || searchCol >= items.count) {
                            flipCount = 0
                            break
                        }
                        
                        // サーチ② 自分の石の色と違う色の場合、flipCountを+1
                        if items[searchRow][searchCol] == (myAttackTurn ? 2 : 1) {
                            flipCount += 1
                        }
                        // サーチ③ 自分の石の色と同じ場合、ループを抜ける
                        else if items[searchRow][searchCol] == (myAttackTurn ? 1 : 2) {
                            break
                        }
                        // サーチ④ 何もない場合、flipCountを０にし、ループを抜ける
                        else if items[searchRow][searchCol] == 0 {
                            flipCount = 0
                            break
                        }
                        count += 1
                    }
                    total += flipCount
                }
                return total
    }
}
