//
//  LJDebugLog.swift
//  LJDebugTool
//
//  Created by panjinyong on 2021/7/9.
//

import Foundation
public struct LJDebugLog: Codable {
    var logId: String
    var createDate: Date
    var fileName: String
    var text: String = ""
    var isCrash: Bool = false
}
