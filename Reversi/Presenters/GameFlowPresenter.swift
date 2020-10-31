//
//  GameFlowPresenter.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/06/28.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

import Foundation

//MARK: - GameFlowPreseterInput protocol
protocol GameFlowPresenterInput {
   
    var itemsArray: [[Int]] { get set }
    var myTurn: Bool { get set }
    var procedure: Int16 { get set }
    var presenceOfPass: Bool { get set }
    var selectRow: Int { get set }
    var changeStones: [Int] { get set }
    var modelDataGetcomp: Bool { get set}
    
    func didSelectCell(row: Int)   // 盤面を選択した時のため
    func pickUpLatestInformation()  //立ち上げた時にデータを取得するためのもの
    func firstSet() -> String
    func reverse()          // 戻るボタンの処理
    func getTurn() -> Bool
    func getItems() -> [[Int]]
    func getSelectRow() -> Int
    func getChangeStones() -> [Int]
    func viewDidLoad()
    func searchPositionable() -> String
    func getMDGC() -> Bool // modelからデータ取得処理が完了したかどうかを確認する
    func setMDGC()
    
}

//MARK: - GameFlowPresenterOutput protocol
protocol GameFlowPresenterOutput {
    func updateInformation(myAttackTurn: Bool, procedures: Int16, items: [[Int]], selectRow: Int)
    func setupCollectionView()
    func gameResult(finalSet: String)
    
    
}

//MARK: - GameFlowPresenter Class
final class GameFlowPresenter: GameFlowPresenterInput {
        
    private var view: GameFlowPresenterOutput!
    
    private var model: GameFlowModelInput!
    
    init(view: GameFlowPresenterOutput, model: GameFlowModelInput) {
        self.view = view
        self.model = model
    }
    
   
    
