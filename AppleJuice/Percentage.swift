//
// Percentage.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

struct Percentage {
    var numeric: Int?

    /// The current percentage, formatted according to the selected client locale, e.g.
    /// en_US: 42% fr_FR: 42 %
    var formatted: String {
        guard let percentage = numeric else {
            return NSLocalizedString("Calculating", comment: "")
        }

        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.generatesDecimalNumbers = false
        percentageFormatter.localizesFormat = true
        percentageFormatter.multiplier = 1.0
        percentageFormatter.minimumFractionDigits = 0
        percentageFormatter.maximumFractionDigits = 0

        return percentageFormatter.string(from: percentage as NSNumber) ?? "\(percentage) %"
    }
}
