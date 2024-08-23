//
//  LJDebugCustomAction.swift
//  LJDebugTool
//
//  Created by panjinyong on 2024/8/23.
//

import UIKit

public struct LJDebugCustomAction {
    var title: String?
    var style: UIAlertAction.Style = .default
    var action: (() -> Void)?
}
