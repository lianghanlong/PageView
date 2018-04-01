//
//  TitleView.swift
//  PageView
//
//  Created by hanlong_liang on 2018/3/28.
//  Copyright © 2018年 kolamama. All rights reserved.
//

import UIKit

protocol TitleViewDelegate : class {
    func titleView(_ titleView : TitleView, didSelected currentIndex : Int)
}

class TitleView: UIView {

    weak var delegate : TitleViewDelegate?
    
    fileprivate var titles : [String]
    fileprivate var titleLabels : [UILabel] = [UILabel]()
    fileprivate var style : PageStyle
    
    fileprivate lazy var currentIndex : Int = 0
    
    //懒加载 scrollView
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView:UIScrollView = UIScrollView.init(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    // 懒加载 bottomLine
    fileprivate lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.frame.size.height = self.style.bottomLineHeight
        bottomLine.backgroundColor = self.style.bottomLineColor
        return bottomLine
    }()
    
    // 懒加载 coverView
    fileprivate lazy var coverView:UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverBgColor
        coverView.alpha = self.style.coverAlpha
        return coverView
    }()
    
    init(frame:CGRect,titles:[String],style:PageStyle) {
        
        self.titles = titles
        self.style = style
        super.init(frame: frame)
        
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- setupSubView

extension TitleView {
    fileprivate func setupSubView() {

        addSubview(scrollView)

        setupTitleLabels()

        setupTitleLabelsFrame()

        setupBottromLine()
        
        setupCoverView()
    }
    
    private func setupTitleLabels() {
        //enumerated() 这个函数会返回一个新的序列，包含了初始序列里的所有元素，以及与元素相对应的编号
        for (i,title) in titles.enumerated() {
            let titleLabel  = UILabel.init()
            titleLabel.text = title
            titleLabel.tag  = i
            titleLabel.font = style.titleFont
            titleLabel.textColor     = i == 0 ? style.selectedColor : style.normalColor
            titleLabel.textAlignment = NSTextAlignment.center
            
            scrollView.addSubview(titleLabel)
            
            // 保存label
            titleLabels.append(titleLabel)
            
            // 添加手势
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(titleLabelClick(tapges:)))
            titleLabel.addGestureRecognizer(tapGes)
            titleLabel.isUserInteractionEnabled = true
            
        }
    }
    
    private func setupTitleLabelsFrame() {
        
        let count = titles.count
        
        for (i,label) in titleLabels.enumerated() {
            
            var w:CGFloat = 0
            let h:CGFloat = bounds.height
            var x:CGFloat = 0
            let y:CGFloat = 0
    //CGFloat.greatestFiniteMagnitude是Swift 3.0语法, 相当于2.3中的CGFloat.max, 即是CGFloat的最大值
            if !style.isScrollEnable {
                
                w = bounds.width / CGFloat(count)
                x = w * CGFloat(i)
                
            } else {
                
                w = (titles[i] as NSString).boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15.0)], context: nil).width
                if i == 0 {
                    x = style.titleMargin * 0.5
                } else {
                    let preLabel = titleLabels[i - 1]
                    x = preLabel.frame.maxX + style.titleMargin
                }
            }
            
            label.frame = CGRect.init(x: x, y: y, width: w, height: h)
            
        }
        
        if style.isScrollEnable {
            scrollView.contentSize.width = titleLabels.last!.frame.maxX + style.titleMargin*0.5
        }
    }
    
    private func setupBottromLine() {
        
        guard style.isShowBottomLine else {
            return
        }
        
        scrollView.addSubview(bottomLine)
        
        bottomLine.frame.origin.x = titleLabels.first!.frame.origin.x
        bottomLine.frame.origin.y = bounds.height - style.bottomLineHeight
        bottomLine.frame.size.width = titleLabels.first!.bounds.width
    }
    
    private func setupCoverView() {
        
        guard style.isShowCoverView else {
            return
        }
        
        scrollView.addSubview(coverView)
        
        var coverW : CGFloat = titleLabels.first!.frame.width - 2*style.coverMargin
        if style.isScrollEnable {
            coverW = titleLabels.first!.frame.width + style.titleMargin * 0.5
        }
        
        let coverH : CGFloat = style.coverHeight
        
        coverView.bounds = CGRect.init(x: 0, y: 0, width: coverW, height: coverH)
        coverView.center = titleLabels.first!.center
        coverView.layer.cornerRadius = style.coverHeight*0.5
        coverView.layer.masksToBounds = true
    }
}

