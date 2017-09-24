//
// TimeRemainingInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class TimeRemainingInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: Battery?) {
        self.title = NSLocalizedString("Time Remaining", comment: "")
        if let value = battery?.timeRemainingFormatted {
            self.value = value
        } else {
            self.value = "--"
        }
    }
}
