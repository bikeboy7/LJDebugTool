//
//  LJLogBaseViewController.swift
//  LJDebugTool
//
//  Created by panjinyong on 2024/8/23.
//

import UIKit

class LJLogBaseViewController: UIViewController {
    
    /// 日志
    public var log: LJDebugLog? {
        didSet { updateLogView() }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    public func initView() {
        view.addSubview(logTextView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logTextView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    public func updateLogView() {
        guard let log else { return }
        logTextView.text = log.text
        title = LJDebugTool.string(date: log.createDate, format: "yy-MM-dd HH:mm:ssZ")
    }
    
    /// log
    private(set) lazy var logTextView: UITextView = {
        let view = UITextView()
        view.inputView = UIView()
        view.delegate = self
        return view
    }()
    
    /// scrollToBottom
    public func scrollToBottom() {
        logTextView.scrollRangeToVisible(.init(location: logTextView.text.count, length: 0))
    }
}

extension LJLogBaseViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        false
    }
}
