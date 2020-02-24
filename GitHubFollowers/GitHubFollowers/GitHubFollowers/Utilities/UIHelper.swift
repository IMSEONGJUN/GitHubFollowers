//
//  UIHelper.swift
//  GitHubFollowers
//
//  Created by SEONGJUN on 2020/01/19.
//  Copyright © 2020 Seongjun Im. All rights reserved.
//

import UIKit

struct UIHelper {
    
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let collectionViewWidth = view.frame.width
        let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let itemsInLine: CGFloat = 3
        let itemSpacing: CGFloat = 10
        let lineSpacing: CGFloat = 10
        let availableWidth = collectionViewWidth - ((itemSpacing * (itemsInLine - 1)) + (inset.left + inset.right))
        let itemWidth = availableWidth / itemsInLine
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = inset
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
}
