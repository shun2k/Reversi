//
//  baseCell.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/18.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

import UIKit

class baseCell: UICollectionViewCell {
    

    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func cellStoneChenger(items: [[Int]], indexPath: Int) -> String {
        if items[indexPath / 8][indexPath % 8] == 1 {
            return "white-stone"
        } else if items[indexPath / 8][indexPath % 8] == 2 {
            return "black-stone"
        } else {
            return  "none"
        }
    }

}
