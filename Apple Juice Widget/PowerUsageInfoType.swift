//
// PowerUsageInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class PowerUsageInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Power Usage", comment: "")
        if let powerUsage = battery?.powerUsage {
            value = "\(powerUsage) \(NSLocalizedString("Watts", comment: ""))"
        } else {
            value = "--"
        }
    }
}
