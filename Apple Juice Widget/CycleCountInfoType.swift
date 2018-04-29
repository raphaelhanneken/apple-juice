//
// CycleCountInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class CycleCountInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Cycle Count", comment: "")
        if let cycleCount = battery?.cycleCount {
            value = "\(cycleCount)"
        } else {
            value = "--"
        }
    }
}
