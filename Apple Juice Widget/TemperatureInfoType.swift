//
// TemperatureInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class TemperatureInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Temperature", comment: "")
        if let temp = battery?.temperature {
            value = String(format: "%.1f °C / %.1f °F", arguments: [temp, (temp * 1.8 + 32)])
        } else {
            value = "--"
        }
    }
}
