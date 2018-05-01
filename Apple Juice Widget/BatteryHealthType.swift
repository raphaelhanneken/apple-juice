//
// TemperatureInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class BatteryHealthType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Health", comment: "")
        if let health = battery?.health {
            value = health
        } else {
            value = "--"
        }
    }
}
