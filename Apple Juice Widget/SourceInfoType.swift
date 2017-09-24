//
// SourceInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class SourceInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: Battery?) {
        title = NSLocalizedString("Power Source", comment: "")
        if let src = battery?.powerSource {
            value = "\(src)"
        } else {
            value = "--"
        }
    }
}
