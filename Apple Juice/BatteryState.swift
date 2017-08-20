//
// BatteryState.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 - 2017 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// Define the precision, with wich the icon can display the current charging level
public let drawingPrecision = 12.5

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
        case .charging(let p):
            return p
        case .discharging(let p):
            return p
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
        return (round(Double(lhsPercentage) / drawingPrecision) == round(Double(rhsPercentage) / drawingPrecision))
    default:
        return false
    }
}
