//
//  CustomLayout.swift
//  Reversi
//
//  Created by 岸本俊祐 on 2020/02/20.
//  Copyright © 2020 岸本俊祐. All rights reserved.
//

import UIKit

class CustomLayout: UICollectionViewLayout {
//    weak var delegate: CustomDelegate!
    
    var attributesArray = [UICollectionViewLayoutAttributes]()
    
    var contentSquare: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width - 40.0
    }
        
    // contentエリアの設定
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentSquare, height: contentSquare)
    }
    
    // セルの設定
    override func prepare() {
        guard attributesArray.isEmpty, let collectionView = collectionView else { return }
        
        let columnWidth = Int(collectionView.bounds.width / 8)
    }
        
}
