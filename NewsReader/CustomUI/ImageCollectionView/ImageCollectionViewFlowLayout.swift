//
//  ImageCollectionViewFlowLayout.swift
//  NewsReader
//
//  Created by 胡仁恩 on 2019/8/30.
//  Copyright © 2019 alexHu. All rights reserved.
//

// 參考自: https://www.hangge.com/blog/cache/detail_1602.html

import UIKit

class ImageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var itemWidth:CGFloat = 500
    var itemHeight:CGFloat = 250
    
    
    override func prepare() {
        super.prepare()

        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0//self.collectionView!.bounds.width / 2 -  itemWidth
        
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
                let scale = CGFloat(1.0)// + (0.8 - abs(centerX - attributes.center.x) / maxDeviation)
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
            return array
    }
    
    /**
     用来设置collectionView停止滚动那一刻的位置(实现目的是当停止滑动，时刻有一张图片是位于屏幕最中央的)
     proposedContentOffset: 原本collectionView停止滚动那一刻的位置
     velocity:滚动速度
     返回：最终停留的位置
     */
    override func targetContentOffset(forProposedContentOffset
        proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y,
                              width: self.collectionView!.bounds.width,
                              height: self.collectionView!.bounds.height)

        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width * 0.5
        let array = self.layoutAttributesForElements(in: lastRect)
        var adjustOffsetX = CGFloat(MAXFLOAT);
        for attri in array! {
            let deviation = attri.center.x - centerX
            if abs(deviation) < abs(adjustOffsetX) {
                adjustOffsetX = deviation
            }
        }
        print("stop \(CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y))")
        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }

}
