//
//  GameRuleModel.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/06/29.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//
import UIKit
import CoreData

//MARK: - GameFlowModelInput protlcol
protocol GameFlowModelInput {

    // マスを選んだ時の処理
    func searchPosition(row: Int, items: [[Int]], turns: Bool, procedures: Int16, presenceOfPass: Bool, completion: @escaping (GameDataModel) -> ())
    
    // myAttackTurn がfalseの時だけの処理
    func opponentTurn(items: [[Int]], turns: Bool, procedures: Int16, presenceOfPass: Bool, completion: @escaping (GameDataModel) -> ())
    
    func resetGame(completion: @escaping (GameDataModel) -> ())
    
    // アプリ立ち上げ時の処理
    func fetchCoreData(itemsArray: [[Int]], completion: @escaping (GameDataModel) -> ())
    
    // reverseの処理
    func reverseProcess(procedure: Int16, itemArray: [[Int]], completion: @escaping (GameDataModel) -> ())
    
    // 石を置いた後、相手に石を置く場所があるかどうかをチェックする処理
    func searchPositionable(arrays: [[Int]], turn: Bool, procedures: Int16) -> Int
    
    
}

//MARK: - GameDataModel struckture
struct GameDataModel {
    let turns: Bool
    let procedure: Int16
    let itemData: [[Int]]
    let presenceOfPassed: Bool
    let selectRow: Int
    let changeStones: [Int]
}

//MARK: - GameModel Class
final class GameModel: GameFlowModelInput {
    
    
    // Core Data
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Core Dataのcontextからのrequestを受け取るための変数
    private var requestTransitionData = [TransitionData]()
    
    
    //MARK: searchPosition Method - 現在のデータとcellの位置を調べて、ゲームの処理をする
    func searchPosition(row: Int, items: [[Int]], turns: Bool, procedures: Int16, presenceOfPass: Bool, completion: @escaping (GameDataModel) -> ()) {
        
        
        let selectCellRow = row / 8
        let selectCellCol = row % 8
        var itemArray = items
        var myAttackTurn = turns
        var procedures = procedures
        let presenceOfPassed = presenceOfPass
        let selectRow = row
        
        let search = SuperRule()
        
        let availableArea = search.searchPosition(row: selectCellRow, col: selectCellCol, items: items, myAttackTurn: turns)
        if availableArea > 0 && items[selectCellRow][selectCellCol] == 0 {
            let flip = Flip(arrays: items)
            flip.flipPosition(row: selectCellRow, col: selectCellCol, myAttackTurn: turns)
            itemArray = flip.getItems()
            procedures += 1
            myAttackTurn = !myAttackTurn
            self.saveTransition(myAttackTurn: myAttackTurn, procedures: procedures, presenceOfPass: presenceOfPass, items: itemArray)
            
            let returnData = GameDataModel(turns: myAttackTurn, procedure: procedures, itemData: itemArray, presenceOfPassed: presenceOfPassed, selectRow: selectRow, changeStones: flip.animesItems)
            completion(returnData)
        }
    }
    
    //MARK: opponentTurn Method - myTurnがfalseになった時の処理
    func opponentTurn(items: [[Int]], turns: Bool, procedures: Int16, presenceOfPass: Bool, completion: @escaping (GameDataModel) -> ()) {
        var itemArray = items
        var myAttackTurn = turns
        var procedures = procedures
        let presenceOfPassed = presenceOfPass
        
        let opponent = Opponent(arrays: itemArray)
        opponent.checkAndFlip()
        itemArray = opponent.getItems()
        myAttackTurn = true
        procedures += 1
        let selectRow = opponent.getOpponentPosition()
        
        self.saveTransition(myAttackTurn: myAttackTurn, procedures: procedures, presenceOfPass: presenceOfPass, items: itemArray)
        
        let returnData = GameDataModel(turns: myAttackTurn, procedure: procedures, itemData: itemArray, presenceOfPassed: presenceOfPassed, selectRow: selectRow, changeStones: opponent.animesItems)
        completion(returnData)
        
    }
    
