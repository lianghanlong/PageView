//
//  PageView.swift
//  PageView
//
//  Created by hanlong_liang on 2018/3/28.
//  Copyright © 2018年 kolamama. All rights reserved.
//

import UIKit

class PageView: UIView {
////    
    fileprivate var titles:[String]
    fileprivate var childVcs:[UIViewController]
    fileprivate var parentVc:UIViewController
    fileprivate var style:PageStyle

    init(frame:CGRect,titles:[String],childVcs:[UIViewController],parentVc:UIViewController,style:PageStyle) {
//        Super.init isn't called on all paths before returning from initializer 
        
// Property self.titles not initialized at super.init call

        self.titles = titles
        self.childVcs = childVcs
        self.parentVc = parentVc
        self.style = style
//        Must call a designated initalizer of the superclass "UIView"
        super.init(frame:frame)
        
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - setupSubView
extension PageView {
    fileprivate func setupSubView() {
        
        // 添加titleView 到pageView中
        let titleViewFrame = CGRect.init(x: 0, y: 0, width: bounds.width, height: style.titleViewHeight)
        let titleView = TitleView.init(frame: titleViewFrame, titles: titles, style: style)
        titleView.backgroundColor = UIColor.randomColor()
        addSubview(titleView)
        
        // 添加contentView到pageView中
        let contentViewFrame = CGRect.init(x: 0, y: titleView.frame.maxY, width: bounds.size.width, height: frame.height - titleViewFrame.height)
        let contentView = ContentView.init(frame: contentViewFrame, childVcs: childVcs, parentVc: parentVc)
        contentView.backgroundColor = UIColor.randomColor()
        addSubview(contentView)
        
        titleView.delegate = contentView
        contentView.delegate = titleView
        
        
    }
}
