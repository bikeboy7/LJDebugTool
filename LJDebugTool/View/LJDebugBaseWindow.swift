//
//  LJDebugBaseWindow.swift
//  LJDebugTool
//
//  Created by panjinyong on 2023/6/16.
//

import UIKit

class LJDebugBaseWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    public func initView() {
        rootViewController = UIViewController()
        windowLevel = UIWindow.Level.init(UIWindow.Level.alert.rawValue + 20)
        backgroundColor = .red
        alpha = 0.5
        addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panAction(pan:))))
        isHidden = false
    }
    
    /// Drag float window
    @objc private func panAction(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self)
        let sWidth = UIScreen.main.bounds.size.width
        let sHeight = UIScreen.main.bounds.size.height
        var frame = self.frame
        var newX = frame.origin.x + translation.x
        if newX < 0 {
            newX = 0
        } else if newX + frame.width > sWidth {
            newX = sWidth - frame.width
        }
        var newY = frame.origin.y + translation.y
        if newY < 44 {
            newY = 44
        } else if newY + frame.height > sHeight {
            newY = sHeight - frame.height
        }
        frame.origin.x = newX
        frame.origin.y = newY
        self.frame = frame
        pan.setTranslation(.zero, in: self)
    }

}
