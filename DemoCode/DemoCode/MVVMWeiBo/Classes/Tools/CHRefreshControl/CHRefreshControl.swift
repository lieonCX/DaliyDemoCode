//
//  CHRefreshControl.swift
//  DemoCode
//
//  Created by lieon on 16/9/26.
//  Copyright © 2016年 lieon. All rights reserved.
//

import UIKit

/// 负责刷新的逻辑
private let contentOffsetY: CGFloat = 50.0

enum RefrehState {
    case normal
    case pulling
    case wilRefresh
}

class CHRefreshControl: UIControl {
    ///  刷新控件的要适用于UITableView和UICollectionView
    private weak var scrollView: UIScrollView?
    private lazy var refreshView: CHRefreshView = CHRefreshView.refreView()
    init() {
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func beginRefresh() {
         guard let sv = scrollView else { return  }
        refreshView.state = .wilRefresh
        var inset = sv.contentInset
        inset.top += contentOffsetY
        sv.contentInset = inset
    }
    
    func endRefreshing() {
        if refreshView.state != .wilRefresh {
            return
        }
        guard let sv = scrollView else { return  }
        refreshView.state = .normal
        var inset = sv.contentInset
        inset.top -= contentOffsetY
        sv.contentInset = inset
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // 记录父视图
         guard let sv = newSuperview as? UIScrollView else { return  }
        scrollView = sv
        // 适用KVO监听父视图的滚动
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // contenOffset的y值跟contentInset有关
         guard let sv = scrollView else { return  }
        let height = -(sv.contentInset.top + sv.contentOffset.y )
        if height < 0 {
            return
        }
        // 可以根据高度设置刷新空间的frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        if sv.isDragging {
            if height > contentOffsetY && refreshView.state == .normal {
                print("放手刷新")
                refreshView.state = .pulling
            } else if height <= contentOffsetY && refreshView.state == .pulling {
                print("使劲拽")
                refreshView.state = .normal
            }
        } else {
            // 放手 -- 判断是否超过临界点
            if refreshView.state == .pulling  {
                print("准备开始刷新")
                beginRefresh()
                
            }
        }
    }
    
    private  func setupUI() {
        backgroundColor = superview?.backgroundColor
        /// 用系统原生的约束布局
        addSubview(refreshView)
        
       refreshView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
    
    override func removeFromSuperview() {
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
}
