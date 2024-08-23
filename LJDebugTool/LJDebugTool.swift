//
//  LJDebugTool.swift
//  LJDebugTool
//
//  Created by panjinyong on 2021/6/17.
//  Copyright © 2021 techne. All rights reserved.
//

import UIKit
import CoreLocation

/// Log change callback
public typealias CurrentLogDidChanged = (LJDebugLog) -> Void

// custom location seted callback
public typealias LocationSetCallback = (CLLocationCoordinate2D?) -> Void

public class LJDebugTool: NSObject {
    
    public static let share = LJDebugTool()
    
    /// current Log
    private(set) lazy var currentLog: LJDebugLog = {
        let date = Date()
        return LJDebugLog.init(
            logId: "\(Int(date.timeIntervalSince1970 * 1000))_\(Int.random(in: 1...100000))",
            createDate: date,
            fileName: "\(Int(date.timeIntervalSince1970 * 1000))_\(LJDebugTool.string(date: date)).txt"
        )
    }()
    
    /// historyLogArray
    private(set) lazy var historyLogArray: [LJDebugLog] = {
        loadLogList()?.sorted(by: {$0.createDate.timeIntervalSince1970 > $1.createDate.timeIntervalSince1970}) ?? []
    }()
            
    /// current log didChanged callback Dic, key: hash
    private var currentLogDidChangedDic: [Int: CurrentLogDidChanged] = [:]
    
    /// custom location did update call back dic
    var locationSetCallBacks: [String: LocationSetCallback] = [:]
    
    /// custom location
    public var customLocation: CLLocationCoordinate2D?

    private override init() {
        super.init()
        addObserver()
        addCrashObserver()
        loadCustomLocationCache()
    }

    // MARK: - UI

    fileprivate lazy var logButton: LJDebugBaseWindow = {
        let window = LJDebugBaseWindow(frame: .zero)
        window.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(logWindowTapAction)))
        window.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(logWindowLongPressAction(press:))))
        return window
    }()
    
    private lazy var logWindow: UIWindow = {
        let window = UIWindow()
        window.backgroundColor = .white
        window.rootViewController = UINavigationController.init(rootViewController: logVC)
        window.frame = UIScreen.main.bounds
        window.windowLevel = UIWindow.Level.init(UIWindow.Level.alert.rawValue + 9)
        return window
    }()
    
    private(set) lazy var logVC: LJLogViewController = {
        .init()
    }()
    
    @objc private func logWindowTapAction() {
        logWindow.isHidden = !logWindow.isHidden
    }
    
    /// scroll to the bottom
    @objc private func logWindowLongPressAction(press: UILongPressGestureRecognizer) {
        switch press.state {
        case .began:
            logVC.scrollToBottom()
        default:
            break
        }
    }
    
    // MARK: - Public
    
    /// launch
    public func launch() {
        logButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 100, y: UIScreen.main.bounds.size.height - 100, width: 40, height: 40)
        logButton.isHidden = false
    }
            
    /// append Log
    public func appendLog(_ log: String, isCrash: Bool = false) {
        self.currentLog.text.append("\n-------------------------\n\(log)")
        self.currentLog.isCrash = isCrash
        DispatchQueue.main.async {
            self.currentLogDidChangedDic.values.forEach { $0(self.currentLog) }
        }
    }
    
    /// custom actions
    public func resetCustomActions(_ actions: [LJDebugCustomAction]) {
        logVC.customActions = actions
    }
    
    /// Adds the current log listener
    public func addCurrentLogListener(_ listener: NSObjectProtocol, currentLogDidChanged: @escaping CurrentLogDidChanged) {
        self.currentLogDidChangedDic[listener.hash] = currentLogDidChanged
    }
    
    /// remove the current log listener
    public func removeCurrentLogListener(_ listener: NSObjectProtocol) {
        self.currentLogDidChangedDic.removeValue(forKey: listener.hash)
    }
}

