//
//  ContentView.swift
//  PageView
//
//  Created by hanlong_liang on 2018/3/28.
//  Copyright © 2018年 kolamama. All rights reserved.
//

import UIKit

private let kCellID = "kCellID"

protocol contentViewDelegate : class {
    func contentView(_ contentView : ContentView,targetIndex : Int, progress : CGFloat)
    func contentView(_ contentView : ContentView,endScroll inIndex : Int)
}

class ContentView: UIView {

    weak var delegate : contentViewDelegate?
    
    fileprivate var childVcs = [UIViewController]()
    fileprivate var parentVc: UIViewController
    
    fileprivate lazy var startOffsetX : CGFloat = 0
    fileprivate lazy var isForbidDelegate : Bool = false
    fileprivate lazy var collectionView:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        
        let collectView:UICollectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
        collectView.dataSource = self
        collectView.delegate = self
        collectView.isPagingEnabled = true
        collectView.scrollsToTop = false //点击状态栏是否回到顶部
        collectView.showsHorizontalScrollIndicator = false
        collectView.bounces = false // 是否回弹
        
        return collectView
    }()
    init(frame:CGRect,childVcs:[UIViewController],parentVc:UIViewController) {
        
        self.childVcs = childVcs
        self.parentVc = parentVc
        super.init(frame:frame)
        
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- 初始化subView
extension ContentView {
    // fileprivate 在当前文件内可以访问
    fileprivate func setupSubView() {
        for childVc in childVcs {
            parentVc.addChildViewController(childVc)
        }
        
        addSubview(collectionView)
    }
}

// MARK:- 遵循UICollectionViewDataSource协议
extension ContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let vc = childVcs[indexPath.item]
        vc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(vc.view)
        
        return cell
        
    }
}

// MARK:- 遵循UICollectionViewDelegate
extension ContentView : UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionViewEndScroll()
    }
    
    private func collectionViewEndScroll() {

        let endIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        delegate?.contentView(self, endScroll: endIndex)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        isForbidDelegate = false
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == startOffsetX || isForbidDelegate { return }

        var targetIndex : Int = 0
        var progress : CGFloat = 0
        
        // 判断用户是左滑还是右滑
        if scrollView.contentOffset.x > startOffsetX { // 左滑
            targetIndex = Int(startOffsetX / scrollView.bounds.width) + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            progress = (scrollView.contentOffset.x - startOffsetX) / scrollView.bounds.width
        } else { // 右滑
            targetIndex = Int(startOffsetX / scrollView.bounds.width) - 1
            if targetIndex < 0 {
                targetIndex = 0
            }
            progress = (startOffsetX - scrollView.contentOffset.x) / scrollView.bounds.width
        }
        
        // 将数据传递给titleView
        delegate?.contentView(self, targetIndex: targetIndex, progress: progress)
    }
}

// MARK:- 遵循TitleViewDelegate协议
extension ContentView : TitleViewDelegate {
    func titleView(_ titleView: TitleView, didSelected currentIndex: Int) {
        
        isForbidDelegate = true
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
}
