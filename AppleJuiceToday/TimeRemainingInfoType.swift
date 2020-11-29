//
// TimeRemainingInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class TimeRemainingInfoType: NSObject, BatteryInfoTypeProtocol {
    // MARK: Lifecycle

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Time Remaining", comment: "")
        value = battery?.timeRemaining.formatted ?? "--"
    }

    // MARK: Internal

    var title: String
    var value: String
}
