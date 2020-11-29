//
// SourceInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class SourceInfoType: NSObject, BatteryInfoTypeProtocol {
    // MARK: Lifecycle

    init(_ battery: BatteryService?) {
        title = NSLocalizedString("Power Source", comment: "")
        value = NSLocalizedString(battery?.powerSource.rawValue ?? "", value: "--", comment: "")
    }

    // MARK: Internal

    var title: String
    var value: String
}
