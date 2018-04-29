//
// PercentageInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class PercentageInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Percentage", comment: "")
        if let percentage = battery?.state?.percentage {
            value = "\(percentage) %"
        } else {
            value = "--"
        }
    }
}