    internal var itemsArray: [[Int]] = [
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 1, 2, 0, 0,0],
        [0, 0, 0, 2, 1, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0]
    ]
    
    // myAttackTurnをobserve,falseの場合、相手番の処理を行う
    internal var myTurn: Bool = true {
        didSet(oldValue) {
            if myTurn == false {
                model.opponentTurn(items: itemsArray, turns: false, procedures: procedure, presenceOfPass: presenceOfPass) { (result) in
                    self.itemsArray = result.itemData
//                    self.myAttackTurn = result.turns
                    self.procedure = result.procedure
                    self.presenceOfPass = result.presenceOfPassed
                    self.selectRow = result.selectRow
                    self.changeStones = result.changeStones
                    self.view.updateInformation(myAttackTurn: result.turns, procedures: self.procedure, items: self.itemsArray, selectRow: self.selectRow)
                    self.modelDataGetcomp = true
                }
                print(itemsArray)
                
            } 
        }
    }
    
    internal var procedure: Int16 = 0
    
    // パスの回数
    internal var presenceOfPass = false
    
    // 選んだcell
    internal var selectRow: Int = -1
    
    // アニメーション描画する石
    internal var changeStones: [Int] = [0]
    
    // Modelからデータを取得できたか
    internal var modelDataGetcomp: Bool = false
    
    //MARK: Enum Message
    enum Message: String {
        case MyTurn = "置きたい場所をタッチしてください"
        case OppTurn = "相手の番です。お待ちください"
        case NotPutOnMyTurn = "置く場所ありません、相手の番になります"
        case NotPutOnOppTurn = "相手は置く場所がありません"
        case Win = "あなたの勝ちです"
        case Lose = "あなたの負けです"
    }
    
    //MARK: didSelectCell Method
    func didSelectCell(row: Int) {
        model.searchPosition(row: row, items: itemsArray, turns: myTurn, procedures: procedure, presenceOfPass: presenceOfPass) { (result) in
            self.itemsArray = result.itemData
//            self.myAttackTurn = result.turns
            self.procedure = result.procedure
            self.presenceOfPass = result.presenceOfPassed
            self.selectRow = result.selectRow
            self.changeStones = result.changeStones
            self.view.updateInformation(myAttackTurn: result.turns, procedures: self.procedure, items: self.itemsArray, selectRow: self.selectRow)
            self.modelDataGetcomp = true
            print(self.itemsArray)
        }
    }
    
    //MARK: searchPositionable Method
    func searchPositionable() -> String {
        let passNeeds = model.searchPositionable(arrays: itemsArray, turn: !myTurn, procedures: procedure)
       
        // 確認ログ
        print("手：\(self.procedure), 番: \(self.myTurn) パス：\(passNeeds)")
        
        switch passNeeds {
        
        
            
        case 0:     // 自分の番が終わった後の処理
            self.myTurn = false
            self.modelDataGetcomp = true
            view.updateInformation(myAttackTurn: myTurn, procedures: procedure, items: itemsArray, selectRow: -1)
            return Message.OppTurn.rawValue
            
        case 1:    // 相手の番が終わった後の処理
            self.myTurn = true
            self.modelDataGetcomp = false
            view.updateInformation(myAttackTurn: myTurn, procedures: procedure, items: itemsArray, selectRow: -1)
            return Message.MyTurn.rawValue
            
        case 2:      // 自分の番をパス
            self.myTurn = false
            self.modelDataGetcomp = true
            view.updateInformation(myAttackTurn: myTurn, procedures: procedure, items: itemsArray, selectRow: -2)
            return Message.NotPutOnMyTurn.rawValue
            
        case 3:     // 相手の番をパス
            self.myTurn = true
            self.modelDataGetcomp = false
            view.updateInformation(myAttackTurn: myTurn, procedures: procedure, items: itemsArray, selectRow: -2)
            return Message.NotPutOnOppTurn.rawValue
            
        case 4:     // ゲーム終了
            var white = 0
            var black = 0
            var messageText = ""
            for i in 0 ..< itemsArray.count {
                for j in 0 ..< itemsArray[i].count {
                    if itemsArray[i][j] == 1 {
                        white += 1
                    } else if itemsArray[i][j] == 2 {
                            black += 1
                    }
                }
            }
            if white > black {
                view.gameResult(finalSet: "Win-pic")
                messageText = Message.Win.rawValue
            } else if white < black {
                view.gameResult(finalSet: "Lose")
                messageText = Message.Lose.rawValue
            }
            self.modelDataGetcomp = false
            return messageText
            
        default:
            self.modelDataGetcomp = false
            return "エラー"
        }
        
    }
    
    //MARK: pickUpLatestInformation Method - アプリ起動時に以前の情報を取得する
    func pickUpLatestInformation() {
        // モデルから最新のデータを取り出す
        model.fetchCoreData(itemsArray: itemsArray) { (result) in
            self.itemsArray = result.itemData
            self.myTurn = result.turns
            self.procedure = result.procedure
            self.presenceOfPass = result.presenceOfPassed
            self.selectRow = result.selectRow
            self.view.updateInformation(myAttackTurn: self.myTurn, procedures: self.procedure, items: self.itemsArray, selectRow: self.selectRow)
        }
        
    }
    //MARK: getTurn Method - myTurnプロパティの値を返す
    func getTurn() -> Bool {
        return self.myTurn
    }
    
    //MARK: getItems Method - itemArrayプロパティの値を返す
    func getItems() -> [[Int]] {
        return self.itemsArray
    }
    
    //MARK: getSelectRow Method - 選択したcellの場所をIntで返す
    func getSelectRow() -> Int {
        return self.selectRow
    }
    
    //MARK: getChangeStones Method - 変更するstoneの場所を[Int]で返す
    func getChangeStones() -> [Int] {
        return self.changeStones
    }
    
    //MARK: viewDidLoad Method - ViewControllerのsetupCollectionView()を呼び出す
    func viewDidLoad() {
        view.setupCollectionView()
    }
    
    //MARK: fristSet Method - 初期化させるボタンのメソッド
    func firstSet() -> String {
        model.resetGame() { (result) in
            self.itemsArray = result.itemData
            self.myTurn = result.turns
            self.procedure = result.procedure
            self.presenceOfPass = result.presenceOfPassed
            self.view.updateInformation(myAttackTurn: self.myTurn, procedures: self.procedure, items: self.itemsArray, selectRow: result.selectRow)
            
        }
        return Message.MyTurn.rawValue
    }
    
    //MARK: reverse Method - １つ前に戻すメソッド
    func reverse() {
        model.reverseProcess(procedure: procedure, itemArray: itemsArray) { (result) in
            self.itemsArray = result.itemData
            self.myTurn = result.turns
            self.procedure = result.procedure
            self.presenceOfPass = result.presenceOfPassed
            self.view.updateInformation(myAttackTurn: self.myTurn, procedures: self.procedure, items: self.itemsArray, selectRow: result.selectRow)
        }
    }
    
    //MARK: getMDGC Method - modelDataGetcompプロパティの値を得るためのメソッド
    func getMDGC() -> Bool {
        return self.modelDataGetcomp
    }
    
    //MARK: setMDGC Method - modelDataGetcompプロパティの値をfalseにするメソッド
    func setMDGC() {
        self.modelDataGetcomp = false
    }
    
    
}

