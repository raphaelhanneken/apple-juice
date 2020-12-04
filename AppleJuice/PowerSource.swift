//
// PowerSource.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

enum PowerSource: String {
    case unknown = "Unknown"
    case powerAdapter = "Power Adapter"
    case battery = "Battery"

    var localizedDescription: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
