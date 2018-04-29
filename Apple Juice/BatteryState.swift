//
// BatteryState.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

import Foundation

/// Define the precision, with wich the icon can display the current charging level
public let batteryStatusBarIconDrawingPrecision = 12.5

///  Defines the state the battery is currently in.
///
///  - pluggedAndCharged: The battery is plugged into a power supply and charged.
///  - charging:          The battery is plugged into a power supply and 
///                       charging. Takes the current percentage as argument.
///  - discharging:       The battery is currently discharging. Accepts the 
///                       current percentage as argument.
enum BatteryState: Equatable {
    case pluggedAndCharged
    case charging(percentage: Int)
    case discharging(percentage: Int)

    /// The current percentage.
    var percentage: Int {
        switch self {
        case .pluggedAndCharged:
            return 100
        case .charging(let percentage):
            return percentage
        case .discharging(let percentage):
            return percentage
        }
    }
}

///  Compares two BatteryStatusTypes for equality.
///
///  - parameter lhs: A BatteryStatusType.
///  - parameter rhs: Another BatteryStatusType.
///  - returns:       True if the supplied BatteryStatusType's are equal. Otherwise false.
func == (lhs: BatteryState, rhs: BatteryState) -> Bool {
    switch (lhs, rhs) {
    case (.charging, .charging), (.pluggedAndCharged, .pluggedAndCharged):
        return true
    case let (.discharging(lhsPercentage), .discharging(rhsPercentage)):
        // Divide the percentages by the defined drawing precision; So that the battery image
        // only gets redrawn, when it actually differs.
        return round(Double(lhsPercentage) / batteryStatusBarIconDrawingPrecision)
            == round(Double(rhsPercentage) / batteryStatusBarIconDrawingPrecision)
    default:
        return false
    }
}
