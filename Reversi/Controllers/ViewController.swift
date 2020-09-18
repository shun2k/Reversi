//
//  ViewController.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2019/11/29.
//  Copyright © 2019 岸本俊祐. All rights reserved.
//

import UIKit
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
    
        
    // 再生する音のインスタンス
    private var audioPlayer : AVAudioPlayer! = nil
    
    // MVP - GameFlowPresenter導入する
    private var presenter: GameFlowPresenterInput!
    private let model = GameModel()
    
    private let resultIdentifier = "reuseIdentifier"
    
    private let layout = UICollectionViewFlowLayout()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MVP - presenterをインスタンス化
        presenter = GameFlowPresenter(view: self, model: model)
       
        presenter.viewDidLoad()
        
        presenter.pickUpLatestInformation()
        
        message.text = "置きたい場所をタッチしてください"
        
        // 盤の表示
        let deviceWidth = view.frame.width - 40
        let cellSize = Int(deviceWidth / 8)
        let floatMargin = (deviceWidth - CGFloat(cellSize) * 8) / 2

        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 2, left: floatMargin, bottom: 0, right: floatMargin)
        collectionView.collectionViewLayout = layout
        
        // Core Dataの保存先を表示させる
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK: Setup collectionView
    func setupCollectionView() {
        collectionView.allowsSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        // baseCell関連付け
        let nib = UINib(nibName: "baseCell", bundle: nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: resultIdentifier)
    }


    //MARK:  Restart Button
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        presenter.firstSet()
    }

    
    @IBAction func passButtonPressed(_ sender: UIButton) {
//        coredataUpdate(procedures: procedures)
    }


    //MARK: Reverse Button
    @IBAction func reverseButtonPressed(_ sender: UIButton) {
        
        presenter.reverse()
         
    }

}

//MARK: - Collectionview Datasource Methods
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64  //縦 * 横
//        return items.count * items[0].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // セルを作成か再利用する　 カスタムセルに対応させるため、baseCell型に宣言、as! baseCellでキャスト
        let cell: baseCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultIdentifier, for: indexPath) as! baseCell
        
        // 枠線の色を黒に
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        
        // itemからデータを取得して枠線の太さに設定
//        cell.contentView.layer.borderWidth = items[indexPath.row]
        cell.contentView.layer.borderWidth = 1
        
        // cellのカラー
        cell.contentView.backgroundColor = UIColor.init(red: 0.06, green: 0.67, blue: 0.52, alpha: 1.00)
        
        //カスタムセルに画像を貼り付ける、配列に対応させる。配列の値が1または２以外では.noneとする。これがないと表示がおかしくなる
        let imageName = cell.cellStoneChenger(items: presenter.getItems(), indexPath: indexPath.row)

        switch imageName {
        case "white-stone", "black-stone":
            cell.cellImage.image = UIImage(named: imageName)
        default:
            cell.cellImage.image = .none
        }
        
        return cell
    }
}

//MARK: - Collectionview Delegate Methods
extension ViewController: UICollectionViewDelegate {
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell: baseCell = collectionView.dequeueReusableCell(withReuseIdentifier: resultIdentifier, for: indexPath) as! baseCell
        
        
       
        var gameMove: Bool = false {
            didSet(oldValue) {
                if gameMove == true {
                    DispatchQueue.main.async {
                    // アニメーション処理
                        let changeStones = self.presenter.getChangeStones()
                        let selectRow = IndexPath(item: self.presenter.getSelectRow(), section: 0)
                        var indexPathes = [IndexPath]()
                        for changeStone in changeStones {
                            indexPathes.append(IndexPath(item: changeStone, section: 0))
                        }
                        let turn = self.presenter.getTurn()
                        let imageName = turn ? "white-stone" : "black-stone"
                       
                        
                        UIView.animate(withDuration: 0, animations: {
                            cell.cellImage.image = UIImage(named: imageName)
                            self.collectionView.reloadItems(at: [selectRow])
                            
                            // 音の再生
                            self.playSound(name: "setSE")
                        })
                        
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UIView.animate(withDuration: 0.5, animations: {
                            cell.cellImage.image = UIImage(named: imageName)
                            self.collectionView.reloadItems(at: indexPathes)
                            
                            
                            
                            // 音を再生
                            self.playSound(name: "flip")
                        }, completion: {(finished: Bool) in
                            // messageの 描画のタイミング上ここに書く
                            self.message.text = self.presenter.searchPositionable()
                            
                            sleep(2)
                            
                            //gameMoveの値をsetする
                            gameMove = self.presenter.getMDGC()
                            
                               
                        })
                        }
                    }
                }
            }
        }
        
        // MVP - 起動
        presenter.didSelectCell(row: indexPath.row)
        // didSelectCell()によりdataの変更処理が終わった後、
        //presenterのmodelDataCompをtrueとする
        // gameMoveにmodelDatacompの値を入れて、描画処理が始まる
        gameMove = presenter.getMDGC()
       

    }
}

//MARK: - AvaudioPlayer Delegate Method
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

//MARK: - GameFlowPresenterOutput Methods
extension ViewController: GameFlowPresenterOutput {
    func updateInformation(myAttackTurn: Bool, procedures: Int16, items: [[Int]], selectRow: Int) {
        
        // 攻撃側のラベル表示
        if myAttackTurn == true {
            attacker.text = "あなたの番です"
            collectionView.allowsSelection = true
        }
        else if myAttackTurn == false {
            attacker.text = "相手の番です"
            collectionView.allowsSelection = false
        }
        // 手数表示
        procedure.text = String(procedures)
        
        // 石の数表示
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
        
        if selectRow == -1 {
            collectionView.reloadData()
        } else if selectRow == -2 {
            self.playSound(name: "notice")
            collectionView.reloadData()
            
        }
        
    }
    // 勝敗表示
    func gameResult(finalSet: String) {
        let image = UIImageView(image: UIImage(named: finalSet))
        let button = UIButton(type: .system)
        let backgroundView = UIView()
        
        
        backgroundView.tag = 100
        backgroundView.backgroundColor = UIColor(displayP3Red: 0.07, green: 0.06, blue: 0.25, alpha: 0.6)
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(backgroundView)
        
        // 画像の設定
        image.tag = 200
        let imageWidth = (view.frame.width / 10) * 6
        let imageHeight = (imageWidth / 4) * 3
        let imageX = (view.frame.width / 2) - (imageWidth / 2) - 25
        let imageY = (view.frame.height / 2) - (imageHeight / 2) - 25
        
        image.frame = CGRect(x: imageX, y: imageY, width: 300, height: 200)
        self.view.addSubview(image)
        
        // ボタンの設定
        button.tag = 300
        let buttonX = (view.frame.width / 2) - 50
        let buttonY = ((view.frame.height / 4) * 3) - 25
        button.setTitle("閉じる", for: .normal)
        button.sizeToFit()
        button.backgroundColor = UIColor.blue
        button.frame = CGRect(x: buttonX, y: buttonY, width: 100, height: 50)
        button.addTarget(self, action: #selector(onTap(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func onTap(sender: UIButton) {
        
        let delviews = [self.view.viewWithTag(100), self.view.viewWithTag(200), self.view.viewWithTag(300)]
        for delview in delviews {
            delview?.removeFromSuperview()
        }
        
    }
}
