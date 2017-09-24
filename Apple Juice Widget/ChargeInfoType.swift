//
// ChargeInfoType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

class ChargeInfoType: NSObject, BatteryInfoTypeProtocol {
    var title: String
    var value: String

    init(_ battery: Battery?) {
        title = NSLocalizedString("Charge", comment: "")
        if let charge = battery?.charge, let capacity = battery?.capacity {
            value = "\(charge) / \(capacity) mAh"
        } else {
            value = "--"
        }
    }
}
