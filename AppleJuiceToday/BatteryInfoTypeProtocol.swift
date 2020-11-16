//
// BatteryInfoTypeProtocol.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

@objc protocol BatteryInfoTypeProtocol {
    var title: String { get }
    var value: String { get }
}