    //MARK: fetchCoreData - アプリを立ち上げた時、直前の情報を取り出す
    func fetchCoreData(itemsArray: [[Int]], completion: @escaping (GameDataModel) -> ()) {
        loadTransition()
        
        var itemsArray = itemsArray
        // .lastで最後のデータをプロパティに代入する
        
        var count = 0
        
        // CoreDataにデータがない場合があるので、この書き方
       // .lastでrequestTransitionDataの最後の行のデータを取り出し、定数itemに入れる
        if let item = requestTransitionData.last {
            // 取り出したデータの盤面配列情報を取り出す
           if let positions: String = item.positionArray {
                       print(type(of: positions))
                       let start = positions.startIndex
                       for i in 0 ..< itemsArray.count {
                           for j in 0 ..< itemsArray[i].count {
                               let off = positions.index(start, offsetBy: count)
                               let charCast = String(positions[off])
                               itemsArray[i][j] = Int(charCast)!
                               count += 1
                           }
                       }
                   }
            let returnData = GameDataModel(turns: item.offenceSide, procedure: item.procedure, itemData: itemsArray, presenceOfPassed: item.presenceOfPass, selectRow: -1, changeStones: [0])
            completion(returnData)
        } else {
            print("ラストなし")
        }
    
    }
    
    //MARK: resetGame Method - ゲームの初期化
    func resetGame(completion: @escaping (GameDataModel) -> ()) {

        // 初期状態を変数に入れる
        let items = [
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 1, 2, 0, 0,0],
        [0, 0, 0, 2, 1, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0],
        [0, 0, 0, 0, 0, 0, 0,0]
        ]
        
        // pass()を調べるために配置
//        let items = [
//        [0, 0, 0, 1, 0, 2, 2, 2],
//        [2, 0, 0, 1, 1, 2, 2, 2],
//        [1, 0, 0, 1, 1, 2, 2, 2],
//        [0, 0, 0, 1, 1, 2, 2, 2],
//        [0, 0, 0, 1, 1, 2, 2, 2],
//        [0, 0, 0, 1, 1, 2, 2, 2],
//        [0, 0, 0, 1, 2, 2, 2, 2],
//        [0, 0, 0, 1, 2, 2, 2, 2]
//        ]

