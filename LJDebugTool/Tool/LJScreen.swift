//
//  LJScreen.swift
//  FairfieldUser
//
//  Created by panjinyong on 2021/8/19.
//

import UIKit
struct LJScreen {
    //屏幕大小
    static let height: CGFloat = UIScreen.main.bounds.size.height
    static let width: CGFloat = UIScreen.main.bounds.size.width
    
    //iPhone6的比例
    static let scaleWidthOfI6 = UIScreen.main.bounds.size.width / 375.0
    static let scaleHeightOfI6 = UIScreen.main.bounds.size.height / 667.0
    
    //iPhoneX的比例
    static let scaleWidthOfIX = UIScreen.main.bounds.size.width / 375.0
    static let scaleHeightOfIX = UIScreen.main.bounds.size.height / 812.0
    static let scaleHeightLessOfIX = scaleHeightOfIX > 1 ? 1 : scaleHeightOfIX
    static let scaleWidthLessOfIX = scaleWidthOfIX > 1 ? 1 : scaleWidthOfIX


    // iphoneX
    static let navigationBarHeight: CGFloat =  isiPhoneXMore() ? 88.0 : 64.0
    static let safeAreaBottomHeight: CGFloat =  isiPhoneXMore() ? 34.0 : 0
    static let statusBarHeight: CGFloat = isiPhoneXMore() ? 44.0 : 20.0
    static let tabBarHeight: CGFloat = isiPhoneXMore() ? 83.0 : 49.0

    // iphoneX
    static func isiPhoneXMore() -> Bool {
        var isMore:Bool = false
        if #available(iOS 11.0, *) {
            isMore = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > CGFloat(0)
        }
        return isMore
    }
}
