//
//  ViewController.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2019/11/29.
//  Copyright © 2019 岸本俊祐. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var attacker: UILabel!
    @IBOutlet weak var procedure: UILabel!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var whiteStones: UILabel!
    @IBOutlet weak var blackStones: UILabel!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var message: UILabel!
    
    
    

     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // core Dataのcontextからのrequestを受け取るための変数
        var requestTransitionData = [TransitionData]()
        
        // 再生する音のインスタンス
        var audioPlayer : AVAudioPlayer! = nil
        
    //    // 石の配置
        var items = [
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
    //    var items = [
    //    [0, 0, 0, 0, 0, 0, 0, 0],
    //    [0, 0, 0, 0, 0, 1, 0, 0],
    //    [0, 0, 0, 1, 1, 1, 1, 0],
    //    [0, 1, 1, 1, 2, 1, 1, 1],
    //    [0, 0, 1, 2, 2, 2, 2, 2],
    //    [0, 1, 1, 1, 1, 1, 1, 1],
    //    [0, 0, 1, 1, 1, 1, 0, 0],
    //    [0, 0, 0, 1, 0, 0, 0, 0]
    //    ]
        
        // pass()を調べるために配置
    //    var items = [
    //    [0, 0, 0, 0, 0, 0, 0, 0],
    //    [0, 0, 0, 0, 0, 1, 0, 0],
    //    [0, 0, 0, 0, 2, 1, 1, 0],
    //    [0, 1, 1, 1, 2, 1, 1, 1],
    //    [0, 0, 1, 2, 2, 2, 2, 2],
    //    [0, 1, 1, 1, 1, 1, 1, 1],
    //    [0, 0, 1, 1, 1, 1, 0, 0],
    //    [0, 0, 0, 1, 0, 0, 0, 0]
    //    ]
        
        // 手数 Int16 はAttributeのデータ型に合わせている
        var procedures : Int16 = 0
        
        // 自分の攻撃であるかどうか
        var myAttackTurn = true
        
        // 勝敗が決したがどうか
        var gameSet = false
        
        let resultIdentifier = "reuseIdentifier"
        
        let layout = UICollectionViewFlowLayout()
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // 初期化
            firstSet()
            totalStones()
            
            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.allowsSelection = true
            
            
            // 盤の表示
            let deviceWidth = view.frame.width - 40
            let cellSize = Int(deviceWidth / 8)
            let floatMargin = (deviceWidth - CGFloat(cellSize) * 8) / 2

            layout.itemSize = CGSize(width: cellSize, height: cellSize)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 2, left: floatMargin, bottom: 0, right: floatMargin)
            collectionView.collectionViewLayout = layout
            
            
            // baseCell関連付け
            let nib = UINib(nibName: "baseCell", bundle: nil)
            collectionView!.register(nib, forCellWithReuseIdentifier: resultIdentifier)
            
            // Core Dataの保存先を表示させる
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
            
        }
        
        // 石の数集計
        func totalStones() {
            var white = 0
            var black = 0
            for i in 0 ..< items.count {
                for j in 0 ..< items[i].count {
                    if items[i][j] == 1 {
                        white += 1
                    }
                    else if items[i][j] == 2 {
                        black += 1
                    }
                }
            }
            
            whiteStones.text = String(white)
            blackStones.text = String(black)
            
            if white + black == items.count * items.count {
                if white < black {
                    print("You lose!")
                }
                else if white > black {
                    print("You Win!")
                }
                else {
                    print("Draw")
                }
                gameSet = true
            }
        }
        
        // サーチ＆パス
        func pass(observedValue : Int) -> Int {
            let allSearch = Positionable(arrays: items, myAttacks: myAttackTurn)
            print("positionable = \(allSearch.searchAll())")
            
            var doPass = observedValue
            // サーチ結果、返り値が０かつgameSetがfalseの時
            if allSearch.searchAll() == 0 && !gameSet {
                let alert = UIAlertController(title: "CAUTION!", message: "置ける場所がありません！", preferredStyle: .alert)
                let action = UIAlertAction(title: "パスする", style: .default) { (action) in
                    if self.myAttackTurn == true {
                        doPass = 1
                    } else if self.myAttackTurn == false {
                        doPass = 0
                    }
                    // 攻守交代
                    self.dataUpdate()
                    // 一度セーブしないと、戻るボタンをした時にエラーが発生する
                    self.saveTransition()
                    
    //                //相手の番(この処理がないと相手の順番にならない）
    //                if self.myAttackTurn == false {
    //
    //                    let opponent = Opponent(arrays: self.items)
    //                    opponent.checkAndFlip()
    //                    self.items = opponent.getItems()
    //
    //                    self.dataUpdate()
    //                    self.saveTransition()
    //                    self.collectionView.reloadData()
    //                }
    //
    //                self.totalStones()
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            return doPass
        }
        
        //情報の更新、Context保存
        func  dataUpdate()  {
            // 攻守交代
            myAttackTurn = !myAttackTurn
            // 手を表示
            if myAttackTurn == true {
                attacker.text = "あなたの番です"
            }
            else if myAttackTurn == false {
                attacker.text = "相手の番です"
            }

            // 手数を＋１する
            procedures += 1
            procedure.text = String(procedures)

        }
        
        // contextをcore dataに保存する
        func saveTransition() {
            // 状態をcontextに保存する
            let newTransition = TransitionData(context: self.context)
            newTransition.offenceSide = myAttackTurn
            newTransition.procedure = procedures
            var position = ""
            for i in 0 ..< items.count {
                for j in 0 ..< items[i].count {
                    position += String(items[i][j])
                }
            }
            newTransition.positionArray = position
                    
            do {
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
    //        self.collectionView.reloadData()
        }
        
        // core dataのcontextを呼び出す
        func loadTransition() {
            let request : NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
            do {
                requestTransitionData = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            // contextからデータを取り出し、データを項目に貼り付けてい
            
            let item = requestTransitionData[Int(procedures)]
            myAttackTurn = item.offenceSide
            procedures = item.procedure
            // 配列入れる
            let positions = item.positionArray
            
            var count = 0
            
            if let start = positions?.startIndex {
                for i in 0 ..< items.count {
                    for j in 0 ..< items[i].count {
                        let off = positions?.index(start, offsetBy: count)
                        let charCast = String(positions![off!])
                        items[i][j] = Int(charCast)!
                        count += 1
                    }
                }
            }
            
            print("Loadテスト\n", items)
            
            collectionView.reloadData()
        }
        
        // 初期化する
        func firstSet() {
            
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
            
            saveTransition()
            
            // 攻撃側、手数の表示
            procedure.text = String(procedures)
            attacker.text = "あなたの番です"
        }
        
        // 指定したデータの削除
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

            } catch {
                print("deleteData is error : ", error)
            }
        }
 
    
        // 初めからボタン
        @IBAction func startButtonPressed(_ sender: UIButton) {
            let alert = UIAlertController(title: "CAUTION!", message: "今のゲームを破棄しますか？", preferredStyle: .alert)
            let action = UIAlertAction(title: "はい", style: .default) { (action) in
                // 初期状態を変数に入れる
                self.items = [
                [0, 0, 0, 0, 0, 0, 0,0],
                [0, 0, 0, 0, 0, 0, 0,0],
                [0, 0, 0, 0, 0, 0, 0,0],
                [0, 0, 0, 1, 2, 0, 0,0],
                [0, 0, 0, 2, 1, 0, 0,0],
                [0, 0, 0, 0, 0, 0, 0,0],
                [0, 0, 0, 0, 0, 0, 0,0],
                [0, 0, 0, 0, 0, 0, 0,0]
                ]
                
                self.procedures = 0
                self.myAttackTurn = true
                
                // core data に初期状態の情報を保存
                self.saveTransition()
                
                // これまでの進行状況をcore data から破棄
                self.firstSet()
                self.collectionView.reloadData()
                self.totalStones()
                
            }
            let noAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    
    
        // パスボタン
        @IBAction func passButtonPressed(_ sender: UIButton) {
            
        }
    
    
        // 一つ前の石の配置に戻す
        @IBAction func reverseButtonPressed(_ sender: UIButton) {
            // 手が０の時処理しない
            if procedures == 0 {
                return
            }
            
            let request : NSFetchRequest<TransitionData> = TransitionData.fetchRequest()
            let deleteIndex = procedures
            
            // procedures番目 を -2 したデータを呼び出し、ロードする
            let index = procedures - 2
            let predicate = NSPredicate(format: "procedure = %d", index)
            var positions = ""
            
            
            request.predicate = predicate
            
            do {
                requestTransitionData = try context.fetch(request)
                for data in requestTransitionData {
                    myAttackTurn = data.value(forKey: "offenceSide") as! Bool
                    procedures = data.value(forKey: "procedure") as! Int16
                    positions = data.value(forKey: "positionArray") as! String
                }
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            var count = 0
            
            let start = positions.startIndex
             
            print("check!!!!")
            
            print(procedures)
            print(myAttackTurn)
            
            // contextからのデータを元に手を表示
            if myAttackTurn == true {
                attacker.text = "あなたの番です"
            } else {
                attacker.text = "相手の番です"
            }
            
            // 手数を表示する
            procedure.text = String(procedures)
            
            // 配置をcontextで取得したdataの通りにする
            for i in 0 ..< items.count {
                for j in 0 ..< items[i].count {
                    let off = positions.index(start, offsetBy: count)
                    let charCast = String(positions[off])
                    items[i][j] = Int(charCast)!
                    count += 1
                }
            }
            
    //        print(items)
            
            totalStones()
            collectionView.reloadData()
            
            // procedure番目のデータを削除する
            deleteData(pros: deleteIndex)
            do {
                try context.save()
            } catch {
                print("\(error)")
            }
        }
    }

    extension ViewController: UICollectionViewDataSource {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        return 64  縦 * 横
            return items.count * items[0].count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            // セルを作成か再利用する　 カスタムセルに対応させるため、baseCell型に宣言、as! baseCellでキャスト
            let cell: baseCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultIdentifier, for: indexPath) as! baseCell
            
            // カスタムセルに画像を貼り付ける、配列に対応させる。配列の値が1または２以外では.noneとする。これがないと表示がおかしくなる
            if items[indexPath.row / items.count][indexPath.row % items.count] == 1 {
                cell.cellImage.image = UIImage(named: "white-stone")
            } else if items[indexPath.row / items.count][indexPath.row % items.count] == 2 {
                cell.cellImage.image = UIImage(named: "black-stone")
            } else {
                cell.cellImage.image = .none
            }
            
            
            // 枠線の色を黒に
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            
            // itemからデータを取得して枠線の太さに設定
    //        cell.contentView.layer.borderWidth = items[indexPath.row]
            cell.contentView.layer.borderWidth = 1
            
            // cellのカラー
            cell.contentView.backgroundColor = UIColor.cyan
            
            // 選択中のセルの背景をグレーに
            let bgView = UIView()
            bgView.backgroundColor = .lightGray
            cell.selectedBackgroundView = bgView
            
            return cell
        }
    }

    extension ViewController: UICollectionViewDelegate {
       
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let cell: baseCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultIdentifier, for: indexPath) as! baseCell
            // SuperRuleをインスタンス化しサーチ
            let search = SuperRule()
            // 置ける場所があるかを調べる、availableAreaにはひっくり返せる石の数がInt型で入る
            let availableArea = search.searchPosition(row: indexPath.row / items.count, col: indexPath.row % items.count, items: items, myAttackTurn: myAttackTurn)
            // Flipクラスのインスタンス化
            let flip = Flip(arrays: items)
            
            // プロパティ監視、observedが1以上の場合、opponentの番
            var observed : Int = 0 {
                didSet(oldValue) {
                    if(observed > oldValue) {
                        if myAttackTurn == false {
                            // 黒が置ける場所があるか確認と処理
                            observed = pass(observedValue: observed)
                            print("observed")

                            let opponent = Opponent(arrays: items)
                            opponent.checkAndFlip()
                            items = opponent.getItems()

                            totalStones()
                            dataUpdate()
                            saveTransition()
                            sleep(2)
                            // アニメーション処理
                            UIView.animate(withDuration: 0, animations: {
                                //opponentが石を置く場所を取得する
                                let opponentInt = opponent.getOpponentPosition()
                                let opponentIndexPath = IndexPath(item: opponentInt, section: 0)
                                cell.cellImage.image = UIImage(named: "black-stone")
                                self.collectionView.reloadItems(at: [opponentIndexPath])
                                
                                // 音を再生
                                self.playSound(name: "setSE")
                               
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // ひっくり返る場所を取得する
                                let otherFlips = opponent.getAnimesItems()
                                // 変化させるIndexPathを入れる配列型
                                var indexPathes = [IndexPath]()
                                
                                for otherFlip in otherFlips {
                                    indexPathes.append(IndexPath(item: otherFlip, section: 0))
                                }
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    cell.cellImage.image = UIImage(named: "black-stone")
                                    self.collectionView.reloadItems(at: indexPathes)
                                    
                                    // 音を再生
                                    self.playSound(name: "flip")
                                      
                                }, completion: {(finished : Bool) in
                                   observed = 0
                                })
                            }
    //
    //                        // 白が置ける場所があるか確認と処理
                            observed = pass(observedValue: observed)
                        }

                    }
                }
            }

           
            // ひっくり返すことができ、かつ置き場所に何もないことが確認された場合の処理を書く
            if availableArea > 0 && items[indexPath.row / items.count][indexPath.row % items.count] == 0 {
                   
                // Flip class Test
                    
                flip.flipPosition(row: indexPath.row / items.count, col: indexPath.row % items.count, myAttackTurn: myAttackTurn)
                    
                print(flip.getItems())
                items = flip.getItems()
                    
                // 手数と攻守の情報を更新
                dataUpdate()
                    
                saveTransition()
                    
                totalStones()
                
                // アニメーション処理 （時間を遅らせないとUIアニメーションが実行される前にデータが更新され不具合が出る）
                    
                UIView.animate(withDuration: 0, animations: {
                    
                    cell.cellImage.image = UIImage(named: "white-stone")
                    self.collectionView.reloadItems(at: [indexPath])
                    
                    // 音を再生
                    self.playSound(name: "setSE")

                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                    let otherFlips = flip.getAnimesItems()
                    // 変化させるIndexPathを入れる配列型
                    var indexPathes = [IndexPath]()
                        
                    for otherFlip in otherFlips {
                        indexPathes.append(IndexPath(item: otherFlip, section: 0))
                    }
                        
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.cellImage.image = UIImage(named: "white-stone")
                        self.collectionView.reloadItems(at: indexPathes)
                        
                        // 音を再生
                        self.playSound(name: "flip")
                              
                    }, completion: {(finished : Bool) in
                        observed = 1
                    })
                }
                    
            }
        }
    }

    extension ViewController : AVAudioPlayerDelegate {
        func playSound(name: String) {
            guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
                print("音源ファイルが見つかりません")
                return
            }
            
            do {
                // AVAudioPlayerのインスタンス化
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                
                // AVAudioPlayerのデリゲートをセット
                audioPlayer.delegate = self
                
                // 音声の再生
                audioPlayer.play()
            } catch {
                print("再生できません")
            }
        }
        
    }


