//
//  LJLogViewController.swift
//  LJDebugTool
//
//  Created by panjinyong on 2021/7/9.
//

import UIKit

class LJLogViewController: LJLogBaseViewController {
        
    /// 日志在textView中显示的文本的起点。用于日志过长需要手工清除时，标记清除位置
    private var logDisplayStartLocation = 0
    
    public var customActions: [LJDebugCustomAction] = []
    
    deinit {
        LJDebugTool.share.removeCurrentLogListener(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log = LJDebugTool.share.currentLog
        LJDebugTool.share.addCurrentLogListener(self) {[weak self] log in
            guard let self else { return }
            self.log = log
        }
        customActions.append(.init(title: "Location setting") {[weak self]  in
            guard let self else { return }
            LJDebugTool.share.showLocationSetAlert(from: self)
        })
    }
    
    override func initView() {
        super.initView()
        navigationItem.leftBarButtonItem = .init(title: "Actions", style: .plain, target: self, action: #selector(leftBarButtonAction))
        navigationItem.rightBarButtonItem = .init(title: "Log", style: .plain, target: self, action: #selector(rightBarButtonAction))
    }
    
    override func updateLogView() {
        super.updateLogView()
        guard let log else { return }
        if logDisplayStartLocation > 0 {
            let text = log.text
            logTextView.text = String(text.suffix(text.count - logDisplayStartLocation))
        }
    }
    
    @objc private func leftBarButtonAction() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let title = "v\(appVersion)"
        let sheet = UIAlertController.init(title: title, message: nil, preferredStyle: .actionSheet)
        customActions.forEach { action in
            sheet.addAction(.init(title: action.title, style: action.style, handler: { _ in
                action.action?()
            }))
        }
        sheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
    
    @objc private func rightBarButtonAction() {
        let sheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(.init(title: "Clear displayed logs", style: .default, handler: {[weak self] _ in
            guard let self else { return }
            logDisplayStartLocation = LJDebugTool.share.currentLog.text.count
            updateLogView()
        }))
        if logDisplayStartLocation > 0 {
            sheet.addAction(.init(title: "Display complete log", style: .default, handler: {[weak self] _ in
                guard let self else { return }
                logDisplayStartLocation = 0
                updateLogView()
            }))
        }
        sheet.addAction(.init(title: "History", style: .default, handler: {[weak self] _ in
            guard let self else { return }
            navigationController?.pushViewController(LJLogListViewController(), animated: true)
        }))
        sheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(sheet, animated: true, completion: nil)
    }
}