// MARK: - 事件处理函数
extension TitleView {
    @objc fileprivate func titleLabelClick(tapges:UITapGestureRecognizer) {

        guard let newLabel = tapges.view as? UILabel else { return }
        
        // 改变自身的titleLabel的颜色
        let oldLabel = titleLabels[currentIndex]
        oldLabel.textColor = style.normalColor
        newLabel.textColor = style.selectedColor
        currentIndex = newLabel.tag
        
        delegate?.titleView(self, didSelected: currentIndex)
        
        if style.isShowBottomLine {
            bottomLine.frame.origin.x = newLabel.frame.origin.x
            bottomLine.frame.size.width = newLabel.frame.width
        }
        
        // 调整位置
        adjustPosition(newLabel)
        

        if style.isShowCoverView {
            let coverW = style.isScrollEnable ? (newLabel.frame.width + style.titleMargin) : (newLabel.frame.width - 2 * style.coverMargin)
            coverView.frame.size.width = coverW
            coverView.center = newLabel.center
        }

    }
}

extension TitleView : contentViewDelegate {
    func contentView(_ contentView: ContentView, endScroll inIndex: Int) {

        let oldLabel = titleLabels[currentIndex]
        let newLabel = titleLabels[inIndex]

        oldLabel.textColor = style.normalColor
        newLabel.textColor = style.selectedColor
        
        currentIndex = inIndex
        
        adjustPosition(newLabel)
    }
    
    
    fileprivate func adjustPosition(_ newLabel : UILabel) {
        guard style.isScrollEnable else { return }
        var offsetX = newLabel.center.x - scrollView.bounds.width * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        let maxOffset = scrollView.contentSize.width - bounds.width
        if offsetX > maxOffset {
            offsetX = maxOffset
        }
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    func contentView(_ contentView: ContentView, targetIndex: Int, progress: CGFloat) {

        let oldLabel = titleLabels[currentIndex]
        let newLabel = titleLabels[targetIndex]
        
        let selectRGB = getGRBValue(style.selectedColor)
        let normalRGB = getGRBValue(style.normalColor)
        let deltaRGB = (selectRGB.0 - normalRGB.0, selectRGB.1 - normalRGB.1, selectRGB.2 - normalRGB.2)
        oldLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        newLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        
        if style.isShowBottomLine {
            let deltaX = newLabel.frame.origin.x - oldLabel.frame.origin.x
            let deltaW = newLabel.frame.width - oldLabel.frame.width
            bottomLine.frame.origin.x = oldLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = oldLabel.frame.width + deltaW * progress
        }
        
        if style.isShowCoverView {
            let oldW = style.isScrollEnable ? (oldLabel.frame.width + style.titleMargin) : (oldLabel.frame.width - 2 * style.coverMargin)
            let newW = style.isScrollEnable ? (newLabel.frame.width + style.titleMargin) : (newLabel.frame.width - 2 * style.coverMargin)
            let deltaW = newW - oldW
            let deltaX = newLabel.center.x - oldLabel.center.x
            coverView.frame.size.width = oldW + deltaW * progress
            coverView.center.x = oldLabel.center.x + deltaX * progress
        }
    }
    
    private func getGRBValue(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard  let components = color.cgColor.components else {
            fatalError("----------")
        }
        
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}
