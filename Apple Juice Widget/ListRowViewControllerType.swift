//
// ListRowViewControllerType.swift
// Apple Juice Widget
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
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

/// Represents a single row.
final class ListRowViewControllerType: NSObject {

  /// Holds the battery property, e.g. time remaining.
  var title: String = ""

  /// Holds the value for the given type, e.g. 2:28
  var value: String = ""

  /// Initializes the RowViewControllerType
  ///
  /// - parameter definition: The RowViewControllerTypeDef.
  init(_ type: ListRowViewControllerTypeDef) {
    // Initialize the parent class.
    super.init()

    // Set the row title for the supplied ListRowViewControllerTypeDef.
    title = NSLocalizedString(type.rawValue, comment: "Translate and set the row description")
    // Set the value for the supplied ListRowViewControllerTypeDef.
    if let data = getBatteryInformation(forRowType: type) {
      value = data
    }
  }

  /// Returns the battery information for the supplied row type.
  ///
  /// - parameter type: The row type to get information for.
  /// - returns: A String containing the battery information for the supplied row type definition.
  private func getBatteryInformation(forRowType type: ListRowViewControllerTypeDef) -> String? {
    do {
      // Try opening the battery service IO.
      let battery = try Battery()

      // Get the battery information according to the given row type definition.
      switch type {
      case .timeRemaining:
        return battery.timeRemainingFormatted
      case .percentage:
        if let percentage = battery.percentage {
          return "\(percentage) %"
        }
      case .powerUsage:
        if let powerUsage = battery.powerUsage {
          return "\(powerUsage) \(NSLocalizedString("Watts", comment: "Translate Watts"))"
        }
      case .capacity:
        if let charge = battery.charge, capacity = battery.capacity {
          return "\(charge) / \(capacity) mAh"
        }
      case .cycleCount:
        if let cycleCount = battery.cycleCount {
          return "\(cycleCount)"
        }
      case .source:
        return battery.powerSource
      case .temperature:
        if let temp = battery.temperature {
          return "\(temp) °C / \(temp * 1.8 + 32) °F"
        }
      }
    } catch {
      print("Getting battery information for \(type) failed.")
    }
    return nil
  }

}

// MARK: ListRowViewControllerTypeDef

///  Represents a RowViewControllerType with information about a certain
///  battery status.
///
///  - Undefined:        Undefined row.
///  - TimeRemaining:    The time remaining until full.
///  - CurrentCharge:    The current charge in percent.
///  - PowerUsage:       The current power usage in Watts.
///  - Capacity:         The current charge and max capacity in mAh.
///  - CycleCount:       The battery's cycle count.
///  - Temperature:      The current temperature in C/F.
///  - Source:           The current power source.
///  - DesignCycleCount: The design cycle count.
///  - DesignCapacity:   The design capacity in mAh.
enum ListRowViewControllerTypeDef: String {
  case timeRemaining    = "Time Remaining"
  case percentage       = "Percentage"
  case powerUsage       = "Power Usage"
  case capacity         = "Charge"
  case cycleCount       = "Cycle Count"
  case source           = "Power Source"
  case temperature      = "Temperature"
}
