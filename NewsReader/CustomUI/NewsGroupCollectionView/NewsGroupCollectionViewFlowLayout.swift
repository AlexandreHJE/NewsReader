//
//  NewsGroupCollectionViewLayout.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/30.
//  Copyright © 2019 alexHu. All rights reserved.
//

import UIKit

class NewsGroupCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var itemWidth:CGFloat = 80
    var itemHeight:CGFloat = 50
    
    //对一些布局的准备操作放在这里
    override func prepare() {
        super.prepare()
        
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 10//self.collectionView!.bounds.width / 2 -  itemWidth
        
        let left = (self.collectionView!.bounds.width - itemWidth) / 2
        let top = (self.collectionView!.bounds.height - itemHeight) / 2
        self.sectionInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            
            let array = super.layoutAttributesForElements(in: rect)
            
            
            let visiableRect = CGRect(x: self.collectionView!.contentOffset.x,
                                      y: self.collectionView!.contentOffset.y,
                                      width: self.collectionView!.frame.width,
                                      height: self.collectionView!.frame.height)
            
            for attributes in array! {
                
                if !visiableRect.intersects(attributes.frame) {continue}
        
                let scale = CGFloat(1.0) //+ (0.8 - abs(centerX - attributes.center.x) / maxDeviation)
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
            return array
    }
    

    override func targetContentOffset(forProposedContentOffset
        proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y,
                              width: self.collectionView!.bounds.width,
                              height: self.collectionView!.bounds.height)
        
        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width * 0.5;
        
        let array = self.layoutAttributesForElements(in: lastRect)
        
        
        var adjustOffsetX = CGFloat(MAXFLOAT);
        for attri in array! {
            let deviation = attri.center.x - centerX
            
            if abs(deviation) < abs(adjustOffsetX) {
                adjustOffsetX = deviation
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }
}
