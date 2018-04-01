//
//  ViewController.swift
//  PageView
//
//  Created by hanlong_liang on 2018/3/28.
//  Copyright © 2018年 kolamama. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pageViewFrame = CGRect.init(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 64)
        
        let titles : [String] = ["第一个","第二个","第三个","第四个","第五个"]
        
        var childVcs = [UIViewController]()
        
        for _ in 0..<titles.count {
            let vc = UIViewController.init()
            vc.view.backgroundColor = UIColor.randomColor()
            childVcs.append(vc)
        }
        
        let parentVc: UIViewController = self
        
        let style = PageStyle.init()
        style.titleViewHeight = 44
        style.isScrollEnable = false
        
        
        let pageView =  PageView.init(frame: pageViewFrame, titles: titles, childVcs: childVcs, parentVc: parentVc, style: style)
        
        view.addSubview(pageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