// MARK: - Save and delete logs

extension LJDebugTool {
    /// logCachesDirectory
    private static let logCachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first?.appending("/ljDebugLog") ?? ""
    
    /// saveCurrentLog
    private func saveCurrentLog() {
        if !FileManager.default.fileExists(atPath: LJDebugTool.logCachesDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: LJDebugTool.logCachesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return
            }
        }
        do {
            let data = try JSONEncoder.init().encode(currentLog)
            try data.write(to: URL.init(fileURLWithPath: "\(LJDebugTool.logCachesDirectory)/\(currentLog.fileName)"))
        } catch {
            print(error)
        }
    }
    
    /// load all log list
    private func loadLogList() -> [LJDebugLog]? {
        do {
            var logArray: [LJDebugLog] = []
            let fileList = try FileManager.default.contentsOfDirectory(atPath: LJDebugTool.logCachesDirectory)
            fileList.forEach { (file) in
                let url = URL.init(fileURLWithPath: "\(LJDebugTool.logCachesDirectory)/\(file)")
                do {
                    let data = try Data.init(contentsOf: url)
                    let logModel = try JSONDecoder.init().decode(LJDebugLog.self, from: data)
                    logArray.append(logModel)
                } catch {
                    print(error)
                }
            }
            return logArray
        } catch {
            print(error)
            return nil
        }
    }
        
    /// clear all Log
    @discardableResult
    public func clearAllLog() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: LJDebugTool.logCachesDirectory)
            self.historyLogArray.removeAll()
            return true
        } catch {
            print(error)
            return false
        }
    }
}

// MARK: - Observer

extension LJDebugTool {
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeKeyNotification), name: UIWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc private func didBecomeKeyNotification() {
//        if UIApplication.shared.keyWindow == logButton {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { in
//                self.logButton.isHidden = true
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { in
//                    self.logButton.isHidden = false
//                }
//            }
//        }
    }
    
    @objc private func appWillTerminate() {
        saveCurrentLog()
    }
}

// MARK: crash observe
extension LJDebugTool {
    
    private func addCrashObserver() {
        NSSetUncaughtExceptionHandler { (exception) in
            let arr = exception.callStackSymbols
            let reason = exception.reason ?? ""
            let name = exception.name.rawValue
            let crash = "\r\n\r\n name:\(name) \r\n reason:\(String(describing: reason)) \r\n \(arr.joined(separator: "\r\n")) \r\n\r\n"
            LJDebugTool.share.appendLog(crash, isCrash: true)
            LJDebugTool.share.saveCurrentLog()
        }
        
        func signalExceptionHandler(signal: Int32) {
            LJDebugTool.share.appendLog(Thread.callStackSymbols.joined(separator: "\n"), isCrash: true)
            LJDebugTool.share.saveCurrentLog()
            exit(signal)
        }
        
        signal(SIGABRT, signalExceptionHandler)
        signal(SIGSEGV, signalExceptionHandler)
        signal(SIGBUS, signalExceptionHandler)
        signal(SIGTRAP, signalExceptionHandler)
        signal(SIGILL, signalExceptionHandler)
        signal(SIGHUP, signalExceptionHandler)
        signal(SIGINT, signalExceptionHandler)
        signal(SIGQUIT, signalExceptionHandler)
        signal(SIGFPE, signalExceptionHandler)
        signal(SIGPIPE, signalExceptionHandler)
    }
}

func LJLog<T>(
    _ message: T,
    file: String = #file,
    method: String = #function,
    line: Int = #line
) {
    #if DEBUG
    let date = LJDebugTool.string(date: Date())
    let log = "\(date), \((file as NSString).lastPathComponent)[\(line)], \(method):\n \(message)"
    print(log)
    LJDebugTool.share.appendLog(log)
    #endif
}

extension LJDebugTool {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func string(date: Date, format: String = "yyyy-MM-dd HH:mm:ss:SSSZ") -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