        let procedures = Int16(0)
        let myAttackTurn = true
        let presenceOfPass = false

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TransitionData")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? TransitionData else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Delete all data in error :", error)
        }
        self.saveTransition(myAttackTurn: myAttackTurn, procedures: procedures, presenceOfPass: presenceOfPass, items: items)
        
        let returnData = GameDataModel(turns: myAttackTurn, procedure:procedures, itemData: items, presenceOfPassed: presenceOfPass, selectRow: -1, changeStones: [0])
        completion(returnData)
    }
    
    // reverseの処理
    func reverseProcess(procedure: Int16, itemArray: [[Int]], completion: @escaping (GameDataModel) -> ()) {
        if procedure == 0 {
            return
        }
        
//        let request: NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
//        let deleteIndex = procedure
        var positions = ""
        var presenceOfPass: Bool = false
        var myAttackTurn: Bool = true
        var procedures: Int16 = procedure
        var items = itemArray
        

//
//        if myAttackTurn == false || presenceOfPass == true {
//            specifiedData = specifyData(specifyInt: procedures)
//        }
        
        repeat {
            // procedureを-1したデータを呼び出し、ロードする
            let index = procedures - 1
//            let predicate = NSPredicate(format: "procedure = %d", index)
//            request.predicate = predicate
            
            let specifiedData =  specifyData(specifyInt: index)
            
            for data in specifiedData {
                myAttackTurn = data.offenceSide
                procedures = data.value(forKey: "procedure") as! Int16
                positions = data.value(forKey: "positionArray") as! String
                presenceOfPass = data.value(forKey: "presenceOfPass") as! Bool
            }


            deleteData(pros: procedures + 1)
            print("presenceOfPass:", presenceOfPass, "ループ終盤のprocedures: \(procedures)", "myAttackTurn:", myAttackTurn)
            

        } while presenceOfPass == true || myAttackTurn == false
        
        var count = 0

        let start = positions.startIndex

        for i in 0 ..< items.count {
            for j in 0 ..< items[i].count {
                let off = positions.index(start, offsetBy: count)
                let charCast = String(positions[off])
                items[i][j] = Int(charCast)!
                count += 1
            }
        }
        
        let returnData = GameDataModel(turns: myAttackTurn, procedure:procedures, itemData: items, presenceOfPassed: presenceOfPass, selectRow: -1, changeStones: [0])
        completion(returnData)
        
    }
    
    //MARK: searchPositionable Method - パスの必要があるか、勝敗が決しているかを調べる
    func searchPositionable(arrays: [[Int]], turn: Bool, procedures: Int16) -> Int {
        // Positionable クラスを使って両方のターンともにパスが不要かどうかをチェックする
        let positionable = Positionable(arrays: arrays, myAttacks: turn)
        let reversePositionable = Positionable(arrays: arrays, myAttacks: !turn)
        // searchAllメソッドで置ける場所を数を取得する
        let positionableValue = positionable.searchAll()
        let reversePositionableValue = reversePositionable.searchAll()
        let passJudgeData = (turn, positionableValue, reversePositionableValue)
        print(passJudgeData)
        switch passJudgeData {
        case (false, 1..., 0...): //相手の番をサーチ、パスなし
            return 0
            
        case (true, 1..., 0...):   // 自分の番をサーチ、パスなし
            return 1
            
        case (true, 0, 1...):   // 自分の番をサーチ、パス要
            coredataUpdate(procedures: procedures) // precenceOfPassをtrueにして保存
            return 2
            
        case (false, 0, 1...):    // 相手の番をサーチ、パス要
            coredataUpdate(procedures: procedures) // precenceOfPassをtrueにして保存
            return 3
        case (true, 0, 0), (false, 0, 0):   // 両方とも置く場所がない、ゲーム終了
            return 4
        case (_, _, _):
            return -1
        }
    }

    //MARK:- Coredata relavent Methods
    //MARK: saveTransition Method - Core Data 保存
    func saveTransition(myAttackTurn: Bool, procedures: Int16, presenceOfPass: Bool, items: [[Int]]) {
        // 状態をcontextに保存する
        let newTransition = TransitionData(context: self.context)
        newTransition.offenceSide = myAttackTurn
        newTransition.procedure = procedures
        newTransition.presenceOfPass = presenceOfPass
        var position = ""
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                position += String(items[i][j])
            }
        }
        newTransition.positionArray = position

        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }

    }

    //MARK: loadTransition Method -  Core Data (全件)呼び出し
    func loadTransition() {
        let request : NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
        do {
            requestTransitionData = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

    }

    //MARK: deleteData Method -  指定した手数の情報を削除
    func deleteData(pros: Int16) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TransitionData")
        let predicate = NSPredicate(format: "procedure = %d", pros)
        fetchRequest.predicate = predicate

        do {
            let requests = try context.fetch(fetchRequest)
            if(!requests.isEmpty) {
                for i in 0..<requests.count {
                    let deleteObject = requests[i] as! TransitionData
                    context.delete(deleteObject)
                }
            }
            // context保存
            try context.save()

        } catch {
            print("deleteData is error : ", error)
        }
    }


    //MARK: coredataUpdate Method - パスする際にpresenceOfPassをtrueに更新するためのメソッド
    func coredataUpdate(procedures: Int16) {
        let request : NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
        let predicate = NSPredicate(format: "%K = %d", "procedure", procedures)
        request.predicate = predicate

        do {
            // predicateの内容で抽出し、データを更新
            requestTransitionData = try context.fetch(request)
            for data in requestTransitionData {
                data.presenceOfPass = true
            }
            // context保存
            try context.save()


        } catch {
            print("Error update from context \(error)")
        }

    }
    
   //MARK: specifyData Method - 指定した情報を呼び出す
    func specifyData(specifyInt: Int16) -> [TransitionData] {
        let request: NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
        let predicate = NSPredicate(format: "procedure = %d", specifyInt)
        request.predicate = predicate
        
        do {
            requestTransitionData = try context.fetch(request)
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        return requestTransitionData
    }
    
    
}
