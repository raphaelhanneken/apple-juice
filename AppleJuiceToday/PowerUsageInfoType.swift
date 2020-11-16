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

        if let powerUsage = battery?.powerUsage,
           let amperage = battery?.amperage {
            value = "\(powerUsage) \(NSLocalizedString("Watts", comment: "")) (\(amperage) mA)"
        } else {
            value = "--"
        }
    }
}
