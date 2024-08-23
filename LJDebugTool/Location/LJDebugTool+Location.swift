//
//  LJDebugTool+Location.swift
//  LJDebugTool
//
//  Created by panjinyong on 2023/7/21.
//

import UIKit
import CoreLocation

extension LJDebugTool {
    
    @discardableResult
    public func addLocateObserver(handle: @escaping LocationSetCallback) -> String {
        let id = UUID().uuidString
        locationSetCallBacks[id] = handle
        return id
    }
    
    public func removeLocateObserver(_ id: String) {
        locationSetCallBacks.removeValue(forKey: id)
    }
    
    public func showLocationSetAlert(from vc: UIViewController) {
        let alert = UIAlertController.init(title: "custom location", message: nil, preferredStyle: .alert)
        alert.addTextField {[weak self] textField in
            guard let self else { return }
            textField.keyboardType = .decimalPad
            textField.placeholder = "latitude"
            if let customLocation {
                textField.text = "\(customLocation.latitude)"
            }
        }
        alert.addTextField {[weak self] textField in
            guard let self else { return }
            textField.keyboardType = .decimalPad
            textField.placeholder = "longitude"
            if let customLocation {
                textField.text = "\(customLocation.longitude)"
            }
        }

        alert.addAction(.init(title: "Confirm custom setting", style: .default, handler: {[weak self, weak alert, weak vc] _ in
            guard let self, let alert, let vc else { return }
            guard
                let lat = Double(alert.textFields?.first?.text ?? ""),
                let long = Double(alert.textFields?.last?.text ?? ""),
                abs(lat) <= 90,
                abs(long) <= 180
            else {
                let alert = UIAlertController.init(title: "Number invalid", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Confirm", style: .cancel))
                vc.present(alert, animated: true)
                return
            }
            let location = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
            customLocation = location
            storeCustomLocation()
            locationSetCallBacks.values.forEach { $0(location) }
        }))
        
        alert.addAction(.init(title: "Remove custom setting", style: .default, handler: {[weak self] _ in
            guard let self else { return }
            customLocation = nil
            storeCustomLocation()
            locationSetCallBacks.values.forEach { $0(nil) }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }
   
    private var customLocationUserDefaultKey: String { "\(self.classForCoder).customLocation" }
    
    public func loadCustomLocationCache() {
        guard let str = UserDefaults.standard.string(forKey: customLocationUserDefaultKey) else { return }
        let arr = str.components(separatedBy: ",")
        guard arr.count == 2, let lat = Double(arr[0]), let long = Double(arr[1]) else { return }
        customLocation = .init(latitude: lat, longitude: long)
    }
    
    private func storeCustomLocation() {
        guard let customLocation else {
            UserDefaults.standard.removeObject(forKey: customLocationUserDefaultKey)
            return
        }
        UserDefaults.standard.setValue("\(customLocation.latitude),\(customLocation.longitude)", forKey: customLocationUserDefaultKey)
    }
}
